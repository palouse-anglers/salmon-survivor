# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_pregame_quiz.R
# Pre-game welcome screen — shown before the game starts.
# Calls on_complete(list(bonus = n)) when the player is ready.
# ══════════════════════════════════════════════════════════════════════════════

mod_pregame_quiz_ui <- function(id) {
  ns <- NS(id)
  div(
    tags$head(
      tags$link(
        href = "https://fonts.googleapis.com/css2?family=Bebas+Neue&display=swap",
        rel  = "stylesheet"
      )
    ),
    style = "max-width:680px; margin:40px auto; padding:0 16px;",
    div(
      style = "background:linear-gradient(135deg,#0a1628,#0d2f4f);
               border:2px solid #4fc3f7; border-radius:12px;
               padding:32px 36px; color:white; text-align:center;",

      tags$h1(
        "Salmon Survivor",
        style = "font-family:'Bebas Neue', sans-serif;
                 font-size:3.6em;
                 letter-spacing:0.08em;
                 color:#4fc3f7;
                 text-shadow:0 0 24px rgba(79,195,247,0.8),
                             0 2px 4px rgba(0,0,0,0.6);
                 margin-bottom:20px;
                 line-height:1.0;"
      ),

      # Fish image with light blue background panel
      div(
        style = "background-image: url('background.png');
                 background-size: cover;
                 background-position: center;
                 border-radius:14px;
                 padding:16px;
                 margin-bottom:20px;
                 display:inline-block;
                 box-shadow:0 4px 28px rgba(79,195,247,0.45);",
        tags$img(
          src   = "smolt.png",
          style = "width:340px; display:block; border-radius:8px;"
        )
      ),

      p(style = "color:#aad4e8; font-size:1.05em; margin-bottom:20px;",
        "500 juvenile steelhead were released from the Walla Walla Basin in 2024.",
        br(),
        tags$b("Only 1 made it home."),
        " Can your cohort do better?"
      ),

      div(
        style = "background:#071220; border-radius:8px; padding:14px 20px;
                 margin-bottom:24px; text-align:left;",
        tags$b(style = "color:#4fc3f7; font-size:0.95em;", "\U0001f3af Difficulty"),
        radioButtons(
          ns("difficulty"),
          label    = NULL,
          choices  = c(
            "\U0001f7e2 Easy — half the mortality (great for younger players)"   = "easy",
            "\U0001f7e1 Medium — real-world mortality rates"                      = "medium",
            "\U0001f534 Hard — 1.5× mortality (brutal, historically accurate)"   = "hard"
          ),
          selected = "medium",
          width    = "100%"
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
      on_complete(list(bonus = 0L, difficulty = input$difficulty))
    }, ignoreNULL = TRUE, ignoreInit = TRUE)
  })
}
