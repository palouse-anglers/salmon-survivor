# ══════════════════════════════════════════════════════════════════════════════
# ui.R
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

source("config/mortality_rates.R")
source("data/sites.R")
source("data/hotspots.R")
source("data/questions.R")
source("R/utils.R")
source("R/parse_data.R")
source("R/simulate_cohort.R")
source("modules/mod_cohort.R")
source("modules/mod_map.R")
source("modules/mod_mortality.R")
source("modules/mod_ocean.R")
source("modules/mod_results.R")
source("modules/mod_quiz.R")
source("modules/mod_pregame_quiz.R")
source("modules/mod_intro_video.R")

# ── YouTube intro video URL — change this to update the video ─────────────
# ── Video URLs ────────────────────────────────────────────────────────────────
INTRO_VIDEO_URL      <- "https://youtu.be/HxlAsTCAp4w?feature=shared"
CORMORANT_VIDEO_URL  <- "https://www.dvidshub.net/video/embed/349996"
DAM_VIDEO_URL        <- "https://www.pbs.org/video/nature-education-extreme-measures/"
ADULT_VIDEO_URL      <- "https://www.youtube.com/embed/DhdPjh69jdM?si=DPgrUAOepHIFUSAL"

ui <- page_navbar(
  title        = tags$span("\U0001f41f Salmon Survivor"),
  window_title = "Salmon Survivor",
  header       = shinyjs::useShinyjs(),
  theme = bs_theme(
    bg           = "#0a1628",
    fg           = "#e8f4fd",
    primary      = "#4fc3f7",
    success      = "#2d8a4e",
    danger       = "#c0392b",
    base_font    = font_google("Inter"),
    heading_font = font_google("Inter")
  ),

  # ── PLAY TAB ───────────────────────────────────────────────────────────────
  nav_panel("\U0001f3ae Play",

    # Pre-game welcome screen — shown before game starts
    conditionalPanel(
      condition = "output.show_pregame",
      mod_pregame_quiz_ui("pregame")
    ),

    # Intro video — after difficulty selection, before game
    conditionalPanel(
      condition = "output.show_intro_video",
      mod_intro_video_ui("intro_video", INTRO_VIDEO_URL)
    ),

    # Dam video — plays before the first dam event
    conditionalPanel(
      condition = "output.show_dam_video",
      mod_intro_video_ui(
        "dam_video",
        DAM_VIDEO_URL,
        title   = "\U0001f6a7 Running the Gauntlet — Dams on the Columbia",
        btn_lbl = "\u23ed\ufe0f Skip \u2192 Continue"
      )
    ),

    # Cormorant predation video — plays before the first cormorant event
    conditionalPanel(
      condition = "output.show_cormorant_video",
      mod_intro_video_ui(
        "cormorant_video",
        CORMORANT_VIDEO_URL,
        title   = "\U0001f426 Avian Predation at the Columbia River",
        btn_lbl = "\u23ed\ufe0f Skip \u2192 Continue"
      )
    ),

    # Adult return video — plays when Begin Adult Return is clicked
    conditionalPanel(
      condition = "output.show_adult_video",
      mod_intro_video_ui(
        "adult_video",
        ADULT_VIDEO_URL,
        title   = "\U0001f420 The Adult Return Journey",
        btn_lbl = "\u23ed\ufe0f Skip \u2192 Continue"
      )
    ),

    # Main game layout
    conditionalPanel(
      condition = paste(
        "!output.show_pregame &&",
        "!output.show_intro_video &&",
        "!output.show_dam_video &&",
        "!output.show_cormorant_video &&",
        "!output.show_adult_video"
      ),
      layout_columns(
        col_widths = c(4, 8),

        # -- Left panel
        div(
          mod_cohort_ui("cohort"),
          uiOutput("start_flavor"),
          uiOutput("pregame_summary"),
          card(card_body(padding="12px",
            uiOutput("game_controls")
          )),
          uiOutput("ocean_card"),
          uiOutput("next_stop_btn"),
          uiOutput("show_results")
        ),

        # -- Right panel - map
        card(
          card_header(uiOutput("map_header")),
          card_body(padding=0,
            mod_map_ui("map")
          )
        )
      ),

      # Mortality modal
      mod_mortality_ui("mortality")
    )
  ),

  # ── QUIZ TAB ───────────────────────────────────────────────────────────────
  nav_panel("\U0001f9e0 Quiz",
    layout_columns(
      col_widths = c(7, 5),
      card(
        style = "background-color: #0a1628; color: #e8f4fd; border: 1px solid #1e3a5f;",
        card_header("Test Your Knowledge"),
        card_body(mod_quiz_ui("quiz"))
      ),
      card(
        style = "background-color: #0a1628; color: #e8f4fd; border: 1px solid #1e3a5f;",
        card_header("Key Facts"),
        card_body(
          tags$dl(
            tags$dt("SAR — Smolt-to-Adult Return"),
            tags$dd("% of smolts returning as adults. Need 2% to survive, 4\u20136% to recover."),
            tags$dt("Walla Walla Basin (your real data)"),
            tags$dd("500 released \u2192 5 returned to Bonneville \u2192 1 reached Nursery Bridge."),
            tags$dt("6PPD-quinone"),
            tags$dd("Tire chemical that kills coho on contact. Washes off roads in first rain. Identified 2020."),
            tags$dt("Pikeminnow Bounty"),
            tags$dd("Program pays anglers per pikeminnow caught. One fish can eat 800 smolts/season."),
            tags$dt("Avian Predation"),
            tags$dd("7 bird kills vs 7 estuary detections in your data — birds ate as many fish as made it past the estuary.")
          )
        )
      )
    )
  ),

  # ── ABOUT TAB ──────────────────────────────────────────────────────────────
  nav_panel("\u2139\ufe0f About",
    card(card_body(
      h4("About Salmon Survivor"),
      p("Real PIT tag data from 500 juvenile steelhead released from the
         Walla Walla Basin in 2024. One fish made it home."),
      h5("Migration Route"),
      tags$ol(
        tags$li("South Fork Walla Walla / Burlingame / Nursery Bridge (random start)"),
        tags$li("Lower Walla Walla River — bass predation"),
        tags$li("Crescent Island — avian predation"),
        tags$li("Lake Wallula — mixed predation"),
        tags$li("McNary Dam"),
        tags$li("Blalock Islands — tern colony"),
        tags$li("Lake Umatilla — reservoir predation"),
        tags$li("John Day Dam"),
        tags$li("Miller Rocks — gull colony"),
        tags$li("Lake Celilo — pikeminnow/bass"),
        tags$li("The Dalles Dam"),
        tags$li("Lake Bonneville — reservoir predation"),
        tags$li("Bonneville Dam"),
        tags$li("Columbia Estuary \u2192 Pacific Ocean"),
        tags$li("Adult return gauntlet \u2192 Home")
      ),
      h5("Data Sources"),
      tags$ul(
        tags$li("PIT tag data: PTAGIS (ptagis.org)"),
        tags$li("Predation hotspots: PIT tag recoveries at bird colonies, Walla Walla Basin"),
        tags$li("SAR data: Fish Passage Center / NOAA Fisheries")
      ),
      h5("Credits"),
      p("Built with R Shiny. Death screen artwork by [Artist Name].")
    ))
  )
)