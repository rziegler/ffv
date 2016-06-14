###############################################
# Global settings (include in every script)

# set locale to UTF-8
Sys.setlocale("LC_ALL", "de_CH.UTF-8")
# set working directory
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/")

###############################################


dateFromMillis <- function(millis) {
  if(!is.numeric.POSIXt(millis)) {
    date <- as.POSIXct(millis/1000, origin = "1970-01-01")
    return (date)
  } else {
    return (millis)
  }
}

dateFromMillis2 <- function(millisList) {
  return (lapply(millisList, dateFromMillis))
}

readFlights <- function() {
  return ("a")
}

readFlight <- function(flightNumber) {
  #install.packages("jsonlite", "curl")
  #install.packages("curl")
  library(jsonlite)
  flightNumber <- "LX316"
  url <- paste("http://ffv.threeit.ch/ffv/resources/api/flight/",flightNumber, sep="")
  raw <- fromJSON(url)
  #raw$carrier <- as.factor(raw$carrier)
  #raw$number <- as.factor(raw$number)
  #raw$departureDate <- dateFromMillis(raw$departureDate)
  #raw$arrivalDate <- dateFromMillis(raw$arrivalDate)
  #raw$fares[[1]]$date <- dateFromMillis2(raw$fares[[1]]$date) # ???
  return (raw)
}

# -------------------------------------------

date <- dateFromMillis(1462913594747)
class(date)
flight <- readFlight("LX316")
head(flight)


# ----

data1 <- fromJSON("http://ffv.threeit.ch/ffv/resources/api/flight/LX316")
colnames(data1)
colnames(data1$fares[[1]])

class(data1$fares[[1]])
test <- lapply(data1$fares, function(x) 
  lapply(x, function(y) y))
#df <- data.frame(matrix(unlist(test), nrow=20, byrow=T))

one <- matrix(unlist(test[1]), ncol=6, byrow=T)

x <- c(1,2,3)
y <- lapply(x, function(i) i+1)


colnames(data1$fares[[1]]$agent)
colnames(data1$fares[[1]])
colnames(flatten(data1))

faredata <- NULL
for(i in 1:5) {
  temp <- cbind(data1$fares[[i]][,c("date","price")],data1$fares[[i]]$agent$name,i)
  names(temp) <-c("date","price","agentname")
  faredata <- rbind(faredata, temp)
}


