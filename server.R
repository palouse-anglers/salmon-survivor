# ══════════════════════════════════════════════════════════════════════════════
# server.R
# ══════════════════════════════════════════════════════════════════════════════

server <- function(input, output, session) {

  # ── Game state ──────────────────────────────────────────────────────────────
  gs <- reactiveValues(
    step          = 0,          # current station index (0 = not started)
    cohort        = NULL,       # simulated cohort tibble from simulate_cohort()
    n_alive       = COHORT_START,
    phase         = "outbound", # outbound | ocean | return | done
    trigger_return = 0,
    journey_log   = NULL
  )

  all_stations <- c(STATIONS_OUTBOUND, STATIONS_RETURN)

  # ── Load data on startup ────────────────────────────────────────────────────
  cohort_csv  <- load_cohort_csv()
  real_counts <- compute_real_counts(cohort_csv)

  # ── Start / restart game ────────────────────────────────────────────────────
  start_game <- function() {
    gs$cohort      <- simulate_cohort(cohort_size = COHORT_START)
    gs$step        <- 1
    gs$n_alive     <- COHORT_START
    gs$phase       <- "outbound"
    gs$journey_log <- NULL
    gs$trigger_return <- 0
  }

  # Auto-start
  observe({
    if (is.null(gs$cohort)) start_game()
  })

  # ── Current station ─────────────────────────────────────────────────────────
  current_station_id <- reactive({
    req(gs$step > 0, !is.null(gs$cohort))
    all_stations[gs$step]
  })

  current_row <- reactive({
    req(!is.null(gs$cohort), gs$step > 0)
    stn <- all_stations[gs$step]
    gs$cohort |> filter(station == stn)
  })

  # ── Advance to next station ─────────────────────────────────────────────────
  observeEvent(input$next_station, {
    req(gs$step < length(all_stations))

    # Log current station to journey
    row <- current_row()
    if (!is.null(row) && nrow(row) > 0) {
      gs$journey_log <- bind_rows(gs$journey_log, row)
      gs$n_alive     <- row$n_arrive
    }

    gs$step <- gs$step + 1

    # Check if entering ocean
    if (all_stations[gs$step] == "ocean") {
      gs$phase <- "ocean"
    } else if (gs$step > which(all_stations == "ocean")) {
      gs$phase <- "return"
    }

    # Check win/lose
    if (all_stations[gs$step] == "nursery_bridge") {
      gs$phase <- "done"
    }
  })

  # ── Return trigger from ocean module ───────────────────────────────────────
  trigger_return_rv <- reactiveVal(0)

  observeEvent(trigger_return_rv(), {
    if (trigger_return_rv() > 0) {
      # Jump to bonneville_adult
      gs$step  <- which(all_stations == "bonneville_adult")
      gs$phase <- "return"
    }
  }, ignoreInit = TRUE)

  # ── Cohort counter ──────────────────────────────────────────────────────────
  mod_cohort_server("cohort", n_alive = reactive({ gs$n_alive }))

  # ── Map ─────────────────────────────────────────────────────────────────────
  # Station info reactive for map modal
  station_info_data <- reactive({
    req(gs$step > 0)
    row <- current_row()
    req(!is.null(row), nrow(row) > 0)
    stn <- STATIONS |> dplyr::filter(id == row$station)
    rc  <- if (!is.null(real_counts)) {
      r <- real_counts |> dplyr::filter(station == row$station)
      if (nrow(r) > 0) r$real_count else NULL
    } else NULL
    list(
      label      = row$label,
      phase_lbl  = phase_label(row$phase),
      rkm        = if (nrow(stn) > 0) stn$rkm else NA,
      real_count = rc
    )
  })

  mod_map_server("map",
    current_station   = current_station_id,
    station_info_data = station_info_data
  )

  # ── Mortality panel ─────────────────────────────────────────────────────────
  current_mortality <- reactive({
    row <- current_row()
    req(!is.null(row), nrow(row) > 0)
    list(
      n_killed = row$n_killed,
      cause    = row$cause,
      context  = NULL  # future: add per-cause context text
    )
  })
  mod_mortality_server("mortality", mortality_event = current_mortality)

  # ── Ocean module ─────────────────────────────────────────────────────────────
  ocean_data <- reactive({
    req(gs$phase == "ocean")
    ocean_row <- gs$cohort |> filter(station == "ocean")
    if (nrow(ocean_row) == 0) return(NULL)
    list(
      n_arrive     = ocean_row$n_arrive,
      ocean_events = list()  # populated by simulate_cohort via attributes
    )
  })
  mod_ocean_server("ocean",
    ocean_data     = ocean_data,
    trigger_return = trigger_return_rv
  )

  # ── Results module ───────────────────────────────────────────────────────────
  final_count <- reactive({
    req(gs$phase == "done")
    row <- gs$cohort |> filter(station == "nursery_bridge")
    if (nrow(row) == 0) return(0)
    row$n_arrive
  })

  mod_results_server("results",
    final_count  = final_count,
    journey_log  = reactive({ gs$journey_log }),
    on_restart   = start_game
  )

  # ── Quiz ─────────────────────────────────────────────────────────────────────
  mod_quiz_server("quiz")

  # Station info now handled via map modal — map_header kept minimal
  output$map_header <- renderUI({
    req(gs$step > 0)
    row <- current_row()
    req(!is.null(row), nrow(row) > 0)
    span(style = "color:#4fc3f7;", row$label)
  })

  # ── Game controls ────────────────────────────────────────────────────────────
  output$game_controls <- renderUI({
    req(!is.null(gs$cohort))

    is_ocean <- gs$phase == "ocean"
    is_done  <- gs$phase == "done"
    at_end   <- gs$step >= length(all_stations)

    if (is_done || at_end) return(NULL)
    if (is_ocean) return(NULL)  # ocean module has its own button

    div(
      style = "display:flex; gap:8px; flex-wrap:wrap; margin-top:4px;",
      actionButton("next_station", "Next Stop →",
                   class = "btn-primary"),
      actionButton("restart_game", "🔄 New Cohort",
                   class = "btn-outline-secondary btn-sm"),
      span(style = "font-size:0.8em; color:#aad4e8; align-self:center;",
           paste0("Stop ", gs$step, " of ", length(all_stations)))
    )
  })

  observeEvent(input$restart_game, { start_game() })
}