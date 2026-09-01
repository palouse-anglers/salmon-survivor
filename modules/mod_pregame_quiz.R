# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_pregame_quiz.R
# Pre-game welcome screen — shown before the game starts.
# Calls on_complete(list(bonus = n)) when the player is ready.
# ══════════════════════════════════════════════════════════════════════════════

mod_pregame_quiz_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "max-width:680px; margin:40px auto; padding:0 16px;",
    div(
      style = "background:linear-gradient(135deg,#0a1628,#0d2f4f);
               border:2px solid #4fc3f7; border-radius:12px;
               padding:32px 36px; color:white; text-align:center;",

      tags$img(
        src   = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Oncorhynchus_tshawytscha.jpg/320px-Oncorhynchus_tshawytscha.jpg",
        style = "width:160px; border-radius:8px; margin-bottom:20px; opacity:0.9;"
      ),

      h2(style = "color:#4fc3f7; margin-bottom:8px;",
         "\U0001f41f Salmon Survivor"),

      p(style = "color:#aad4e8; font-size:1.05em; margin-bottom:20px;",
        "500 juvenile steelhead were released from the Walla Walla Basin in 2024.",
        br(),
        tags$b("Only 1 made it home."),
        " Can your cohort do better?"
      ),

      div(
        style = "background:#071220; border-radius:8px; padding:14px 20px;
                 margin-bottom:24px; font-size:0.88em; color:#aad4e8; text-align:left;",
        tags$b(style="color:#4fc3f7;", "Your mission:"),
        tags$ul(style="margin:8px 0 0 0; padding-left:18px;",
          tags$li("Guide your salmon cohort from the Walla Walla Basin to the Pacific Ocean and back."),
          tags$li("Face real predation events based on actual PIT tag data."),
          tags$li("Answer conservation questions to earn bonus fish.")
        )
      ),

      actionButton(
        ns("start"),
        "\U0001f420 Begin Migration \u2192",
        class = "btn-primary btn-lg",
        style = "font-size:1.1em; padding:12px 32px;"
      )
    )
  )
}

mod_pregame_quiz_server <- function(id, on_complete) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$start, {
      on_complete(list(bonus = 0L))
    }, ignoreNULL = TRUE, ignoreInit = TRUE)
  })
}
