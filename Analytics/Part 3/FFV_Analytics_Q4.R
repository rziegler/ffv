# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Frage 4) Gibt es Destinationen, welche sich ähnlich verhalten?
#
#               WICHTIG: 
#
# Autor         Ruth Ziegler
# Date          2016-06-22
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 3")

# --- import base script if not sourced
if(!exists("global_labeller", mode="function")) {
  source("FFV_Analytics_QBase.R")
}


data.q4 <- data.flights.completeSeriesOnly %>% 
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate, agentName) %>%
  filter(
    pmin == min(pmin) | pmin == max(pmin)
  )

# --- make each lowest price unique
data.q4.unique <- data.q4 %>%
  ungroup() %>%
  group_by(flightNumber, carrier, origin, destination, 
           departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday, pmin, agentName, agentType) %>%
  arrange(flightNumber, departureDate, departureTime, agentName, requestDate) %>%
  summarise(
    n = n(),
    requestDate = first(requestDate),  # keep the first #### TODO it could be that if I have mutliple cheapest prices, they are not in the same week
    requestWeekday = first(requestWeekday),
    deltaTime = first(deltaTime)
  )

data.q4.diff <- data.q4.unique %>%
  ungroup() %>%
  group_by(flightNumber, carrier, origin, destination, 
           departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday,
           agentName) %>%
  summarise(
    n = n(),
    priceMin = min(pmin),
    priceMax = max(pmin)
  )

viz.q4 <- data.q4.diff %>%
  filter(
    carrier == "LX"
  )

ggplot(viz.q4, aes(priceMin, priceMax, color = carrier)) + geom_point()
