# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Weitere Visualisierungen.
#
# Autor         Ruth Ziegler
# Date          2016-06-14
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 3")

# --- import base script if not sourced
if(!exists("data.flights.completeSeriesOnly")) {
  source("FFV_Analytics_Data_02.R")
}

# --- import horizon graph (flowing data)
if(!exists("horizonGraph", mode="function")) {
  source("horizon-graph.R")
}

# prefilter for visualization
viz.data <- data.flights.completeSeriesOnly %>%
  filter(
    agentName=="eDreams"
  )

viz.test <- viz.data %>%
  mutate(
    requestDayAsDate = as.Date(strptime(requestDay, "%d.%m.%Y")),
    departureDayAsDate = as.Date(strptime(departureDay, "%d.%m.%Y"))
  ) %>%
  filter(
    flightNumber == "LX316"
    #destination == "BKK",
    #carrier == "TG",
    #departureDayAsDate > "2016-06-01",
    #departureDayAsDate < "2016-08-30"
    #departureDay %in% c("27.06.2016", "28.06.2016")
  )
  
viz.test.x <- viz.test %>% 
  # mutate(requestDayAsDate = as.Date(strptime(requestDay, "%d.%m.%Y"))) %>%
  mutate(
    rank2 = dense_rank(deltaTime)
  ) %>%
  filter(
    departureWeekday %in% c("Mo")
    # departureWeekday %in% c("Mo", "Di", "Mi", "Do", "Fr")
    # departureWeekday %in% c("Sa", "So")
    #departureWeekday %in% c("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So")
  ) %>%
  ungroup() %>%
  arrange(flightNumber, departureDay, requestDayAsDate) %>% 
  group_by(flightNumber, departureDay) %>% 
  mutate(n=n(), priceChangeRel = pmin/lag(pmin), priceChangeAbs = pmin/first(pmin), pr = dense_rank(pmin), pcm = cummin(pmin))

viz.test.x$priceChangeRel[is.na(viz.test.x$priceChangeRel)] <- 1

# --- visualize price evolution of some randomly selected flights

#par(mfrow=c(3,1), mar=c(1,0,0.8,0))
# min price
plot.min <- ggplot(viz.test.x, aes(x=rank2, y=pmin, group=departureDay, color=departureDay)) +
  geom_line() +
  ggtitle(sprintf("Min price (on %s)", paste(unique(viz.test.x$departureWeekday), collapse = ", ")))
# abs price
plot.abs <- ggplot(viz.test.x, aes(x=rank2, y=priceChangeAbs, group=departureDay, color=departureDay)) +
  geom_line() +
  ggtitle(sprintf("Abs price (on %s)", paste(unique(viz.test.x$departureWeekday), collapse = ", ")))
# rel price
plot.rel <- ggplot(viz.test.x, aes(x=rank2, y=priceChangeRel, group=departureDay, color=departureDay)) +
  geom_line() +
  ggtitle(sprintf("Rel price (on %s)", paste(unique(viz.test.x$departureWeekday), collapse = ", ")))


multiplot(plot.min, plot.abs, plot.rel, cols=1)
