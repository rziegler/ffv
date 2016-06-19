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
  source("FFV_Analytics_Data.R")
}

# --- import horizon graph (flowing data)
if(!exists("horizonGraph", mode="function")) {
  source("horizon-graph.R")
}

# --- function definitions
PlotPricesPerWeekdays <- function(values, days) {
  values.filteredByDays <- values %>% 
    filter(
      departureWeekday %in% days
    ) %>%
    ungroup() %>%
    arrange(flightNumber, departureDate, requestDate) %>% 
    group_by(flightNumber, departureDate) %>% 
    mutate(
      n=n(), 
      deltaTimeInt = as.integer(deltaTime),
      priceChangeRel = pmin/lag(pmin), 
      priceChangeAbs = pmin/first(pmin), 
      pr = dense_rank(pmin), 
      pcm = cummin(pmin)
    )
  
  values.filteredByDays$priceChangeRel[is.na(values.filteredByDays$priceChangeRel)] <- 1
  
  # --- visualize price evolution (min price, absolute price change, relative price change)
  # min price
  plot.min <- ggplot(values.filteredByDays, aes(x=deltaTimeInt, y=pmin, shape=flightNumber, color=departureDate)) +
    geom_point() + 
    geom_line(aes(group=interaction(departureDate,flightNumber))) +
    ggtitle(sprintf("Min price (on %s) flight %s, n=%d", 
                    paste(unique(values.filteredByDays$departureWeekday), collapse = ", "), 
                    values.filteredByDays$destination, 
                    kSeriesLength)
    )
  # abs price
  plot.abs <- ggplot(values.filteredByDays, aes(x=deltaTimeInt, y=priceChangeAbs, shape=flightNumber, color=departureDate)) +
    geom_point() + 
    geom_line(aes(group=interaction(departureDate,flightNumber))) +
    ggtitle(sprintf("Abs price change (on %s) flight %s, n=%d", 
                    paste(unique(values.filteredByDays$departureWeekday), collapse = ", "), 
                    values.filteredByDays$destination, 
                    kSeriesLength)
    )
  # rel price
  plot.rel <- ggplot(values.filteredByDays, aes(x=deltaTimeInt, y=priceChangeRel, shape=flightNumber, color=departureDate)) +
    geom_point() + 
    geom_line(aes(group=interaction(departureDate,flightNumber))) +
    ggtitle(sprintf("Rel price change (on %s) flight %s, n=%d", 
                    paste(unique(values.filteredByDays$departureWeekday), collapse = ", "), 
                    values.filteredByDays$destination, 
                    kSeriesLength)
    )
  # print plots to PDF
  pdf(sprintf("%s-%d-%s.pdf", 
              values.filteredByDays$destination, 
              kSeriesLength, 
              paste(unique(values.filteredByDays$departureWeekday), collapse = "-"))
  )
  multiplot(plot.min, plot.abs, plot.rel, cols=1)
  dev.off()
}

# prefilter for visualization
viz.data <- data.flights.completeSeriesOnly %>%
  filter(
    agentName=="eDreams"
  )

viz.test <- viz.data %>%
  filter(
    # flightNumber == "LX316"
    destination == "MAD"
    # carrier == "TG"
    #departureDayAsDate > "2016-06-01",
    #departureDayAsDate < "2016-08-30"
    #departureDay %in% c("27.06.2016", "28.06.2016")
  )
  
PlotPricesPerWeekdays(viz.test, c("Do"))
PlotPricesPerWeekdays(viz.test, c("Mo", "Di", "Mi", "Do", "Fr"))
PlotPricesPerWeekdays(viz.test, c("Sa", "So"))