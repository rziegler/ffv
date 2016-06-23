# ---------------------------------------------------------------------------- #
# CAS DATA VISUALIZATION 2016
# Autorenprojekt Flight Fare Visualization
#
# Description   Datenbereinigung und -aufbereitung der gesammelten Flugpreise
#               zu 20 Flugverbindungen (EU sowie Oversea).
#
#               Base for all FFV_Analytics_Qx.R scripts
#
# Autor         Ruth Ziegler
# Date          2016-06-21
# Version       v1.0
# ---------------------------------------------------------------------------- #

# --- global settings (include in every script)
Sys.setlocale("LC_ALL", "de_CH.UTF-8")  # set locale to UTF-8
setwd("/Users/ruthziegler/Documents/Work/CAS Data Visualization/Flight Fare Visualization/Analytics/Part 3")

# --- import base script if not sourced
if(!exists("data.flights.completeSeriesOnly")) {
  source("FFV_Analytics_Data.R")
}

# --- define a global labeller used in all faceting plots
destinationLabels <- c(
  AMS = "Amsterdam (AMS)",
  BEG = "Belgrade (BEG)",
  BKK = "Bangkok (BKK)",
  BOM = "Bombay (BOM)",
  DXB = "Dubai (DXB)",
  GRU = "Sao Paolo (GRU)",
  ICN = "Seoul (ICN)",
  IST = "Istanbul (IST)",
  JFK = "New York (JFK)",
  KEF = "Reykjavik (KEF)",
  LHR = "London (LHR)",
  MAD = "Madrid (MAD)",
  MLA = "Malta (MLA)",
  NRT = "Tokyo (NRT)",
  PEK = "Peking (PEK)",
  RHO = "Rhode (RHO)",
  RIX = "Riga (RIX)",
  SIN = "Singapore (SIN)",
  SVO = "Moscou (SVO)",
  YYZ = "Toronto (YYZ)"
)

global_labeller <- labeller(
  destination = destinationLabels,
  agentName = label_wrap_gen(10),
  flightNumber = label_wrap_gen(10),
  .default = label_both
)
