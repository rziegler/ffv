# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Einlesen der rohen Daten (tidy) für Aufbereitung in weiteren
#               Skripten.
#
# Autor         Ruth Ziegler
# Date          2016-06-01
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 2")

# --- import base script if not sourced
if(!exists("DateFromMillis", mode="function")) {
  source("FFV_Analytics_Base.R")
}

# --- constants
kReadDataModes <- c("DATABASE", "FILE")
kReadDataMode <- kReadDataModes[2]

# --- read data
if(kReadDataMode=="DATABASE") {
  kDbUrl  <- "http://localhost:7474/db/data/"
  kDbUser <- "neo4j"
  kDbPwd  <- "ffv"
  
  # read from neo4j database   !!! IMPORTANT: Start neo4j console first!!!
  graph <- startGraph(kDbUrl, username=kDbUser, password=kDbPwd)
  #data.raw <- cypher(graph, 
  #  "MATCH (f:Flight) --> (n:FlightDate) --> (p:Price) 
  #   RETURN f.flightNumber, f.carrier, f.number, f.origin, f.destination, n.departureDate, n.arrivalDate, n.duration, p.price, p.date, p.executionDate, p.requestDaytime, a.agentName, a.agentType")
  # --> Error: Java heap space  
  
  # reduce data size with only requesting one single destination (LHR) for the moment ;)
  data.raw <- cypher(graph, 
    "MATCH (f:Flight {destination:'LHR' }) --> (n:FlightDate) --> (p:Price) --> (a:Agent)
     RETURN f.flightNumber, f.carrier, f.number, f.origin, f.destination, n.departureDate, n.arrivalDate, n.duration, p.price, p.date, p.executionDate, p.requestDaytime, a.agentName, a.agentType")
  
} else if (kReadDataMode=="FILE") {
  # read from CSV file 
  data.raw <- fread("input.csv")
} else {
  stop(sprintf("Invalid read data mode. Valid modes: %s", paste(kReadDataModes, collapse=", ")))
}

# rename columns
names(data.raw) <- c("flightNumber", "carrier", "number", "origin", "destination", "departure", "arrival", "duration", "price", "requestDate", "requestExecutionDate", "requestDaytime", "agentName", "agentType")

# transform data types
data.raw$flightNumber <- as.factor(data.raw$flightNumber)
data.raw$carrier <- as.factor(data.raw$carrier)
data.raw$number <- as.factor(data.raw$number)
data.raw$origin<- as.factor(data.raw$origin)
data.raw$destination <- as.factor(data.raw$destination)
data.raw$departure <- DateFromMillis(data.raw$departure)
data.raw$arrival <- DateFromMillis(data.raw$arrival)
data.raw$price <- as.double(data.raw$price)
data.raw$requestDaytime <- as.factor(data.raw$requestDaytime)
data.raw$agentName <- as.factor(data.raw$agentName)
data.raw$agentType <- as.factor(data.raw$agentType)
# use the exact request execution date instead of the "normalized" request date
#data.raw$requestDate <- DateFromMillis(data.raw$requestDate)
data.raw$requestDate <- DateFromMillis(data.raw$requestExecutionDate)

# --- reshaping data

# filter all UNKNOWN requests and calculate helper columns for grouping
data.flights <- data.raw %>% 
  mutate(
    # delta > 90 duerfte auch mit dem fehler zusammenhaengen, dass requestdate veraendert wurde mit skyscanner api
    deltaTime = (round(difftime(data.raw$departure, data.raw$requestDate, units = c("days"), tz="UTC"), 0)),
    requestWeekday = as.factor(weekdays(data.raw$requestDate, abbreviate=TRUE)),
    requestDay = (strftime(requestDate, format="%d.%m.%Y", tz="UTC")),
    departureDay = (strftime(departure, format="%d.%m.%Y", tz="UTC")),
    departureTime = (strftime(departure, format="%H:%M:%S", tz="UTC")),
    departureWeekday = as.factor(weekdays(data.raw$departure, abbreviate=TRUE))
  ) %>%
  select(-requestExecutionDate)  # drop the requestExecutionDate column, only use requestDate from now on

data.flights.filtered <- data.flights %>% 
  #filter(requestDaytime!="UNKNOWN", agentType=="Airline") # TODO undo
  #filter(requestDaytime!="UNKNOWN", agentName=="eDreams") # TODO undo
  filter(requestDaytime!="UNKNOWN")

data.flights.unique <- distinct(data.flights.filtered)

# Group the data so that for every request day and departure day there is only ONE observation.
# Therefore the columns not included anymore after grouping (since irrelevant) are: 
# - requestDate (has time information not needed)
# - requestDaytime (quasi a grouped time information)
# - price (is aggregated, see sumarise)
data.flights.grouped <- data.flights.unique %>% 
  group_by(
    flightNumber, carrier, number, origin, destination,  # flight related columns
    departure, arrival, duration, departureDay, departureTime, departureWeekday,  # flight date related columns
    requestDay, requestWeekday,  # request related columns
    agentName, agentType  # TODO undo
    ) %>%  # agent related
  summarise(  # aggregate price information
    p1=first(unique(price)),
    p2=nth(unique(price), 2),
    p3=nth(unique(price), 3),
    p4=nth(unique(price), 4), # dont use last(price), otherwise it uses the last again if there are less than 4 prices a day
    pmin=min(price),
    pmax=max(price),
    psd=sd(price),
    pmean=mean(price),
    pmedian=median(price),
    price.distinct=n_distinct(price),
    agent.distinct=n_distinct(agentName),
    n=n()  # the count of the number of rows being in same group
  )

write.csv(data.flights.grouped, "data-flights-grouped.csv")
