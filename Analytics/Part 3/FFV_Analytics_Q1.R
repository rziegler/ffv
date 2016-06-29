# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Frage 1) An welchem Wochentag soll ich abfliegen? (departureDate)
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

# filter data

# --- constants for calculating complete weeks buckets
kEarliestDepartureDate <- min(data.flights.completeSeriesOnly$departureDate)
kLatestDepartureDate <- max(data.flights.completeSeriesOnly$departureDate)


# --- calculate the offset to shift the departure date so that it "starts" on a monday for the grouping afterwards
# --- ISO week starts on monday, wday from POSIXlt start on sunday with 0, monday is 1, ... saturday is 5
kWeekdayShiftOffset <- (as.POSIXlt(kEarliestDepartureDate)$wday-1)%%7 # since wday is 0-based subtract 1, mod 7 for staying between 0..6

# --- filter lowest prices for each flight
data.q1 <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    pmin == min(pmin)
  ) %>% mutate(
    # shift the departure date so that it "starts" on a monday for the grouping afterwards
    # -- ISO week starts on monday, wday from POSIXlt start on sunday with 0, monday is 1, ... saturday is 5
    kw = ISOweek(as.IDate(departureDate-kWeekdayShiftOffset))
  )

# --- make each lowest price unique
# if a price doesn't change for multiple days and it is the cheapest for this flights, 
# there are multiple rows for every request day with that cheap price in data.q2. 
# to avoid counting a destination-related row multiple times only one row is kept 
# (the first returning this cheap price).
data.q1.unique <- data.q1 %>%
  ungroup() %>%
  group_by(flightNumber, carrier, origin, destination, 
           departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday, pmin, kw) %>%
  arrange(flightNumber, departureDate, departureTime, agentName, requestDate) %>%
  summarise(
    requestDate = first(requestDate),  # keep the first #### TODO it could be that if I have mutliple cheapest prices, they are not in the same week
    requestWeekday = first(requestWeekday),
    deltaTime = first(deltaTime),
    agentName = first(agentName),
    agentType = first(agentType)
  )

# filter dates which are not in a complete week
departureDateDiff <- as.numeric(kLatestDepartureDate - kEarliestDepartureDate)
rightBoundDate <- kLatestDepartureDate - ((departureDateDiff + 1) %% 7)

data.q1.completeWeeksOnly <- data.q1.unique %>%
  ungroup() %>%
  group_by(flightNumber, departureDate) %>%
  filter(
    departureDate <=rightBoundDate
  )

# -- CHEAPEST FLIGHTS BY DEPARTURE WEEKDAY, CARRIER AND DESTINATION
# only keep flights for each kw, carrier and destination with minimal price
data.q1.minByCalendarWeek <- data.q1.completeWeeksOnly %>%
  ungroup() %>%
  arrange(carrier, destination, kw, pmin) %>%
  group_by(carrier, destination, kw) %>%
  filter(
    pmin == first(pmin)
  )

# count by departure weekday within each carrier, destination (skip the kw here, because all weeks are joined)
data.q1.minByCalendarWeekCounted <- data.q1.minByCalendarWeek %>%
  ungroup() %>%
  group_by(carrier, destination, departureWeekday) %>%
  summarise(
    n = n()
  )

# plot cheapest flights distributed by request weekday for each destination
ggplot(data = data.q1.minByCalendarWeekCounted, 
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

ggplot(data = data.q1.minByCalendarWeekCounted, 
       aes(x = departureWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity", position = "dodge") +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on departure weekday overall") +
  xlab("departure weekday") +
  ylab("number of cheapest flights")
SavePlot("q1-departure-wday-all-2.pdf")



# -- MOST EXPENSIVE PRICES BY DEPARTURE WEEKDAY, CARRIER AND DESTINATION
# only keep flights for each kw, carrier and destination with maximal price
data.q1.maxByCalendarWeek <- data.q1.completeWeeksOnly %>%
  ungroup() %>%
  arrange(carrier, destination, kw, pmin) %>%
  group_by(carrier, destination, kw) %>%
  filter(
    pmin == last(pmin)
  )

# count by departure weekday within each carrier, destination (skip the kw here, because all weeks are joined)
data.q1.maxByCalendarWeekCounted <- data.q1.maxByCalendarWeek %>%
  ungroup() %>%
  group_by(carrier, destination, departureWeekday) %>%
  summarise(
    n = n()
  )

# plot cheapest flights distributed by request weekday for each destination
ggplot(data = data.q1.maxByCalendarWeekCounted, 
       aes(x = departureWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity") +
  # annotate("text", x=3, y=10, label = sprintf("n=%s", data)) + 
  # geom_text(aes(label = n, y = pos), size = 3) +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of most expensive flights on departure weekday overall") +
  xlab("departure weekday") +
  ylab("number of most expensive flights")
SavePlot("q1-departure-wday-max-price-all.pdf")

ggplot(data = data.q1.maxByCalendarWeekCounted, 
       aes(x = departureWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity", position = "dodge") +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of most expensive flights on departure weekday overall") +
  xlab("departure weekday") +
  ylab("number of most expensive flights")
SavePlot("q1-departure-wday-max-price-all-2.pdf")



# for validation of some results ;)
# PrintMinPrice(data.flights.completeSeriesOnly, "LX332", "2016-06-01")


# same as above but additionally grouped by agent

## DOES IT MAKE SENSE HERE???? I THINK NOT AT THE MO


# data.q1.agent <- data.flights.completeSeriesOnly %>%
#   ungroup() %>%
#   arrange(flightNumber, departureDate, agentName, requestDate) %>%  # sorting 
#   group_by(flightNumber, departureDate, agentName) %>%
#   filter(
#     pmin == min(pmin)
#   )
# 
# # --- make each lowest price unique
# data.q1.agent.unique <- data.q1.agent %>%
#   ungroup() %>%
#   group_by(flightNumber, carrier, origin, destination, 
#            departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday, pmin) %>%
#   arrange(flightNumber, departureDate, departureTime, agentName, requestDate) %>%
#   summarise(
#     requestDate = first(requestDate),  # keep the first
#     requestWeekday = first(requestWeekday),
#     deltaTime = first(deltaTime),
#     agentName = first(agentName),
#     agentType = first(agentType)
#   )
# 
# # count by departure weekday for each flight with same carrier for each agent
# data.q1.agent.byDepartureWeekday <- data.q1.agent.unique %>%
#   group_by(carrier, departureWeekday, destination, agentName) %>%
#   summarise(
#     n = n()
#   )
# 
# ggplot(data = data.q1.agent.byDepartureWeekday, 
#        aes(x = departureWeekday, 
#            y = n,
#            fill = carrier)) + 
#   geom_bar(stat="identity") +
#   facet_grid(destination ~ agentName, scales="free_y", labeller = global_labeller) + 
#   ggtitle("Number of cheapest flights on departure weekday for each agent") +
#   xlab("departure weekday") +
#   ylab("number of cheapest flights")
# SavePlot("q1-departure-wday-agent.pdf")
