# ══════════════════════════════════════════════════════════════════════════════
# R/simulate_cohort.R
# Builds the cohort journey tibble from MORTALITY config
# Each row = one station, with fish arriving, killed, and cause
# ══════════════════════════════════════════════════════════════════════════════

simulate_cohort <- function(cohort_size = COHORT_START) {

  all_stations <- c(STATIONS_OUTBOUND, STATIONS_OCEAN, STATIONS_RETURN)
  n <- cohort_size
  rows <- list()

  for (stn in all_stations) {

    # Quiz stops have no mortality
    if (grepl("^quiz_", stn) || stn == "ocean_end") {
      rows[[stn]] <- tibble::tibble(
        station  = stn,
        n_arrive = n,
        n_killed = 0L,
        cause    = NA_character_,
        label    = STATIONS$label[STATIONS$id == stn][1] %||% stn,
        phase    = dplyr::case_when(
          stn %in% STATIONS_OUTBOUND ~ "outbound",
          stn %in% STATIONS_OCEAN   ~ "ocean",
          TRUE                      ~ "return"
        )
      )
      next
    }

    # Home — win condition, no mortality
    if (stn == "home") {
      rows[[stn]] <- tibble::tibble(
        station  = stn,
        n_arrive = n,
        n_killed = 0L,
        cause    = NA_character_,
        label    = "Home Spawning Grounds \U0001f3c6",
        phase    = "return"
      )
      next
    }

    mort <- MORTALITY[[stn]]
    if (is.null(mort)) {
      # Station in sequence but no mortality defined — pass through
      rows[[stn]] <- tibble::tibble(
        station  = stn,
        n_arrive = n,
        n_killed = 0L,
        cause    = NA_character_,
        label    = STATIONS$label[STATIONS$id == stn][1] %||% stn,
        phase    = dplyr::case_when(
          stn %in% STATIONS_OUTBOUND ~ "outbound",
          stn %in% STATIONS_OCEAN   ~ "ocean",
          TRUE                      ~ "return"
        )
      )
      next
    }

    # Apply mortality — add small random variance (+/- 15%) to keep replays fresh
    base_kill <- mort$kill
    variance  <- round(base_kill * runif(1, -0.15, 0.15))
    n_killed  <- max(0L, min(n, as.integer(base_kill + variance)))
    n         <- max(0L, n - n_killed)

    rows[[stn]] <- tibble::tibble(
      station  = stn,
      n_arrive = n + n_killed,   # fish when arriving (before kill)
      n_killed = n_killed,
      cause    = mort$cause,
      label    = mort$label,
      phase    = dplyr::case_when(
        stn %in% STATIONS_OUTBOUND ~ "outbound",
        stn %in% STATIONS_OCEAN   ~ "ocean",
        TRUE                      ~ "return"
      )
    )
  }

  dplyr::bind_rows(rows)
}