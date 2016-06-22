# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Frage 1) An welchem Wochentag soll ich abfliegen? (departureDate)
#
# Autor         Ruth Ziegler
# Date          2016-06-21
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 3")

# --- import base script if not sourced
if(!exists("data.flights.completeSeriesOnly")) {
  source("FFV_Analytics_Data.R")
}

# install.packages("modeest")
library(modeest)

# filter lowest prices for each flight
data.q1 <- data.fligths.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    pmin == min(pmin)
  )

# count by departure weekday for each flight with same flight number
data.q1.byDepartureWeekday <- data.q1 %>%
  group_by(flightNumber, departureWeekday) %>%
  summarise(
    n = n()
  )

# same as above but additionally grouped by agent
data.q1.agent <- data.fligths.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, agentName, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate, agentName) %>%
  filter(
    pmin == min(pmin)
  )

# count by departure weekday for each flight with same flight number for each agent
data.q1.agent.byDepartureWeekday <- data.q1.agent %>%
  group_by(flightNumber, departureWeekday, agentName) %>%
  summarise(
    count = n()
  )

# plot cheapest flights distributed by departure weekday for each agent
ggplot(data = data.q1.agent.byDepartureWeekday, 
       aes(x = data.q1.agent.byDepartureWeekday$requestWeekday, 
           y = data.q1.agent.byDepartureWeekday$n, 
           fill = data.q1.agent.byDepartureWeekday$agentName)) + 
  geom_bar(stat="identity", position = "dodge") +
  geom_vline(xintercept=seq(1.5, length(unique(data.q1.agent.byDepartureWeekday$requestWeekday))-0.5, 1), 
             lwd=0.5, colour="black") +
  ggtitle("Number of cheapest flights on request weekday for each agent") +
  xlab("request weekday") +
  ylab("number of cheapest flights")

