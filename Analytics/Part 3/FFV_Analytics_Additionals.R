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

data.lx316 <- data.flights.completeSeriesOnly %>%
  ungroup() %>%
  arrange(flightNumber, departureDate, requestDate) %>%
  group_by(flightNumber, departureDate, requestDate, origin, destination) %>%
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
    pcm = cummin(pmin),
    priceChangeRelBoolean = ifelse((pmin == lag(pmin, default = first(pmin))), 0, ifelse(pmin > lag(pmin, default = first(pmin)), 1, -1)),
    priceChangeAbsBoolean = ifelse((pmin == first(pmin)), 0, ifelse(pmin > first(pmin), 1, -1))
  )


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


write.csv(data.destinations, "data-destinations.csv", row.names = FALSE)
write.csv(data.destinations.condensed, "data-destinations-condensed.csv", row.names = FALSE)
write.csv(data.lx316, "data-lx316.csv", row.names = FALSE)
