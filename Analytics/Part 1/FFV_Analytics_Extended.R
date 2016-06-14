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
ext.data.flights <- read.csv("data-flights.csv", colClasses=c("NULL",NA,NA,NA,NA,NA,NA,NA,NA,NA,NA)) # "NULL" means skip the column, NA means that R chooses the appropriate data type for that column

ext.data.flights$origin<- as.factor(ext.data.flights$origin)
ext.data.flights$destination <- as.factor(ext.data.flights$destination)
ext.data.flights$flightNumber <- as.factor(ext.data.flights$flightNumber)
ext.data.flights$requestDaytime <- as.factor(ext.data.flights$requestDaytime)
ext.data.flights$price <- as.double(ext.data.flights$price)
ext.data.flights$requestWeekday <- as.factor(ext.data.flights$requestWeekday)
ext.data.flights$departureWeekday <- as.factor(ext.data.flights$departureWeekday)

# --- filter one weekday and visualize its histogram 
# from stats-all.csv (FFV_Analytics.R)
# deltaTime	departureWeekday	origin	destination	priceMedian	priceMean	  priceMin	priceMax	sd(price)	  n
# 87      	Fr	              ZRH   	LHR	        207.4	      209.0922038	90	      446.69	  56.79441417	1325

histogram.delta.weekday <- ext.data.flights %>%
  filter(requestDaytime!="UNKNONW", deltaTime==87, departureWeekday=="Fr") %>%
  ungroup() %>%  # to be save, if executed multiple times :)
  arrange(requestDaytime)

ggplot(histogram.delta.weekday, aes(x=price)) + 
  geom_histogram(aes(y=..density..)) +
  geom_density()

# -- plot all delta times in one diagram

histogram.all <- ext.data.flights %>%
  mutate(deltaWeekday = paste(ext.data.flights$deltaTime, ext.data.flights$requestWeekday, sep="")) %>%
  filter(requestDaytime!="UNKNONW", deltaTime > 80, deltaTime < 91) %>%
  ungroup() %>%  # to be save, if executed multiple times :)
  arrange(deltaWeekday)

histogram.all.stats <- histogram.all %>%
  group_by(deltaWeekday) %>%
  summarise(  # aggregieren
    priceMedian=median(price), 
    priceMean=mean(price), 
    priceMin=min(price), 
    priceMax=max(price), 
    sd(price), 
    n=n()  # the count of the number of rows being in same group
  ) %>%
  ungroup() %>%  # to be save, if executed multiple times :)
  arrange(deltaWeekday)
  
ggplot(histogram.all, aes(x = deltaWeekday, y = price)) +
  geom_point(alpha = 1/10) +
  geom_point(data = histogram.all.stats, aes(y = priceMean),
             colour = 'red', size = 1) +
  geom_point(data = histogram.all.stats, aes(y = priceMin),
             colour = 'blue', size = 1) +
  geom_point(data = histogram.all.stats, aes(y = priceMax),
             colour = 'blue', size = 1)

