# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
# Autor         Ruth Ziegler
# Date          2016-05-29
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 1")

# --- function definitions
DateFromMillis <- function(millis) {
  # Converts the given date from millis into a POSIXct date object. If the given
  # date is already a POSIXct date, then it is returned unchanged.
  # 
  # Args:
  #   millis: The date (including time) in milliseconds.
  #
  # Returns:
  #   The converted date in POSIXct format.
  if(is.numeric.POSIXt(millis)) {
    return (millis)
  } else {
    date <- as.POSIXct(millis/1000, origin="1970-01-01", tz="UTC")
    return (date)
  }
}

# --- import libraries
#install.packages("RNeo4j", "dplyr")  # only needs to be once
library(RNeo4j)
library(dplyr)

# --- constants
kDbUrl  <- "http://localhost:7474/db/data/"
kDbUser <- "neo4j"
kDbPwd  <- "ffv"

# --- read data
# read from neo4j database   !!! IMPORTANT: Start neo4j console first!!!
graph <- startGraph(kDbUrl, username=kDbUser, password=kDbPwd)
# Error: Java heap space
#data.raw <- cypher(graph, 
#  "MATCH (f:Flight) --> (n:FlightDate) --> (p:Price) 
#   RETURN p.price, p.date, p.requestDaytime, n.arrivalDate, n.departureDate, n.duration, f.flightNumber, f.origin, f.destination")

# reduce data size with only requesting one single destination (LHR) for the moment ;)
data.raw <- cypher(graph, 
  "MATCH (f:Flight {destination:'LHR' }) --> (n:FlightDate) --> (p:Price) 
   RETURN p.price, p.date, p.requestDaytime, n.arrivalDate, n.departureDate, n.duration, f.flightNumber, f.origin, f.destination")

# rename columns
names(data.raw) <- c("price", "requestDate", "requestDaytime", "arrival", "departure", "duration", "flightNumber", "origin", "destination")

# transform data types
data.raw$origin<- as.factor(data.raw$origin)
data.raw$destination <- as.factor(data.raw$destination)
data.raw$flightNumber <- as.factor(data.raw$flightNumber)
data.raw$requestDate <- DateFromMillis(data.raw$requestDate)
data.raw$requestDaytime <- as.factor(data.raw$requestDaytime)
data.raw$arrival <- DateFromMillis(data.raw$arrival)
data.raw$departure <- DateFromMillis(data.raw$departure)
data.raw$price <- as.double(data.raw$price)

# --- reshaping data
# calculate new columns
data.flights <- data.raw %>% 
  mutate(
    deltaTime = (round(difftime(data.raw$departure, data.raw$requestDate, units = c("days")), 0)),
    requestWeekday = as.factor(weekdays(data.raw$requestDate, abbreviate=TRUE)),
    departureTime = (strftime(departure, format="%H:%M:%S")),
    departureWeekday = as.factor(weekdays(data.raw$departure, abbreviate=TRUE))
  )
#write.csv(data.flights, "data-flights-full.csv") # write CSV for simpler use as input in FF_Analytics_Extended2.R

# remove absolute date rows (requestDate, arrival, departure)
data.flights <- data.flights %>% select(-requestDate, -departure, -arrival)
#write.csv(data.flights, "data-flights.csv")  # write CSV for simpler use as input in FF_Analytics_Extended.R

# ---calculate statistics for visualization
stats.all <- data.flights %>% 
  filter(requestDaytime!="UNKNOWN") %>%
  group_by(deltaTime, departureWeekday, origin, destination) %>%
  summarise(  # aggregieren
    priceMedian=median(price), 
    priceMean=mean(price), 
    priceMin=min(price), 
    priceMax=max(price), 
    sd(price), 
    n=n()  # the count of the number of rows being in same group
  ) %>%
  ungroup() %>%  # to be save, if executed multiple times :)
  arrange(origin, destination, -deltaTime, priceMedian)
#write.csv(stats.all, "stats-all.csv")
