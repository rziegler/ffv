# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Frage 2) In welcher Woche VOR dem Abflug ist es am günstigsten?
#
#               WICHTIG: Wenn ein günstigster Preis von einem Anbieter über 
#               mehrere Tage konstant ist, dann wird jeweils nur der früheste
#               Tag behalten. So wird vermieden, dass ein Abflugtag mehrmals 
#               berücksichtigt wird.
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

# --- filter data
# filter lowest prices for each flight
data.q2 <- data.flights.completeSeriesOnly %>% 
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    pmin == min(pmin)
  ) %>% mutate (
    weeks = ceiling((deltaTime/7))
  )

# --- make each lowest price unique
# if a price doesn't change for multiple days and it is the cheapest for this flights, 
# there are multiple rows for every request day with that cheap price in data.q2. 
# to avoid counting a destination-related row multiple times only one row is kept 
# (the first returning this cheap price).
data.q2.unique <- data.q2 %>%
  ungroup() %>%
  group_by(flightNumber, carrier, origin, destination, 
           departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday,
           agentName, agentType, pmin) %>%
  arrange(flightNumber, departureDate, departureTime, agentName, requestDate, weeks) %>%
  summarise(
    requestDate = first(requestDate),  # keep the first #### TODO it could be that if I have mutliple cheapest prices, they are not in the same week
    requestWeekday = first(requestWeekday),
    deltaTime = first(deltaTime),
    weeks = first(weeks)
  )

# -- BY WEEKS, FLIGHT NUMBER (CARRIER) AND DESTINATION
# count by delta weeks for each flight with same carrier and destination
data.q2.byDeltaWeek <- data.q2.unique %>%
  group_by(carrier, destination, weeks) %>%
  summarise(
    n = n()
  )

# plot cheapest flights distributed by request weekday for each destination
ggplot(data = data.q2.byDeltaWeek, 
       aes(x = weeks, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity") +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on delta weeks overall") +
  xlab("delta week (number of weeks before departure)") +
  ylab("number of cheapest flights")
SavePlot("q2-departure-weeks-all.pdf")

ggplot(data = data.q2.byDeltaWeek, 
       aes(x = weeks, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity", position = "dodge") +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on delta weeks overall") +
  xlab("delta week (number of weeks before departure)") +
  ylab("number of cheapest flights")
SavePlot("q2-departure-weeks-all-2.pdf")


# for validation of some results ;)
# PrintMinPrice(data.flights.completeSeriesOnly, "TK1908", "2016-06-20")
# PrintMinPrice(data.flights.completeSeriesOnly, "SQ345", "2016-06-10")
# PrintMinPrice(data.flights.completeSeriesOnly, "SQ2928", "2016-06-10")



# same as above but additionally grouped by agent
data.q2.agent <- data.flights.completeSeriesOnly %>% 
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    pmin == min(pmin)
  ) %>% mutate (
    weeks = ceiling((deltaTime/7))
  )

# --- make each lowest price unique
data.q2.agent.unique <- data.q2.agent %>%
  ungroup() %>%
  group_by(flightNumber, carrier, origin, destination, 
           departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday,
           agentName, agentType, pmin) %>%
  arrange(flightNumber, departureDate, departureTime, agentName, requestDate, weeks) %>%
  summarise(
    requestDate = first(requestDate),  # keep the first
    requestWeekday = first(requestWeekday),
    deltaTime = first(deltaTime),
    weeks = first(weeks)
  )

# -- BY WEEKS, FLIGHT NUMBER (CARRIER) AND DESTINATION
# count by delta weeks for each flight with same carrier and destination for each agent
data.q2.agent.byDeltaWeek <- data.q2.agent.unique %>%
  group_by(carrier, destination, weeks, agentName) %>%
  summarise(
    n = n()
  )

ggplot(data = data.q2.agent.byDeltaWeek, 
       aes(x = weeks, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity") +
  facet_grid(destination ~ agentName, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on departure weekday for each agent") +
  xlab("departure weekday") +
  ylab("number of cheapest flights")
SavePlot("q2-departure-weeks-agent.pdf")


