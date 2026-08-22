# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_ocean.R
# Ocean phase — time-skip screen with random events (El Niño, harvest, orca)
# ══════════════════════════════════════════════════════════════════════════════

mod_ocean_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("ocean_panel"))
}

mod_ocean_server <- function(id, ocean_data, trigger_return) {
  moduleServer(id, function(input, output, session) {

    output$ocean_panel <- renderUI({
      od <- ocean_data()
      req(!is.null(od))

      events_hit <- od$ocean_events %||% list()

      div(
        style = "background: linear-gradient(135deg, #0a1628, #0d2f4f);
                 border-radius: 8px; padding: 20px; color: white;
                 border: 1px solid #4fc3f7; margin-bottom: 12px;",

        h4(style = "color: #4fc3f7; margin-top:0;",
           "🌊 Ocean Phase — 1 to 3 Years at Sea"),

        p(style = "color: #aad4e8; font-size: 0.9em;",
          "Your cohort has left the Columbia River and entered the Pacific Ocean.
           Many things can happen out here — and scientists can't track every fish."),

        hr(style = "border-color: #1a4a6a;"),

        # Ocean events that fired
        if (length(events_hit) > 0) {
          tagList(
            h6(style = "color: #e67e22;", "⚡ Events During Ocean Residence:"),
            lapply(events_hit, function(ev) {
              is_good <- ev$n_killed < 0
              div(
                style = paste0(
                  "margin-bottom: 8px; padding: 10px; border-radius: 6px; ",
                  if (is_good) "background:#0d2a1a; border-left: 3px solid #2d8a4e;"
                  else "background:#2a0d0d; border-left: 3px solid #c0392b;"
                ),
                div(style = "font-weight: bold;", ev$event$label),
                p(style = "margin: 4px 0 0; font-size:0.85em; color:#ccc;",
                  ev$event$text),
                if (!is_good) {
                  span(style = "color:#c0392b; font-size:0.9em; font-weight:bold;",
                       paste0("💀 -", ev$n_killed, " fish"))
                } else {
                  span(style = "color:#2d8a4e; font-size:0.9em; font-weight:bold;",
                       paste0("✨ +", abs(ev$n_killed), " bonus survivors"))
                }
              )
            })
          )
        } else {
          div(style = "color: #aad4e8; font-style: italic; font-size:0.9em;",
              "✅ No major ocean disturbances this year. Your fish had favorable conditions.")
        },

        hr(style = "border-color: #1a4a6a;"),

        div(
          style = "background: #071220; padding: 12px; border-radius: 6px;",
          p(style = "margin:0; font-size:0.85em; color:#aad4e8;",
            "📊 ",
            tags$b("Real data: "),
            "Only 5 of 500 Walla Walla Basin fish were detected returning as adults.
             That's a 1% smolt-to-adult return rate (SAR). Recovery requires 2–6%."
          )
        ),

        div(
          style = "margin-top: 16px; text-align: center;",
          actionButton(
            session$ns("begin_return"),
            "🐟 Begin Adult Return Migration →",
            class = "btn-primary btn-lg"
          )
        )
      )
    })

    observeEvent(input$begin_return, {
      trigger_return(trigger_return() + 1)
    })
  })
}
