# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Additional stuff.
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

data.destinations <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  group_by(
    destination, departureDate, departureTime
  ) %>%
  summarise(
    durationMin = min(duration),
    durationMax = max(duration)
  )

data.destinations <- data.destinations %>%
  ungroup() %>%
  group_by(
    destination, departureDate
  ) %>%
  summarise(
    flightsPerDay = n(),
    durationMin = min(durationMin), 
    durationMax = max(durationMax)
  )

destinationCodes <- c(
"AMS",
"BEG",
"BKK",
"BOM",
"DXB",
"GRU",
"ICN",
"IST",
"JFK",
"KEF",
"LHR",
"MAD",
"MLA",
"NRT",
"PEK",
"RHO",
"RIX",
"SIN",
"SVO",
"YYZ"
)

destinationNames <- c(
  "Amsterdam",
  "Belgrade",
  "Bangkok",
  "Bombay",
  "Dubai",
  "Sao Paolo",
  "Seoul",
  "Istanbul",
  "New York",
  "Reykjavik",
  "London",
  "Madrid",
  "Malta",
  "Tokyo",
  "Peking",
  "Rhode",
  "Riga",
  "Singapore",
  "Moscou",
  "Toronto"
)
destinations <- data.frame("destination" = destinationCodes, "destinationName" = destinationNames)

data.destinations <- left_join(data.destinations, destinations, by = "destination", copy = TRUE)

data.destinations.condensed <- data.destinations %>%
  ungroup() %>%
  group_by(
    destination, destinationName
  ) %>% summarise(
    n = n(),
    avgFlightsPerDay = round(mean(flightsPerDay), digits=1),
    durationMin = min(durationMin),
    durationMax = max(durationMax)
  ) %>% select (destination, destinationName, avgFlightsPerDay, durationMin, durationMax)

write.csv(data.destinations, "data-destinations.csv", row.names = FALSE)
write.csv(data.destinations.condensed, "data-destinations-condensed.csv", row.names = FALSE)


# -- data for LX316
data.lx316 <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%
  group_by(flightNumber, departureDate, requestDate, deltaTime, origin, destination, carrier) %>%
  filter(
    flightNumber == "LX316"
  ) %>%
  summarise(
    pmin = min(pmin)
  )

data.lx316 <- data.lx316 %>%
  ungroup() %>%
  group_by(flightNumber, departureDate) %>%
  mutate(
    priceChangeRel = pmin/lag(pmin, default = first(pmin)),
    priceChangeAbs = pmin/first(pmin),
    pr = dense_rank(pmin),
    bin = cut(pmin, 7),
    binRanked = cut(pmin, 7, labels=c(1,2,3,4,5,6,7)),
    priceChangeRelBoolean = ifelse((pmin == lag(pmin, default = first(pmin))), 0, ifelse(pmin > lag(pmin, default = first(pmin)), 1, -1)),
    priceChangeAbsBoolean = ifelse((pmin == first(pmin)), 0, ifelse(pmin > first(pmin), 1, -1))
  )

data.lx316 <- data.lx316 %>%
  ungroup() %>%
  group_by(origin, destination, flightNumber, departureDate, requestDate) %>%
  # select(origin, destination, flightNumber, departureDate, requestDate, deltaTime, pmin, priceChangeRel, priceChangeAbs, pr, pcm, priceChangeRelBoolean, priceChangeAbsBoolean) %>%
  arrange(origin, destination, flightNumber, departureDate, requestDate)

write.csv(data.lx316, "data-lx316.csv", row.names = FALSE)


# -- data for ALL
data.all <- FilterDataForDestination("ALL")
write.csv(data.all, "data-dest-all.csv", row.names = FALSE)

# -- data for every destination
for (destinationCode in destinationCodes){
  var.name <- paste("data.",tolower(destinationCode),sep="")
  var.filename <- sprintf("data-dest-%s.csv", tolower(destinationCode))
  
  assign(var.name, FilterDataForDestination(destinationCode))
  write.csv(var.name, var.filename, row.names = FALSE)
}



data.mad.small <- data.mad %>% filter( departureDate >= '2016-06-29', departureDate < '2016-07-02')
write.csv(data.mad.small, "data-dest-mad-small.csv", row.names = FALSE)

# -- plots for LX316

ggplot(data = data.lx316, 
       aes(x = requestDate, 
           y = priceChangeAbsBoolean
       )) + 
  geom_step(stat="identity") +
  facet_wrap(~ departureDate, ncol = 5, scales="free_y") + 
  ggtitle("LX316 (abs price change)") +
  xlab("request date") +
  ylab("+1 if higher, 0 if same, -1 if lower")
SavePlot("qx-lx316-change-rel.pdf")

ggplot(data = data.lx316, 
       aes(x = requestDate, 
           y = priceChangeRelBoolean
       )) + 
  geom_step(stat="identity") +
  facet_wrap(~ departureDate, ncol = 5, scales="free_y") + 
  ggtitle("LX316 (rel price change)") +
  xlab("request date") +
  ylab("+1 if higher, 0 if same, -1 if lower")
SavePlot("qx-lx316-change-abs.pdf")
