# ══════════════════════════════════════════════════════════════════════════════
# R/simulate_cohort.R
# Cohort simulation engine — generates a new game run based on real survival
# rates from config/mortality_rates.R, scaled to COHORT_START fish
# ══════════════════════════════════════════════════════════════════════════════

library(dplyr)

# ── Apply one segment of mortality ───────────────────────────────────────────
# Returns list(survivors, killed, cause, n_killed)
apply_segment_mortality <- function(n_alive, survival_rate, mortality_key) {
  n_survive  <- max(0, round(n_alive * survival_rate))
  n_killed   <- n_alive - n_survive

  # Pick a cause weighted by MORTALITY_CAUSES
  causes     <- MORTALITY_CAUSES[[mortality_key]]
  if (is.null(causes) || n_killed == 0) {
    cause <- "other"
  } else {
    cause <- sample(names(causes), 1, prob = unlist(causes))
  }

  list(
    survivors = n_survive,
    n_killed  = n_killed,
    cause     = cause
  )
}

# ── Run a full cohort simulation ──────────────────────────────────────────────
# Returns a tibble with one row per station showing fish counts + mortality
simulate_cohort <- function(cohort_size = COHORT_START,
                            use_real_rates = TRUE,
                            seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  rate_type <- if (use_real_rates) "real" else "simulated"

  # Helper to get survival rate
  get_rate <- function(key) {
    r <- SURVIVAL[[key]][[rate_type]]
    if (is.na(r)) SURVIVAL[[key]][["simulated"]] else r
  }

  results <- list()
  n <- cohort_size

  # ── OUTBOUND ────────────────────────────────────────────────────────────────
  results[["release"]] <- list(
    station   = "release",
    phase     = "outbound",
    n_arrive  = n,
    n_killed  = 0,
    cause     = NA_character_,
    label     = "Release Site — South Fork Walla Walla"
  )

  # Release → McNary
  seg <- apply_segment_mortality(n, get_rate("release_to_mcnary"), "release_to_mcnary")
  n   <- seg$survivors
  results[["mcnary_juv"]] <- list(
    station  = "mcnary_juv",
    phase    = "outbound",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "McNary Dam — Juvenile Detection"
  )

  # McNary → John Day
  seg <- apply_segment_mortality(n, get_rate("mcnary_to_johnday"), "mcnary_to_johnday")
  n   <- seg$survivors
  results[["johnday_juv"]] <- list(
    station  = "johnday_juv",
    phase    = "outbound",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "John Day Dam — Juvenile Detection"
  )

  # John Day → Bonneville
  seg <- apply_segment_mortality(n, get_rate("johnday_to_bonneville"), "johnday_to_bonneville")
  n   <- seg$survivors
  results[["bonneville_juv"]] <- list(
    station  = "bonneville_juv",
    phase    = "outbound",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "Bonneville Dam — Juvenile Detection"
  )

  # Bonneville → Estuary
  seg <- apply_segment_mortality(n, get_rate("bonneville_to_estuary"), "bonneville_to_estuary")
  n   <- seg$survivors
  results[["estuary"]] <- list(
    station  = "estuary",
    phase    = "outbound",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "Columbia River Estuary"
  )

  # Estuary → Ocean
  seg <- apply_segment_mortality(n, get_rate("estuary_to_ocean"), "estuary")
  n   <- seg$survivors

  # ── OCEAN PHASE with random events ──────────────────────────────────────────
  ocean_events_hit <- list()
  for (ev in OCEAN_EVENTS) {
    if (runif(1) < ev$prob) {
      if (ev$kill_pct > 0) {
        killed <- round(n * ev$kill_pct)
        n      <- max(0, n - killed)
      } else {
        # Bonus survival
        bonus  <- round(n * abs(ev$kill_pct))
        n      <- n + bonus
        killed <- -bonus
      }
      ocean_events_hit[[length(ocean_events_hit) + 1]] <- list(
        event   = ev,
        n_killed = killed
      )
    }
  }

  results[["ocean"]] <- list(
    station      = "ocean",
    phase        = "ocean",
    n_arrive     = n,
    n_killed     = 0,
    cause        = NA_character_,
    label        = "Pacific Ocean — 1 to 3 Years at Sea",
    ocean_events = ocean_events_hit
  )

  # ── RETURN ──────────────────────────────────────────────────────────────────

  # Ocean → Bonneville Adult
  seg <- apply_segment_mortality(n, get_rate("ocean_survival") * cohort_size / max(n, 1),
                                  "ocean")
  # Use SAR directly for ocean leg
  n_adult <- max(0, round(cohort_size * get_rate("ocean_survival")))
  n <- n_adult

  results[["bonneville_adult"]] <- list(
    station  = "bonneville_adult",
    phase    = "return",
    n_arrive = n,
    n_killed = 0,
    cause    = NA_character_,
    label    = "Bonneville Dam — Adult Fish Ladder"
  )

  # Bonneville → The Dalles
  seg <- apply_segment_mortality(n, get_rate("bonneville_to_thedalles"), "adult_return")
  n   <- seg$survivors
  results[["thedalles_adult"]] <- list(
    station  = "thedalles_adult",
    phase    = "return",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "The Dalles Dam — Adult Fish Ladder"
  )

  # The Dalles → John Day
  seg <- apply_segment_mortality(n, get_rate("thedalles_to_johnday"), "adult_return")
  n   <- seg$survivors
  results[["johnday_adult"]] <- list(
    station  = "johnday_adult",
    phase    = "return",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "John Day Dam — Adult Fish Ladder"
  )

  # John Day → McNary
  seg <- apply_segment_mortality(n, get_rate("johnday_to_mcnary"), "adult_return")
  n   <- seg$survivors
  results[["mcnary_adult"]] <- list(
    station  = "mcnary_adult",
    phase    = "return",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "McNary Dam — Adult Fish Ladder"
  )

  # McNary → Burlingame
  seg <- apply_segment_mortality(n, get_rate("mcnary_to_burlingame"), "adult_return")
  n   <- seg$survivors
  results[["burlingame"]] <- list(
    station  = "burlingame",
    phase    = "return",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "Burlingame Dam — Walla Walla River"
  )

  # Burlingame → Nursery Bridge
  seg <- apply_segment_mortality(n, get_rate("burlingame_to_nursery"), "adult_return")
  n   <- seg$survivors
  results[["nursery_bridge"]] <- list(
    station  = "nursery_bridge",
    phase    = "return",
    n_arrive = n,
    n_killed = seg$n_killed,
    cause    = seg$cause,
    label    = "Nursery Bridge — Home Spawning Grounds 🏆"
  )

  # Convert to tibble
  dplyr::bind_rows(lapply(results, function(r) {
    tibble::tibble(
      station  = r$station,
      phase    = r$phase,
      n_arrive = r$n_arrive,
      n_killed = r$n_killed,
      cause    = r$cause %||% NA_character_,
      label    = r$label
    )
  }))
}
