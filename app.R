# ══════════════════════════════════════════════════════════════════════════════
# app.R — Entry point. Sources all modules and runs the app.
# To run: shiny::runApp("salmon-survivor/")
# ══════════════════════════════════════════════════════════════════════════════

library(shiny)
library(bslib)
library(leaflet)
library(dplyr)
library(lubridate)
library(readr)
library(janitor)
library(xml2)
library(purrr)
library(tibble)
library(shinyjs)

# ── Config (tune game difficulty here) ───────────────────────────────────────
source("config/mortality_rates.R")

# ── Site metadata ─────────────────────────────────────────────────────────────
source("data/sites.R")
source("data/hotspots.R")

# ── Helpers and engines ───────────────────────────────────────────────────────
source("R/utils.R")
source("R/parse_data.R")
source("R/simulate_cohort.R")

# ── Shiny modules ─────────────────────────────────────────────────────────────
source("modules/mod_cohort.R")
source("modules/mod_map.R")
source("modules/mod_mortality.R")
source("modules/mod_ocean.R")
source("modules/mod_results.R")
source("modules/mod_quiz.R")

# ── UI and Server ─────────────────────────────────────────────────────────────
source("ui.R")
source("server.R")

shinyApp(ui, server)