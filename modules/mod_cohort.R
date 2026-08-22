# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_cohort.R
# Cohort counter widget — the big fish counter shown throughout the game
# ══════════════════════════════════════════════════════════════════════════════

mod_cohort_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "cohort-counter",
      style = "text-align:center; padding: 12px; border-radius: 8px;
               background: #0a2a3a; color: white; margin-bottom: 12px;",
      div(style = "font-size: 0.85em; color: #aad4e8; letter-spacing: 1px;
                   text-transform: uppercase;",
          "Fish Remaining"),
      div(
        uiOutput(ns("counter_number")),
        style = "font-size: 3.5em; font-weight: 900; line-height: 1.1;"
      ),
      div(style = "font-size: 0.8em; color: #aad4e8;",
          uiOutput(ns("counter_pct"))),
      div(style = "margin-top: 6px; font-size: 0.75em; overflow-wrap: break-word;
                   word-break: break-all; line-height: 1.6;",
          uiOutput(ns("fish_bar")))
    )
  )
}

mod_cohort_server <- function(id, n_alive) {
  moduleServer(id, function(input, output, session) {

    output$counter_number <- renderUI({
      n     <- n_alive()
      color <- counter_color(n)
      div(style = paste0("color:", color, "; transition: color 0.5s;"), n)
    })

    output$counter_pct <- renderUI({
      n <- n_alive()
      paste0(pct_remaining(n), " of original cohort")
    })

    output$fish_bar <- renderUI({
      n <- n_alive()
      HTML(fish_emoji_bar(n))
    })
  })
}
