###############################################
# Global settings (include in every script)

# set locale to UTF-8
Sys.setlocale("LC_ALL", "de_CH.UTF-8")
# set working directory
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/
       Flight Fare Visualization/Analytics/")

###############################################

DateFromMillis <- function(millis) {
  # Converts the given date from millis into a POSIXct date object. If the given
  # date is already a POSIXct date, then it is returned unchanged.
  # 
  # Args:
  #   millis: The date (including time) in milliseconds.
  #
  # Returns:
  #   The converted date in POSIXct format.
  if(is.numeric.POSIXt(millis)) {
    return (millis)
  } else {
    date <- as.POSIXct(millis/1000, origin = "1970-01-01")
    return (date)
  }
}

dateFromMillis2 <- function(millisList) {
  return (lapply(millisList, DateFromMillis))
}

# ---create the data structure----------------------------------------

# import libraries
#install.packages("RNeo4j", "dplyr")
library(RNeo4j)
library(dplyr)

# read data from neo4j
# IMPORTANT: Start neo4j console first!!!!!
graph = startGraph("http://localhost:7474/db/data/", username="neo4j", password="ffv")
raw <- cypher(graph, "MATCH (f:Flight) --> (n:FlightDate) --> (p:Price) 
              RETURN p.price, p.date, p.requestDaytime, n.arrivalDate, n.departureDate, n.duration, f.flightNumber, f.origin, f.destination")

# rename columns
names(raw) <- c("price", "requestDate", "requestDaytime", "arrival", "departure", "duration", "flightNumber", "origin", "destination")

# transform data types
raw$origin<- as.factor(raw$origin)
raw$destination <- as.factor(raw$destination)
raw$flightNumber <- as.factor(raw$flightNumber)
raw$requestDate <- DateFromMillis(raw$requestDate)
raw$arrival <- DateFromMillis(raw$arrival)
raw$departure <- DateFromMillis(raw$departure)
raw$price <- as.double(raw$price)

# calculate new columns
# TODO check if rounding of days is correct! otherwise create new date object without time information and use difftime then
flightData <- raw %>% 
  mutate(
    deltaTime=(round(difftime(raw$departure, raw$requestDate, units = c("days")),0)),
    departureTime=(strftime(departure, format="%H:%M:%S"))
  )

# remove absolute date rows (requestDate, arrival, departure)
flightData <- flightData %>% select(price, requestDaytime, duration, flightNumber, origin, destination, deltaTime, departureTime)
head(flightData)

# ---calculate statistics----------------------------------------
zrhLhr <- flightData %>% 
  filter(origin=="ZRH", destination=="LHR", requestDaytime!="UNKNOWN") %>%
  group_by(deltaTime) %>%
  summarise(priceMedian=median(price), priceMean=mean(price), n=n()) %>% # aggregieren
  ungroup() %>% # to be save, if executed multiple times :)
  arrange(priceMedian)
zrhLhr

all <- flightData %>% 
  filter(requestDaytime!="UNKNOWN") %>%
  group_by(deltaTime, origin, destination) %>%
  summarise(priceMedian=median(price), priceMean=mean(price), priceMin=min(price), priceMax=max(price), n=n()) %>% # aggregieren
  ungroup() %>% # to be save, if executed multiple times :)
  arrange(origin, destination, -deltaTime, priceMedian)
all

# TODO weitermachenn ;) jetzt noch das min suchen innerhalb einer verbindung (ZRH-AMS) und soweiter

write.csv(all, "all_flights.csv")

# 
destinations <- cypher(graph, "MATCH (f:Flight) RETURN DISTINCT f.destination ORDER BY f.destination")

list_dest <- split(all, all$destination) #split the dataset into a list of datasets based on the value of all$destination
#list2env(list_dest, envir= .GlobalEnv) #split the list into separate datasets

for (i in 1:length(list_dest)) {
  #assign(new_names[i], iris_split[[i]])
  tmp <- destinations[i]
  #filteredForDestination <- all %>%
  #  filter(destination=tmp) %>%
  #  summarise(priceMin=min(price), priceMax=max(price))%>% # aggregieren
  #  ungroup() %>% # to be save, if executed multiple times :)
  #  arrange(origin, destination, priceMedian)
  #filteredForDestination
  print(tmp)
}


for (d in destinations){
  #print(paste("The destination is", d))
  tmp <- d
  
  filteredForDestination <- all %>%
    filter(destination=tmp) %>%
    summarise(priceMin=min(price), priceMax=max(price))%>% # aggregieren
    ungroup() %>% # to be save, if executed multiple times :)
    arrange(origin, destination, priceMedian)
  filteredForDestination
}






