# ══════════════════════════════════════════════════════════════════════════════
# ui.R
# ══════════════════════════════════════════════════════════════════════════════

library(bslib)

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

    # Main game layout — hidden until pregame is done
    conditionalPanel(
      condition = "!output.show_pregame",
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
      card(card_header("Test Your Knowledge"), card_body(mod_quiz_ui("quiz"))),
      card(
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