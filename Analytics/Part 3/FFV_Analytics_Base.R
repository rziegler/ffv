# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Basis-Funktionalitäten wie Funktionen oder Libs.
#
# Autor         Ruth Ziegler
# Date          2016-06-01
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 3")

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

SavePlot <- function(name) {
  ggsave(file=name, width = 297, height = 210, units = "mm")
}

PrintMinPrice <- function(df, fNumber, departureDateAsString) {  #df = data.flights.completeSeriesOnly, flightNumber = "LX332", departureDate = "2016-06-01"
  tmp <- df %>%
    filter(
      flightNumber == fNumber,
      departureDate >= departureDateAsString,
      departureDate <= departureDateAsString
    )
  # min price
  dev.off()
  p <- ggplot(tmp, aes(x=requestDate, y=pmin, group=agentName, color=agentName)) +
    geom_line() +
    ggtitle(sprintf("Min price (flight %s, on %s)", tmp$flightNumber, paste(unique(tmp$departureDate), collapse = ", ")))
  print(p)
}

FilterDataForDestination <- function(dest) {
  if(dest == "ALL") {
    data.tmp <- data.flights.completeSeriesOnly %>%
      ungroup() %>%
      arrange(flightNumber, departureDate, requestDate) %>%
      group_by(flightNumber, departureDate, departureTime, departureWeekday, requestDate, deltaTime, origin, destination, carrier) %>%
      summarise(
        pmin = min(pmin)
      )
  } else {
    data.tmp <- data.flights.completeSeriesOnly %>%
      ungroup() %>%
      arrange(flightNumber, departureDate, requestDate) %>%
      group_by(flightNumber, departureDate, departureTime, departureWeekday, requestDate, deltaTime, origin, destination, carrier) %>%
      filter(
        destination == dest
      ) %>%
      summarise(
        pmin = min(pmin)
      )
  }
  
  data.tmp <- data.tmp %>%
    ungroup() %>%
    group_by(flightNumber, departureDate) %>%
    mutate(
      priceChangeRel = pmin/lag(pmin, default = first(pmin)),
      priceChangeAbs = pmin/first(pmin),
      pr = dense_rank(pmin),
      bin = cut(pmin, 7),
      binRanked = cut(pmin, 7, labels=c(1,2,3,4,5,6,7)),
      priceChangeRelBoolean = ifelse((pmin == lag(pmin, default = first(pmin))), 0, ifelse(pmin > lag(pmin, default = first(pmin)), 1, -1)),
      priceChangeAbsBoolean = ifelse((pmin == first(pmin)), 0, ifelse(pmin > first(pmin), 1, -1))
    )
  
  data.tmp <- data.tmp %>%
    ungroup() %>%
    group_by(origin, destination, flightNumber, departureDate, requestDate) %>%
    # select(origin, destination, flightNumber, departureDate, requestDate, deltaTime, pmin, priceChangeRel, priceChangeAbs, pr, pcm, priceChangeRelBoolean, priceChangeAbsBoolean) %>%
    arrange(origin, destination, flightNumber, departureDate, requestDate)
  
  return(data.tmp)
}

# --- import libraries
#install.packages("RNeo4j", "dplyr", "ggplot2", "tidyr", "data.table")  # only needs to be once
#install.packages("Rmisc")
#install.packages("ISOweek")
library(data.table)
library(bit64)
library(RNeo4j)
library(Rmisc)
library(dplyr)
library(ggplot2)
library(tidyr)
library(ISOweek)
