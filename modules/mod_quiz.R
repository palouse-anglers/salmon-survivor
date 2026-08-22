# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_quiz.R
# Quiz tab — 5 questions, immediate feedback, score tracker
# ══════════════════════════════════════════════════════════════════════════════

QUIZ_QUESTIONS <- list(
  list(
    q        = "Out of 500 juvenile salmon released from the Walla Walla Basin, how many were confirmed returning home as adults?",
    choices  = c("About 50 (10%)", "About 25 (5%)", "About 5 (1%)", "Just 1 (0.2%)"),
    correct  = 4,
    explain  = "Only 1 fish out of 500 was confirmed at Nursery Bridge — a 0.2% return rate. Even the broader SAR goal of 2% is rarely met for Snake River fish."
  ),
  list(
    q        = "In the real Walla Walla data, avian predators killed 7 fish. How many fish made it past the estuary?",
    choices  = c("50 fish", "20 fish", "7 fish", "100 fish"),
    correct  = 3,
    explain  = "Exactly 7 fish were detected in the estuary — the same number killed by birds. More fish were eaten by birds than successfully passed through the estuary zone."
  ),
  list(
    q        = "What does SAR stand for, and what rate is needed just to prevent population decline?",
    choices  = c("Salmon Adult Ratio — 10%", "Smolt-to-Adult Return — 2%",
                 "Spawner Assessment Rate — 5%", "Seasonal Adult Return — 4%"),
    correct  = 2,
    explain  = "SAR = Smolt-to-Adult Return. A 2% SAR is the minimum to maintain population levels. Recovery requires 4–6%. Snake River wild Chinook average just 0.77%."
  ),
  list(
    q        = "Why do salmon from the John Day and Yakima rivers have much higher survival rates than Snake River salmon?",
    choices  = c("They are a different, hardier species",
                 "They receive more hatchery supplementation",
                 "They pass through fewer dams",
                 "They have better ocean conditions"),
    correct  = 3,
    explain  = "John Day River chinook have a 4.21% SAR and Yakima steelhead hit 5.3% — well above recovery goals. The key difference: Snake River fish must pass 8 dams (4 Snake + 4 Columbia). John Day fish pass only 3–4."
  ),
  list(
    q        = "A PIT tag recovered at a bird colony tells scientists what?",
    choices  = c("The fish survived and spawned successfully",
                 "The exact location and date the fish was eaten by a bird",
                 "The fish was caught by a fisherman",
                 "The fish made it to the ocean"),
    correct  = 2,
    explain  = "PIT tag readers at bird colonies scan regurgitated tags and bones. Each recovered tag gives scientists the exact tag code, letting them trace the fish's entire journey up to the point it was eaten — powerful mortality data."
  )
)

mod_quiz_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("question_ui")),
    hr(),
    uiOutput(ns("feedback_ui"))
  )
}

mod_quiz_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      index    = 1,
      score    = 0,
      answered = FALSE,
      correct  = NULL
    )

    output$question_ui <- renderUI({
      idx <- rv$index
      if (idx > length(QUIZ_QUESTIONS)) {
        return(div(
          class = "alert alert-success",
          h4("🎉 Quiz Complete!"),
          p(paste("Score:", rv$score, "out of", length(QUIZ_QUESTIONS))),
          actionButton(ns("restart_quiz"), "Try Again", class = "btn-success")
        ))
      }

      q <- QUIZ_QUESTIONS[[idx]]
      tagList(
        p(class = "text-muted mb-1",
          paste("Question", idx, "of", length(QUIZ_QUESTIONS))),
        h5(q$q),
        div(
          lapply(seq_along(q$choices), function(i) {
            btn_class <- if (rv$answered) {
              if (i == q$correct) "btn-success w-100 mb-2 text-start"
              else if (!rv$correct && !is.null(input[[paste0("ans_", i)]]) &&
                       input[[paste0("ans_", i)]] > 0)
                "btn-danger w-100 mb-2 text-start"
              else "btn-outline-secondary w-100 mb-2 text-start"
            } else {
              "btn-outline-primary w-100 mb-2 text-start"
            }
            actionButton(ns(paste0("ans_", i)), q$choices[i], class = btn_class)
          })
        )
      )
    })

    output$feedback_ui <- renderUI({
      req(rv$answered)
      idx <- rv$index
      if (idx > length(QUIZ_QUESTIONS)) return(NULL)
      q   <- QUIZ_QUESTIONS[[idx]]

      tagList(
        div(
          class = if (rv$correct) "alert alert-success" else "alert alert-danger",
          if (rv$correct) "✅ Correct!" else "❌ Not quite.",
          br(), q$explain
        ),
        actionButton(ns("next_q"), "Next →", class = "btn-primary")
      )
    })

    # Answer handlers
    lapply(seq_len(4), function(i) {
      observeEvent(input[[paste0("ans_", i)]], {
        if (!rv$answered) {
          q          <- QUIZ_QUESTIONS[[rv$index]]
          rv$correct <- (i == q$correct)
          if (rv$correct) rv$score <- rv$score + 1
          rv$answered <- TRUE
        }
      }, ignoreNULL = TRUE, ignoreInit = TRUE)
    })

    observeEvent(input$next_q, {
      rv$index    <- rv$index + 1
      rv$answered <- FALSE
      rv$correct  <- NULL
    })

    observeEvent(input$restart_quiz, {
      rv$index    <- 1
      rv$score    <- 0
      rv$answered <- FALSE
      rv$correct  <- NULL
    })
  })
}
