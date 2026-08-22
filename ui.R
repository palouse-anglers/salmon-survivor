# ══════════════════════════════════════════════════════════════════════════════
# ui.R
# ══════════════════════════════════════════════════════════════════════════════

ui <- page_navbar(
  title = tags$span(
    "🐟 Salmon Survivor"
  ),
  theme = bs_theme(
    bg           = "#0a1628",
    fg           = "#e8f4fd",
    primary      = "#4fc3f7",
    success      = "#2d8a4e",
    danger       = "#c0392b",
    base_font    = font_google("Inter"),
    heading_font = font_google("Inter")
  ),
  window_title = "Salmon Survivor",

  # ── GAME TAB ───────────────────────────────────────────────────────────────
  nav_panel("🎮 Play",
    layout_columns(
      col_widths = c(4, 8),

      # Left panel — cohort counter + controls + death screen
      div(
        mod_cohort_ui("cohort"),

        card(
          card_body(
            padding = "12px",
            uiOutput("station_info"),
            hr(),
            uiOutput("game_controls")
          )
        ),

        div(style = "margin-top: 10px;",
          mod_mortality_ui("mortality")
        ),

        div(style = "margin-top: 10px;",
          mod_ocean_ui("ocean")
        ),

        div(style = "margin-top: 10px;",
          mod_results_ui("results")
        )
      ),

      # Right panel — map
      card(
        card_header(uiOutput("map_header")),
        card_body(padding = 0,
          mod_map_ui("map")
        )
      )
    )
  ),

  # ── QUIZ TAB ───────────────────────────────────────────────────────────────
  nav_panel("🧠 Quiz",
    layout_columns(
      col_widths = c(7, 5),
      card(
        card_header("Test Your Knowledge"),
        card_body(mod_quiz_ui("quiz"))
      ),
      card(
        card_header("Key Facts"),
        card_body(
          tags$dl(
            tags$dt("SAR (Smolt-to-Adult Return)"),
            tags$dd("% of smolts that return as spawning adults. Need 2% to survive, 4–6% to recover."),
            tags$dt("Snake River Wild Chinook SAR"),
            tags$dd("Mean of 0.77% (1994–2022). Only above 2% in 2 of 20 years."),
            tags$dt("Walla Walla Basin (your data)"),
            tags$dd("500 released → 5 returned to Bonneville → 1 reached Nursery Bridge."),
            tags$dt("Avian Predation"),
            tags$dd("7 birds kills vs 7 estuary detections — birds took as many fish as passed the estuary."),
            tags$dt("Four Lower Snake Dams"),
            tags$dd("If removed, Snake River fish would have similar migration conditions to John Day/Yakima — which meet recovery goals.")
          )
        )
      )
    )
  ),

  # ── ABOUT TAB ──────────────────────────────────────────────────────────────
  nav_panel("ℹ️ About",
    card(card_body(
      h4("About Salmon Survivor"),
      p("This game uses real PIT tag detection data from the Walla Walla Basin
         to simulate the journey of 500 juvenile Chinook salmon and Steelhead
         from their home streams to the Pacific Ocean and back."),
      h5("Data Sources"),
      tags$ul(
        tags$li("PIT tag cohort data: PTAGIS (ptagis.org) — Pacific States Marine Fisheries Commission"),
        tags$li("Avian predation hotspots: PIT tag recoveries at bird colonies, Walla Walla Basin"),
        tags$li("Survival rates: Fish Passage Center Comparative Survival Study"),
        tags$li("SAR data: Trout Unlimited / NOAA Fisheries")
      ),
      h5("Real Numbers from Your Data"),
      tags$ul(
        tags$li("500 fish released from South Fork Walla Walla River, April 2024"),
        tags$li("124 detected at McNary Dam juvenile bypass"),
        tags$li("167 detected at Bonneville Dam juvenile bypass"),
        tags$li("7 detected in the Columbia Estuary"),
        tags$li("7 PIT tags recovered at avian predator colonies"),
        tags$li("5 returned to Bonneville Dam as adults (2026)"),
        tags$li("1 confirmed at Nursery Bridge — home spawning grounds")
      ),
      h5("Credits"),
      p("Death screen artwork by [Local Artist Name]. Built with R Shiny.")
    ))
  )
)
