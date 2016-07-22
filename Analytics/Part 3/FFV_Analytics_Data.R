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
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 3")

# --- import base script if not sourced
if(!exists("DateFromMillis", mode="function")) {
  source("FFV_Analytics_Base.R")
}

# --- constants
kReadDataModes <- c("DATABASE", "FILE")
kReadDataMode <- kReadDataModes[2]

######## for constants relating complete time series look further down 

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
names(data.raw) <- c("flightNumber", "carrier", "number", "origin", "destination", "departure", "arrival", "duration", "price", "request", "requestExecution", "requestDaytime", "agentName", "agentType")

# transform data types
data.raw$flightNumber <- as.factor(data.raw$flightNumber)
data.raw$carrier <- as.factor(data.raw$carrier)
data.raw$number <- as.factor(data.raw$number)
data.raw$origin<- as.factor(data.raw$origin)
data.raw$destination <- as.factor(data.raw$destination)
data.raw$departure <- DateFromMillis(data.raw$departure)
data.raw$arrival <- DateFromMillis(data.raw$arrival)
data.raw$price <- as.double(data.raw$price)
data.raw$requestDaytime <- factor(data.raw$requestDaytime, levels = c("NIGHT", "MORNING", "NOON", "EVENING", "UNKNOWN"))
data.raw$agentName <- as.factor(data.raw$agentName)
data.raw$agentType <- as.factor(data.raw$agentType)
# use the exact request execution date instead of the "normalized" request date
#data.raw$request <- DateFromMillis(data.raw$request)
data.raw$request <- DateFromMillis(data.raw$requestExecution)

# --- reshaping data

# filter all UNKNOWN requests and calculate helper columns for grouping
data.flights <- data.raw %>% 
  mutate(
    departureDate = as.IDate(data.raw$departure),
    departureTime = as.ITime(data.raw$departure),
    arrivalDate = as.IDate(data.raw$arrival),
    arrivalTime = as.ITime(data.raw$arrival),
    requestDate = as.IDate(data.raw$request),
    # requestTime = as.ITime(data.raw$request),
    deltaTime = difftime(departureDate, requestDate, units = c("days"), tz="UTC"),
    requestWeekday = factor(weekdays(data.raw$request, abbreviate=TRUE), levels = c("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So")),
    departureWeekday = factor(weekdays(data.raw$departure, abbreviate=TRUE), levels = c("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"))
  ) %>%
  select(-requestExecution, -number, -departure, -arrival, -request)  # drop the requestExecutionDate column, only use requestDate from now on

data.flights.filtered <- data.flights %>% 
  filter(requestDaytime != "UNKNOWN")

data.flights.unique <- distinct(data.flights.filtered)

# Group the data so that for every request day and departure day there is only ONE observation.
# Therefore the columns not included anymore after grouping (since irrelevant) are: 
# - requestDate (has time information not needed)
# - requestDaytime (quasi a grouped time information)
# - price (is aggregated, see sumarise)
data.flights.grouped <- data.flights.unique %>% 
  group_by(
    flightNumber, carrier, origin, destination,  # flight related columns
    departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday,  # flight date related columns
    requestDate, requestWeekday, deltaTime, # request related columns
    agentName, agentType  # TODO undo
  ) %>%  # agent related
  summarise(  # aggregate price information
    pmin=min(price)
  )

# filter only complete price series (means that kSeriesLength requests for flight on day x have been fulfilled)

# --- constants for series length and latest request date
kSeriesLength <- 49 # should be multiples of 7 to have complete weeks
kLatestRequestDate <- max(data.flights.grouped$requestDate)  # latest request date from dump

# --- drop incomplete series
data.flights.completeSeriesOnly <- data.flights.grouped %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    departureDate <= kLatestRequestDate
  )

# ATTENTION: do not change grouping before executing, it bases on grouping of prev stmt
data.flights.completeSeriesOnly <- data.flights.completeSeriesOnly %>%
  mutate(
    rank = dense_rank(requestDate),
    maxRank = max(rank)
  )

# ATTENTION: do not change grouping before executing, it bases on grouping of prev stmt
data.flights.completeSeriesOnly <- data.flights.completeSeriesOnly %>%
  filter(
    (maxRank >= kSeriesLength) & (rank > (maxRank - kSeriesLength))
  )

# ATTENTION: do not change grouping before executing, it bases on grouping of prev stmt
data.flights.completeSeriesOnly <- data.flights.completeSeriesOnly %>%
  select(-rank, -maxRank) 

# --- filter all series that are not continuous, i.e. deltaTime 1,2,3,4....20,21,22,23,...
# ATTENTION: do not change grouping before executing, it bases on grouping of prev stmt
data.flights.completeSeriesOnly <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  group_by(flightNumber, departureDate) %>%
  filter(
    max(deltaTime) <= kSeriesLength
  )

# writing the results
write.csv(data.flights.grouped, "data-flights-grouped.csv")
write.csv(data.flights.completeSeriesOnly, "data-flights-completeseries.csv")

# -- for checking if all flights depart on every weekday or not
# -- actually ICN (Seoul) only flies on DI, DO and SA, and RHO (Rhodes) does not fly on FR/SO, all other flights depart on every weekday
data.flights.destinationByWeekday <- data.flights.completeSeriesOnly %>%
  group_by(destination) %>%
  summarise(
    n = n(),
    ndistinct = n_distinct(departureWeekday),
    weekdays_concatenated = paste(unique(departureWeekday), collapse = ", ")
  ) %>% 
  arrange(ndistinct, destination)
