# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Frage 0) An welchem Wochentag soll ich buchen? (requestDate)
#
#               WICHTIG: Wenn ein günstigster Preis von einem Anbieter über 
#               mehrere Tage konstant ist, dann werden alle Tage berücksichtigt. 
#               Dies führt dazu, dass ein Abflugtag mehrmals "gezählt" wird. Da
#               in dieser Auswertung nur der Abfragetag (requestDate) eine Rolle
#               spielt, ist dies in Ordnung.
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

# filter lowest prices for each flight
data.q0 <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate) %>%
  filter(
    pmin == min(pmin)
  )

# -- BY REQUEST WEEKDAY, DESTINATION AND CARRIER
# count by request weekday, destination AND carrier
data.q0.byRequestWeekday <- data.q0 %>%
  ungroup() %>%
  group_by(requestWeekday, carrier, destination) %>%
  summarise(
    n = n()
  )

# plot cheapest flights distributed by request weekday for each destination and carrier
ggplot(data = data.q0.byRequestWeekday, 
       aes(x = requestWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity") +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on request weekday overall") +
  xlab("request weekday") +
  ylab("number of cheapest flights")
SavePlot("q0-request-wday-all.pdf")

ggplot(data = data.q0.byRequestWeekday, 
       aes(x = requestWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity", position = "dodge") +
  facet_wrap(~ destination, ncol = 5, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on request weekday overall") +
  xlab("request weekday") +
  ylab("number of cheapest flights")
SavePlot("q0-request-wday-all-2.pdf")

# calculate the mode value for request weekday
# data.q0.mode <- mfv(as.numeric(data.q0$requestWeekday))

# same as above but additionally grouped by agent
data.q0.agent <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, agentName, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate, agentName) %>%
  filter(
    pmin == min(pmin)
  )

# -- BY REQUEST WEEKDAY, DESTINATION AND AGENT
# count by request weekday and destination for each agent
data.q0.agent.byRequestWeekday <- data.q0.agent %>%
  group_by(requestWeekday, carrier, destination, agentName) %>%
  summarise(
    n = n()
  )

ggplot(data = data.q0.agent.byRequestWeekday, 
       aes(x = requestWeekday, 
           y = n,
           fill = carrier)) + 
  geom_bar(stat="identity") +
  facet_grid(destination ~ agentName, scales="free_y", labeller = global_labeller) + 
  ggtitle("Number of cheapest flights on request weekday for each agent") +
  xlab("request weekday") +
  ylab("number of cheapest flights")
SavePlot("q0-request-wday-agent.pdf")

write.csv(data.q0.byRequestWeekday, "data-q0-request-wday-all.csv", row.names = FALSE)
write.csv(data.q0.agent.byRequestWeekday, "data-q0-request-wday-agent.csv", row.names = FALSE)
