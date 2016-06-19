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

# --- import libraries
#install.packages("RNeo4j", "dplyr", "ggplot2", "tidyr", "data.table")  # only needs to be once
#install.packages("Rmisc")
library(data.table)
library(bit64)
library(RNeo4j)
library(Rmisc)
library(dplyr)
library(ggplot2)
library(tidyr)
