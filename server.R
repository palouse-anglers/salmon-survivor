# ══════════════════════════════════════════════════════════════════════════════
# server.R
# ══════════════════════════════════════════════════════════════════════════════

server <- function(input, output, session) {

  all_stations <- c(STATIONS_OUTBOUND, STATIONS_OCEAN, STATIONS_RETURN)

  # ── Game state ──────────────────────────────────────────────────────────────
  gs <- reactiveValues(
    phase                = "pregame",   # pregame | intro_video | dam_video | cormorant_video | adult_video | playing | modal | done
    step                 = 0,
    step_processed       = FALSE,  # TRUE once advance_to_step has run for current step
    cohort               = NULL,
    n_alive              = COHORT_START,
    cohort_start         = COHORT_START,
    difficulty           = "medium",
    start_loc            = NULL,
    journey_log          = NULL,
    current_ev           = NULL,
    dam_video_seen        = FALSE,
    gasbubble_video_seen  = FALSE,
    fishladder_video_seen = FALSE,
    cormorant_video_seen  = FALSE,
    adult_video_seen      = FALSE,
    sealion_video_seen    = FALSE
  )

  # ── Load data ────────────────────────────────────────────────────────────────
  cohort_csv  <- load_cohort_csv()
  real_counts <- compute_real_counts(cohort_csv)

  # ── Pre-game quiz complete → show intro video ─────────────────────────────
  pregame_done <- function(result) {
    gs$cohort_start <- COHORT_START + result$bonus
    gs$n_alive      <- gs$cohort_start
    gs$difficulty   <- result$difficulty %||% "medium"
    gs$start_loc    <- START_LOCATIONS[[sample(length(START_LOCATIONS), 1)]]
    gs$phase        <- "intro_video"
  }

  mod_pregame_quiz_server("pregame", on_complete = pregame_done)
  mod_intro_video_server("intro_video", on_done = function() {
    gs$phase <- "wallawalla_video"
  })
  mod_intro_video_server("wallawalla_video", on_done = start_game)
  mod_intro_video_server("dam_video", on_done = function() {
    gs$dam_video_seen <- TRUE
    ev <- gs$current_ev
    if (!is.null(ev)) gs$n_alive <- ev$n_arrive - ev$n_killed
    gs$phase          <- "playing"
    gs$step_processed <- TRUE
  })
  mod_intro_video_server("gasbubble_video", on_done = function() {
    gs$gasbubble_video_seen <- TRUE
    ev <- gs$current_ev
    if (!is.null(ev)) gs$n_alive <- ev$n_arrive - ev$n_killed
    gs$phase          <- "playing"
    gs$step_processed <- TRUE
  })
  mod_intro_video_server("fishladder_video", on_done = function() {
    gs$fishladder_video_seen <- TRUE
    ev <- gs$current_ev
    if (!is.null(ev)) gs$n_alive <- ev$n_arrive - ev$n_killed
    gs$phase          <- "playing"
    gs$step_processed <- TRUE
  })
  mod_intro_video_server("cormorant_video", on_done = function() {
    gs$cormorant_video_seen <- TRUE
    ev <- gs$current_ev
    if (!is.null(ev)) gs$n_alive <- ev$n_arrive - ev$n_killed
    gs$phase                <- "playing"
    gs$step_processed       <- TRUE
  })
  mod_intro_video_server("adult_video", on_done = function() {
    gs$adult_video_seen <- TRUE
    next_step <- gs$step + 1
    gs$phase  <- "playing"
    advance_to_step(next_step)
  })
  mod_intro_video_server("sealion_video", on_done = function() {
    gs$sealion_video_seen <- TRUE
    ev <- gs$current_ev
    if (!is.null(ev)) gs$n_alive <- ev$n_arrive - ev$n_killed
    gs$phase          <- "playing"
    gs$step_processed <- TRUE
  })

  output$show_pregame           <- reactive({ gs$phase == "pregame" })
  output$show_intro_video       <- reactive({ gs$phase == "intro_video" })
  output$show_wallawalla_video  <- reactive({ gs$phase == "wallawalla_video" })
  output$show_dam_video         <- reactive({ gs$phase == "dam_video" })
  output$show_gasbubble_video   <- reactive({ gs$phase == "gasbubble_video" })
  output$show_fishladder_video  <- reactive({ gs$phase == "fishladder_video" })
  output$show_cormorant_video   <- reactive({ gs$phase == "cormorant_video" })
  output$show_adult_video       <- reactive({ gs$phase == "adult_video" })
  output$show_sealion_video     <- reactive({ gs$phase == "sealion_video" })
  outputOptions(output, "show_pregame",          suspendWhenHidden = FALSE)
  outputOptions(output, "show_intro_video",      suspendWhenHidden = FALSE)
  outputOptions(output, "show_wallawalla_video", suspendWhenHidden = FALSE)
  outputOptions(output, "show_dam_video",        suspendWhenHidden = FALSE)
  outputOptions(output, "show_gasbubble_video",  suspendWhenHidden = FALSE)
  outputOptions(output, "show_fishladder_video", suspendWhenHidden = FALSE)
  outputOptions(output, "show_cormorant_video",  suspendWhenHidden = FALSE)
  outputOptions(output, "show_adult_video",      suspendWhenHidden = FALSE)
  outputOptions(output, "show_sealion_video",    suspendWhenHidden = FALSE)

  # ── Start / restart ───────────────────────────────────────────────────────────
  start_game <- function() {
    gs$cohort          <- simulate_cohort(cohort_size = gs$cohort_start,
                                          difficulty  = gs$difficulty)
    gs$step            <- 1
    gs$step_processed  <- FALSE   # player must click Next Stop to begin
    gs$n_alive         <- gs$cohort_start
    gs$phase           <- "playing"
    gs$journey_log     <- NULL
    gs$current_ev      <- NULL
  }

  restart_game <- function() {
    gs$phase                <- "pregame"
    gs$cohort               <- NULL
    gs$n_alive              <- COHORT_START
    gs$cohort_start         <- COHORT_START
    gs$difficulty           <- "medium"
    gs$start_loc            <- NULL
    gs$journey_log          <- NULL
    gs$current_ev           <- NULL
    gs$step                 <- 0
    gs$step_processed       <- FALSE
    gs$dam_video_seen        <- FALSE
    gs$gasbubble_video_seen  <- FALSE
    gs$fishladder_video_seen <- FALSE
    gs$cormorant_video_seen  <- FALSE
    gs$adult_video_seen      <- FALSE
    gs$sealion_video_seen    <- FALSE
  }

  # ── Advance to a step ────────────────────────────────────────────────────────
  advance_to_step <- function(step) {
    req(!is.null(gs$cohort))
    gs$step           <- step
    gs$step_processed <- TRUE
    gs$current_ev     <- NULL   # clear any stale event
    stn <- all_stations[step]

    # Quiz stops — show quiz modal directly (handled by mod_pregame_quiz for
    # in-river quizzes... actually handled by mortality modal via INGAME_QUESTIONS)
    # For pure quiz stops with no mortality, skip straight to showing controls
    if (grepl("^quiz_", stn)) {
      # Quiz is embedded in the mortality modal via INGAME_QUESTIONS
      # Build a zero-mortality event so modal still fires with just the quiz
      row <- gs$cohort |> dplyr::filter(station == stn)
      gs$current_ev <- list(
        station  = stn,
        n_arrive = gs$n_alive,
        n_killed = 0L,
        cause    = "quiz",
        label    = "Conservation Stop",
        phase    = "outbound"
      )
      gs$phase <- "modal"
      return()
    }

    # Ocean end — time skip card, no modal
    if (stn == "ocean_end") { gs$phase <- "ocean_end"; return() }
    if (stn == "home")      { gs$phase <- "done";      return() }

    row <- gs$cohort |> dplyr::filter(station == stn)
    if (nrow(row) > 0 && row$n_killed > 0) {
      gs$current_ev <- as.list(row[1,])

      # ── Show dam video before the first dam event ─────────────────────────
      if (!gs$dam_video_seen &&
          isTRUE(startsWith(gs$current_ev$cause, "dam_"))) {
        gs$phase <- "dam_video"
      # ── Show gas bubble video before John Day Dam ──────────────────────────
      } else if (!gs$gasbubble_video_seen &&
          isTRUE(gs$current_ev$cause == "dam_john_day")) {
        gs$phase <- "gasbubble_video"
      # ── Show fish ladder video before The Dalles Dam ───────────────────────
      } else if (!gs$fishladder_video_seen &&
          isTRUE(gs$current_ev$cause == "dam_thedalles")) {
        gs$phase <- "fishladder_video"
      # ── Show cormorant video before the first cormorant event ─────────────
      } else if (!gs$cormorant_video_seen &&
          isTRUE(gs$current_ev$cause == "avian_cormorant")) {
        gs$phase <- "cormorant_video"
      # ── Show sea lion video before the first sea lion event ───────────────
      } else if (!gs$sealion_video_seen &&
          isTRUE(gs$current_ev$cause == "sealion")) {
        gs$phase <- "sealion_video"
      } else {
        gs$phase <- "modal"
      }
    } else {
      # No mortality — just update counter and move on
      if (nrow(row) > 0) gs$n_alive <- row$n_arrive[1]
      gs$phase <- "playing"
    }
  }

  # ── Mortality modal: next button callback ─────────────────────────────────────
  mortality_next <- function(fish_back) {
    ev <- gs$current_ev

    # Apply kill and quiz bonus together — dashboard only updates now (on Close)
    gs$n_alive <- (ev$n_arrive %||% gs$n_alive) - (ev$n_killed %||% 0) + fish_back

    # Log
    gs$journey_log <- dplyr::bind_rows(
      gs$journey_log,
      tibble::tibble(
        station   = ev$station %||% "",
        label     = ev$label   %||% "",
        n_arrive  = ev$n_arrive %||% 0,
        n_killed  = ev$n_killed %||% 0,
        fish_back = fish_back,
        net_loss  = (ev$n_killed %||% 0) - fish_back
      )
    )

    # Return to main screen — player clicks Next Stop to advance
    gs$phase <- "playing"
  }

  # ── Next stop button ──────────────────────────────────────────────────────────
  observeEvent(input$next_station, {
    req(gs$phase == "playing")
    if (!gs$step_processed) {
      advance_to_step(gs$step)
    } else {
      next_step <- gs$step + 1
      if (next_step > length(all_stations)) {
        gs$phase <- "done"
      } else {
        advance_to_step(next_step)
      }
    }
  })

  # ── Ocean end → begin return ─────────────────────────────────────────────────
  observeEvent(input$begin_return, {
    req(gs$phase == "ocean_end")
    gs$phase <- "adult_video"
  })

  # ── Modules ───────────────────────────────────────────────────────────────────
  mod_cohort_server("cohort", n_alive = reactive({ gs$n_alive }))

  station_info_data <- reactive({
    req(gs$step > 0, !is.null(gs$cohort))
    stn_id <- all_stations[gs$step]
    stn    <- STATIONS |> dplyr::filter(id == stn_id)
    rc     <- if (!is.null(real_counts)) {
      r <- real_counts |> dplyr::filter(station == stn_id)
      if (nrow(r) > 0) r$real_count else NULL
    } else NULL
    phase <- dplyr::case_when(
      stn_id %in% STATIONS_OUTBOUND ~ "outbound",
      stn_id %in% STATIONS_OCEAN   ~ "ocean",
      TRUE                          ~ "return"
    )
    list(
      label      = if (nrow(stn)>0) stn$label else stn_id,
      phase_lbl  = phase_label(phase),
      rkm        = if (nrow(stn)>0 && !is.na(stn$rkm)) stn$rkm else NA,
      real_count = rc
    )
  })

  mod_map_server("map",
    current_station   = reactive({ if(gs$step>0) all_stations[gs$step] else NULL }),
    station_info_data = station_info_data
  )

  mortality_fish_back <- mod_mortality_server("mortality",
    mortality_event = reactive({ if(gs$phase=="modal") gs$current_ev else NULL }),
    on_next         = mortality_next
  )

  mod_results_server("results",
    final_count = reactive({ gs$n_alive }),
    journey_log = reactive({ gs$journey_log }),
    on_restart  = restart_game
  )

  mod_quiz_server("quiz")

  # ── UI outputs ────────────────────────────────────────────────────────────────

  # Start location flavor text
  output$start_flavor <- renderUI({
    req(!is.null(gs$start_loc), gs$phase != "pregame")
    div(
      style = "background:#071a2e; border-left:3px solid #4fc3f7;
               border-radius:4px; padding:10px 14px; margin-bottom:10px;
               font-size:0.88em; color:#aad4e8; font-style:italic;",
      paste0("\U0001f41f ", gs$start_loc$flavor)
    )
  })

  # Pregame summary
  output$pregame_summary <- renderUI({
    req(!is.null(gs$cohort_start), gs$phase != "pregame",
        gs$cohort_start > COHORT_START)
    bonus <- gs$cohort_start - COHORT_START
    div(
      style = "background:#071a0e; border:1px solid #2d8a4e; border-radius:6px;
               padding:9px 14px; margin-bottom:10px; font-size:0.83em; color:#aaddbb;",
      paste0("\U0001f33f Habitat bonus: +", bonus, " fish. Starting cohort: ",
             gs$cohort_start, " fish.")
    )
  })

  # Game controls
  output$game_controls <- renderUI({
    req(gs$phase == "playing")
    stn <- all_stations[gs$step]

    div(
      style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;",
      actionButton("restart_game", "\U0001f504 New Cohort",
                   class="btn-outline-secondary btn-sm"),
      span(style="font-size:0.8em; color:#aad4e8;",
           paste0("Stop ", gs$step, " of ", length(all_stations)))
    )
  })

  # Ocean time-skip card
  output$ocean_card <- renderUI({
    req(gs$phase == "ocean_end")
    div(
      style = "background:linear-gradient(135deg,#0a1628,#0d2f4f);
               border:1px solid #4fc3f7; border-radius:10px;
               padding:20px 24px; color:white; margin-bottom:12px;",
      h4(style="color:#4fc3f7; margin-top:0;", "\U0001f30a 1 to 3 Years at Sea"),
      p(style="color:#aad4e8;",
        "Your cohort has entered the Pacific Ocean. Scientists lose track of
         most fish here — no antennas, no PIT readers. Only the ones that
         survive will return."),
      div(style="background:#071220; padding:12px; border-radius:6px; margin:12px 0;
                 font-size:0.85em; color:#aad4e8;",
        tags$b("Real data: "),
        "Of 500 Walla Walla fish, only 5 returned to Bonneville Dam as adults.
         That is a 1% smolt-to-adult return rate. Recovery requires 2\u20136%."
      ),
      actionButton("begin_return", "\U0001f420 Begin Adult Return \u2192",
                   class="btn-primary btn-lg")
    )
  })

  # Win/lose
  output$show_results <- renderUI({
    req(gs$phase == "done")
    mod_results_ui("results")
  })

  observeEvent(input$restart_game, { restart_game() })

  output$map_header <- renderUI({
    req(gs$step > 0)
    stn <- all_stations[gs$step]
    s   <- STATIONS |> dplyr::filter(id == stn)
    lbl <- if (nrow(s)>0) s$label else stn
    span(style="color:#4fc3f7;", lbl)
  })

  output$next_stop_btn <- renderUI({
    req(gs$phase %in% c("playing", "modal"), gs$step > 0)
    actionButton("next_station", "Next Stop \u27a1\ufe0f",
      class = "btn-primary w-100 mt-2"
    )
  })

}
