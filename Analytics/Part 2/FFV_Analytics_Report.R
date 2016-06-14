# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Visualisierungen der Tidy Daten um die Aussagekraft der Daten
#               zu prüfen.
#
# Autor         Ruth Ziegler
# Date          2016-06-01
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 2")

# --- import base script if not sourced
if(!exists("data.flights.grouped")) {
  source("FFV_Analytics_Data.R")
}

# prefilter for visualization
viz.data <- data.flights.grouped %>%
  filter(
    agentName=="eDreams") %>%
  select(-p1, -p2, -p3, -p4)

# --- visualize price evolution of some randomly selected flights
# parameters for the plot
viz.flightNumber <- c("LX316", "LX1804", "LX1804", "TK1914", "AI7702", "NH6752")
viz.departureDay <- c("28.07.2016", "29.07.2016", "30.07.2016", "14.07.2016", "15.07.2016", "10.08.2016")

pdf(file="ffv-reports-01.pdf", onefile = TRUE)
for(i in 1:length(viz.flightNumber)) {
  # print(viz.flightNumber[i])
  viz.data.flightNumber <- viz.data %>%
    filter(flightNumber==viz.flightNumber[i])
  # transform to date object for plotting on x-axis
  viz.data.flightNumber$requestDay <- as.Date(strptime(viz.data.flightNumber$requestDay, "%d.%m.%Y"))  
  
  for(j in 1:length(viz.departureDay)) {
    #print(viz.departureDay[j])
    viz.data.flightNumber.byDepartureDay <- viz.data.flightNumber %>%
      filter(departureDay==viz.departureDay[j])

    print(  # use print inside for-loops to ggplot object
      ggplot(viz.data.flightNumber.byDepartureDay, aes(x=requestDay, y=pmedian)) +
        geom_line() +
        ggtitle(sprintf(
          "Preisentwicklung eines Fluges nach Anfragedatum\n(%s am %s, %s um %s)",
          viz.data.flightNumber.byDepartureDay$flightNumber, viz.data.flightNumber.byDepartureDay$departureWeekday,
          viz.data.flightNumber.byDepartureDay$departureDay, viz.data.flightNumber.byDepartureDay$departureTime
        ))
    )
  }
}
dev.off()

# --- visualize price evolution of all flights over a period of time
# add a column for the grouping in the plot
viz.data.group <- viz.data %>%
  mutate(
    vizGroup=paste(flightNumber,departureDay,departureTime, sep="-")
  )

# parameters for the plot
viz.destination <- c("LHR", "AMS", "DXB")
viz.weekday <- list(c("Di"), c("Fr"), c("Sa", "So"))
viz.departureFrom <- c("2016-06-01")
viz.departureTo <- c("2016-08-30")

pdf(file="ffv-reports-02.pdf", onefile = TRUE)
for(i in 1:length(viz.destination)) {
  viz.data.destination <- viz.data.group %>%
    filter(destination==viz.destination[i])
  
  for(j in 1:length(viz.weekday)) {
    print(i)
    print(j)
    viz.data.destination.byWeekday <- viz.data.destination %>%
      filter(departureWeekday %in% viz.weekday[[j]])
    
    # transform to date object for filtering by time period and plotting on x-axis respectively
    viz.data.destination.byWeekday$departureDay <- as.Date(strptime(viz.data.destination.byWeekday$departureDay, "%d.%m.%Y"))
    viz.data.destination.byWeekday$requestDay <- as.Date(strptime(viz.data.destination.byWeekday$requestDay, "%d.%m.%Y"))
    
    # filter by time period
    viz.data.destination.byWeekday <- with(viz.data.destination.byWeekday, 
                                           viz.data.destination.byWeekday[(departureDay >= viz.departureFrom[1] & departureDay <= viz.departureTo[1]), ])
    
    print(  # use print inside for-loops to ggplot object
      ggplot(viz.data.destination.byWeekday, aes(x=requestDay, y=pmedian, group=vizGroup, color=carrier)) + 
        geom_line() + 
        ggtitle(sprintf(
          "Preisentwicklung nach Anfragedatum\n(ZHR-%s, am %s mit Abflug zwischen %s und %s)",
          viz.data.destination.byWeekday$destination, viz.weekday[j],
          viz.departureFrom[1], viz.departureTo[1]
        ))
    )
  }
}
dev.off()
