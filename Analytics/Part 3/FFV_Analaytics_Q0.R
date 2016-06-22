# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Frage 0) An welchem Wochentag soll ich buchen? (requestDate)
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
data.q0 <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    pmin == min(pmin)
  )

# count by request weekday and destination
data.q0.byRequestWeekday <- data.q0 %>%
  group_by(requestWeekday, destination) %>%
  summarise(
    n = n()
  )

# plot cheapest flights distributed by request weekday for each destination
ggplot(data = data.q0.byRequestWeekday, 
       aes(x = requestWeekday, 
           y = n)) + 
  geom_bar(stat="identity") +
  facet_wrap(~ destination, ncol = 5, scales="free_y") + 
  ggtitle("Number of cheapest flights on request weekday overall") +
  xlab("request weekday") +
  ylab("number of cheapest flights")


# calculate the mode value for request weekday
# data.q0.mode <- mfv(as.numeric(data.q0$requestWeekday))

# same as above but additionally grouped by agend
data.q0.agent <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, agentName, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate, agentName) %>%
  filter(
    pmin == min(pmin)
  )

# count by request weekday and destination for each agent
data.q0.agent.byRequestWeekday <- data.q0.agent %>%
  group_by(requestWeekday, agentName, destination) %>%
  summarise(
    n = n()
  )

# plot cheapest flights distributed by request weekday for each destination and agent
# ggplot(data = data.q0.agent.byRequestWeekday, 
#        aes(x = requestWeekday, 
#            y = n, 
#            fill = agentName)) + 
#   geom_bar(stat="identity", position = "dodge") +
#   geom_vline(xintercept=seq(1.5, length(unique(viz.q0$requestWeekday))-0.5, 1), 
#              lwd=0.5, colour="black") +
#   ggtitle("Number of cheapest flights on request weekday for each agent") +
#   xlab("request weekday") +
#   ylab("number of cheapest flights")

ggplot(data = data.q0.agent.byRequestWeekday, 
       aes(x = requestWeekday, 
           y = n)) + 
  geom_bar(stat="identity") +
  facet_grid(destination ~ agentName, scales="free_y") + 
  ggtitle("Number of cheapest flights on request weekday for each agent") +
  xlab("request weekday") +
  ylab("number of cheapest flights")
