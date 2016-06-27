# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Frage 3) Wie viel Geld kann ich durchschnittlich sparen, wenn
#               ich zum richtigen Zeitpunkt buche?
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

# --- filter data
# filter lowest and highest prices for each flight
data.q3 <- data.flights.completeSeriesOnly %>% 
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%  # sorting 
  group_by(flightNumber, departureDate, agentName) %>%
  filter(
    pmin == min(pmin) | pmin == max(pmin)
  )

# --- make each lowest price unique
# if a price doesn't change for multiple days and it is the cheapest for this flights, 
# there are multiple rows for every request day with that cheap price in data.q2. 
# to avoid counting a destination-related row multiple times only one row is kept 
# (the first returning this cheap price).
data.q3.unique <- data.q3 %>%
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

# calculate difference between min and max price for each flight 
data.q3.diff <- data.q3.unique %>%
  ungroup() %>%
  group_by(flightNumber, carrier, origin, destination, 
           departureDate, departureTime, arrivalDate, arrivalTime, duration, departureWeekday,
           agentName) %>%
  summarise(
    n = n(),
    priceMin = min(pmin),
    priceMax = max(pmin)
  ) %>% mutate (
    priceDiffAbs = priceMax - priceMin,
    priceDiffRel = priceMin / priceMax,
    priceSaveRel = 1 - priceDiffRel
  )
### @Ueli: Es gibt Flüge, zb LX1412, welche am selben Tag mit derselben Flugnummer unterschiedliche Abflugszeiten
### eigentlich müsste hier die Anzahl doch die Hälfte von data.q3.unique sein, ist aber 1 mehr -> LX1412 hat bei n einmal 1


# for validation of some results ;)
PrintMinPrice(data.flights.completeSeriesOnly, "LX1416", "2016-06-15")
PrintMinPrice(data.flights.completeSeriesOnly, "KL1954", "2016-06-19")


viz.destination <- data.q3.diff %>%
  filter(
    destination == "LHR"
  )

# ggplot(viz.destination, aes(x = departureDate, y = priceSaveRel)) +
#   geom_point(shape=1)      # Use hollow circles


ggplot(data = viz.destination, 
       aes(x = departureDate, 
           y = priceSaveRel,
           shape = carrier)) + 
  geom_point() +
  # geom_smooth() + 
  facet_grid(agentName ~ flightNumber, labeller = global_labeller) + 
  ggtitle(sprintf("Price difference between min/max price per flight (%s)", viz.destination$destination)) +
  xlab("departure date") +
  ylab("price difference between min/max price in %")



# ggplot(data = viz.destination, 
#        aes(x = factor(departureDate), 
#            y = priceDiffAbs)) + 
#   geom_boxplot() +
#   facet_wrap(~ agentName, ncol = 5, labeller = global_labeller) + 
#   ggtitle(sprintf("Price difference between min/max price per flight (%s)", viz.destination$destination)) +
#   xlab("departure date") +
#   ylab("price difference between min/max price in %")





data.q3.sum <- data.q3.diff %>%
  group_by(carrier, origin, destination,
           departureDate, departureWeekday) %>%
  summarise(
    n = n(),
    v = var(priceSaveRel),
    s = sd(priceSaveRel)
  )



