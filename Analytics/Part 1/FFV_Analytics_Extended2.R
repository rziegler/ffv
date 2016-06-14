# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Erweiterte statistische Auswertungen von FF_Analytics.R
#
# Autor         Ruth Ziegler
# Date          2016-05-29
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 1")

# --- import libraries
#install.packages("ggplot2", "dplyr")  # only needs to be once
library(ggplot2)
library(dplyr)

# --- read from CSV written in FFV_Analytics.R
ext.data.flights.full <- read.csv("data-flights-full.csv", colClasses=c("NULL",NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA)) # "NULL" means skip the column, NA means that R chooses the appropriate data type for that column

ext.data.flights.full$origin<- as.factor(ext.data.flights.full$origin)
ext.data.flights.full$destination <- as.factor(ext.data.flights.full$destination)
ext.data.flights.full$flightNumber <- as.factor(ext.data.flights.full$flightNumber)
ext.data.flights.full$requestDate <- as.POSIXct(ext.data.flights.full$requestDate, tz="UTC")
ext.data.flights.full$requestDaytime <- as.factor(ext.data.flights.full$requestDaytime)
ext.data.flights.full$arrival <- as.POSIXct(ext.data.flights.full$arrival, tz="UTC")
ext.data.flights.full$departure <- as.POSIXct(ext.data.flights.full$departure, tz="UTC")
ext.data.flights.full$price <- as.double(ext.data.flights.full$price)
ext.data.flights.full$requestWeekday <- as.factor(ext.data.flights.full$requestWeekday)
ext.data.flights.full$departureWeekday <- as.factor(ext.data.flights.full$departureWeekday)

ext.data.flights.full$departureDay <- as.POSIXct(round(ext.data.flights.full$departure, "days"))  # deplyr mutate does not support POSIXlt results

# -- plot all by departure day
ext.data.flights.bydeparture <- ext.data.flights.full %>% 
  filter(requestDaytime!="UNKNOWN") %>%
  group_by(departureDay, origin, destination) %>%
  summarise(  # aggregieren
    priceMedian=median(price), 
    priceMean=mean(price), 
    priceMin=min(price), 
    priceMax=max(price), 
    sd(price), 
    n=n()  # the count of the number of rows being in same group
  ) %>%
  ungroup() %>%  # to be save, if executed multiple times :)
  arrange(origin, destination, departureDay, priceMedian)

ggplot(ext.data.flights.bydeparture, aes(x = departureDay)) +
  geom_point(aes(y = priceMean),color="red") +
  geom_point(aes(y = priceMin)) +
  geom_point(aes(y = priceMax))
