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
    n = n()
  ) %>% select (destination, destinationName)

write.csv(data.destinations, "data-destinations.csv", row.names = FALSE)
write.csv(data.destinations.condensed, "data-destinations-condensed.csv", row.names = FALSE)
