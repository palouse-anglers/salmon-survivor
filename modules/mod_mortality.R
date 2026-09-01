mod_mortality_ui <- function(id) {
  ns <- NS(id)
  tagList()  # modal is shown via showModal, no inline UI needed
}

mod_mortality_server <- function(id, mortality_event, on_next) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      quiz_answered = FALSE,
      quiz_correct  = FALSE,
      fish_back     = 0,
      bonus_text    = NULL,
    )

    # Show modal when new event fires
    observeEvent(mortality_event(), {
      rv$quiz_answered <- FALSE
      rv$quiz_correct  <- FALSE
      rv$fish_back     <- 0
      rv$bonus_text    <- NULL

      ev         <- mortality_event()
      img_src    <- DEATH_IMAGES[[ev$cause]] %||% DEATH_IMAGES[["placeholder"]]
      narrative  <- gsub("\\{n\\}", ev$n_killed,
                    gsub("\\{remaining\\}", ev$n_arrive - ev$n_killed,
                    DEATH_NARRATIVES[[ev$cause]] %||% DEATH_NARRATIVES[["other"]]))
      cause_label <- gsub("_", " ", toupper(ev$cause %||% "mortality"))

      showModal(modalDialog(
        title = NULL,
        easyClose = TRUE,
        footer = modalButton("Close"),
        size = "m",

        # ── Artist image ──────────────────────────────────────────────
        tags$img(src = img_src,
                 style = "width:100%; max-height:200px; object-fit:cover;
                          display:block; border-radius:6px; margin-bottom:12px;"),

        div(style = "font-size:1.4em; font-weight:900; color:#e74c3c; margin-bottom:6px;",
            paste0("\U0001f480 -", ev$n_killed, " fish")),

        p(style = "color:#555; font-size:0.9em; line-height:1.5; margin-bottom:14px;",
          narrative),

        # ── Math breakdown ────────────────────────────────────────────
        div(
          style = "background:#f8f8f8; border:1px solid #ddd; border-radius:6px;
                   padding:12px 14px; font-family:monospace; font-size:0.85em;
                   margin-bottom:14px;",

          div(style = "color:#888; font-size:0.78em; text-transform:uppercase;
                       letter-spacing:0.5px; margin-bottom:8px;",
              "Mortality Calculation"),

          div(style = "display:flex; justify-content:space-between; padding:3px 0;
                       border-bottom:1px solid #eee;",
            span(style="color:#555;", "Fish arriving"),
            span(paste0(ev$n_arrive, " fish"))
          ),
          div(style = "display:flex; justify-content:space-between; padding:3px 0;
                       border-bottom:1px solid #eee;",
            span(style="color:#555;", ev$label %||% cause_label),
            span(style="color:#e74c3c; font-weight:bold;", paste0("-", ev$n_killed, " fish"))
          ),
          uiOutput(ns("bonus_row")),
          div(style = "display:flex; justify-content:space-between; padding:6px 0 2px;
                       margin-top:4px; border-top:1px solid #ccc;",
            span(style="font-weight:700;", "Survivors"),
            uiOutput(ns("survivor_count"), inline = TRUE)
          )
        ),

        # ── Quiz section ──────────────────────────────────────────────
        uiOutput(ns("quiz_section"))
      ))
    })

    # Close modal
    observeEvent(input$close_modal, {
      removeModal()
    })

    # Survivor count
    output$survivor_count <- renderUI({
      ev      <- mortality_event()
      req(!is.null(ev))
      net     <- ev$n_arrive - ev$n_killed + rv$fish_back
      span(style = paste0("font-weight:900; font-size:1.05em; ",
                          if (net > 0) "color:#2d8a4e;" else "color:#e74c3c;"),
           paste0(net, " fish"))
    })

    # Bonus row (shows after correct answer)
    output$bonus_row <- renderUI({
      req(rv$quiz_answered, rv$fish_back > 0)
      div(style = "display:flex; justify-content:space-between; padding:3px 0;
                   border-bottom:1px solid #eee;",
        span(style="color:#2d8a4e;", paste0("\u2705 ", rv$bonus_text %||% "Quiz bonus")),
        span(style="color:#2d8a4e; font-weight:bold;", paste0("+", rv$fish_back, " fish"))
      )
    })

    # Quiz section
    output$quiz_section <- renderUI({
      ev <- mortality_event()
      q  <- INGAME_QUESTIONS[[ev$station]]
      req(!is.null(q))

      if (!rv$quiz_answered) {
        div(
          style = "background:#eaf4fb; border:1px solid #aed6f1; border-radius:8px;
                   padding:14px 16px;",
          div(style="font-size:0.72em; color:#e67e22; text-transform:uppercase;
                     letter-spacing:1px; margin-bottom:6px;",
              paste0("\u26a1 Earn some back! Correct = +", q$fish_back, " fish")),
          p(style="font-size:0.9em; margin-bottom:10px;", q$q),
          lapply(seq_along(q$choices), function(i) {
            actionButton(
              ns(paste0("ans_", i)), q$choices[i],
              class = "btn-outline-primary w-100 mb-2 text-start",
              style = "padding:8px 12px; font-size:0.85em;"
            )
          })
        )
      } else {
        div(
          style = paste0("border-radius:8px; padding:12px 16px; ",
            if (rv$quiz_correct)
              "background:#eafaf1; border:1px solid #2d8a4e;"
            else
              "background:#fdf0f0; border:1px solid #c0392b;"
          ),
          div(style = paste0("font-weight:700; margin-bottom:6px; ",
                if(rv$quiz_correct) "color:#2d8a4e;" else "color:#c0392b;"),
              if(rv$quiz_correct)
                paste0("\u2705 Correct! +", rv$fish_back, " fish returned")
              else
                "\u274c Incorrect — no fish earned back"
          ),
          p(style="margin:0; font-size:0.82em; color:#555;", q$explain)
        )
      }
    })

    # Quiz answer handlers
    lapply(seq_len(4), function(i) {
      observeEvent(input[[paste0("ans_", i)]], {
        if (!rv$quiz_answered) {
          q <- INGAME_QUESTIONS[[mortality_event()$station]]
          req(!is.null(q))
          correct <- (i == q$correct)
          rv$quiz_correct  <- correct
          rv$quiz_answered <- TRUE
          rv$fish_back     <- if (correct) q$fish_back else 0
          rv$bonus_text    <- if (correct) q$bonus_text else NULL
        }
      }, ignoreNULL = TRUE, ignoreInit = TRUE)
    })

    # Expose fish_back for server to pick up
    reactive({ rv$fish_back })
  })
}