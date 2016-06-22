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
if(!exists("global_labeller", mode="function")) {
  source("FFV_Analytics_QBase.R")
}

# install.packages("modeest")
library(modeest)

# filter lowest prices for each flight
data.q1 <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    pmin == min(pmin)
  )

# -- BY DEPARTURE WEEKDAY, FLIGHT NUMBER (CARRIER) AND DESTINATION
# count by departure weekday for each flight with same flight number and destination
data.q1.byDepartureWeekday <- data.q1 %>%
  group_by(flightNumber, carrier, departureWeekday, destination) %>%
  summarise(
    n = n()
  )

# data.q1.byDepartureWeekday <- data.q1.byDepartureWeekday %>%
#   ungroup() %>%
#   group_by(flightNumber, carrier, destination) %>%
#   mutate (
#     total = max(cumsum(n))  # calculate total n
#   )
# test for geom_text to write n for each stacked bar -> not working yet!! 
# data.q1.byDepartureWeekday <- data.q1.byDepartureWeekday %>%
#   ungroup() %>%
#   group_by(destination, carrier, departureWeekday) %>%
#   # arrange(flightNumber, carrier, departureWeekday, destination, n) %>%
#   mutate (
#     pos = cumsum(n) - (0.5*n))

# plot cheapest flights distributed by request weekday for each destination
ggplot(data = data.q1.byDepartureWeekday, 
       aes(x = departureWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity") +
  # annotate("text", x=3, y=10, label = sprintf("n=%s", data)) + 
  # geom_text(aes(label = n, y = pos), size = 3) +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on departure weekday overall") +
  xlab("departure weekday") +
  ylab("number of cheapest flights")
SavePlot("q1-departure-wday-all.pdf")

ggplot(data = data.q1.byDepartureWeekday, 
       aes(x = departureWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity", position = "dodge") +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on departure weekday overall") +
  xlab("departure weekday") +
  ylab("number of cheapest flights")
SavePlot("q1-departure-wday-all-2.pdf")

# for validation of some results ;)
# PrintMinPrice(data.flights.completeSeriesOnly, "LX332", "2016-06-01")

# same as above but additionally grouped by agent
data.q1.agent <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, agentName, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate, agentName) %>%
  filter(
    pmin == min(pmin)
  )

# count by departure weekday for each flight with same flight number for each agent
data.q1.agent.byDepartureWeekday <- data.q1.agent %>%
  group_by(flightNumber, departureWeekday, carrier, agentName) %>%
  summarise(
    count = n()
  )

ggplot(data = data.q1.agent.byDepartureWeekday, 
       aes(x = departureWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity") +
  facet_grid(destination ~ agentName, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on departure weekday for each agent") +
  xlab("departure weekday") +
  ylab("number of cheapest flights")
SavePlot("q1-departure-wday-agent.pdf")
