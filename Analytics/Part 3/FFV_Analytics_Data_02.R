# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Weitere Cleanups auf den Daten fuer Visualisierung.
#
# Autor         Ruth Ziegler
# Date          2016-06-14
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 3")

# --- import base script if not sourced
if(!exists("data.flights.grouped")) {
  source("FFV_Analytics_Data.R")
}

# --- constants 
kSeriesLength <- 14 # should be multiples of 7 to have complete weeks

# filter only complete price series (means that kSeriesLength requests for flight on day x have been fulfilled)
# --- drop incomplete series
data.flights.completeSeriesOnly <- data.flights.grouped %>%
  # select(-p1, -p2, -p3, -p4, -psd, -pmax) %>%  # drop some unused columns
  mutate(
    requestDayAsDate = as.Date(strptime(requestDay, "%d.%m.%Y")),
    departureDayAsDate = as.Date(strptime(departureDay, "%d.%m.%Y"))
  ) %>%
  ungroup() %>%
  arrange(flightNumber, departureDay, requestDayAsDate) %>%  # sorting 
  group_by(flightNumber, departureDay) %>%
  mutate(
    rank = dense_rank(requestDayAsDate),
    maxRank = max(rank)
  )

# ATTENTION: do not change grouping before executing
data.flights.completeSeriesOnly <- data.flights.completeSeriesOnly %>%
  filter(
    (maxRank >= kSeriesLength) & (rank > (maxRank - kSeriesLength))
  )

