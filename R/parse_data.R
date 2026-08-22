# ══════════════════════════════════════════════════════════════════════════════
# R/parse_data.R
# Load and clean the real 500-fish cohort CSV and avian hotspot KMZ
# ══════════════════════════════════════════════════════════════════════════════

library(dplyr)
library(lubridate)
library(janitor)
library(readxl)

# ── Load 500-fish cohort CSV ──────────────────────────────────────────────────
load_cohort_csv <- function(path = NULL) {
  # Accept xlsx or csv — auto-detect
  if (is.null(path)) {
    if (file.exists("data/walla_walla_500.xlsx")) {
      path <- "data/walla_walla_500.xlsx"
    } else if (file.exists("data/walla_walla_500.csv")) {
      path <- "data/walla_walla_500.csv"
    } else {
      message("⚠️  No cohort data file found in data/ — using simulated data")
      return(NULL)
    }
  }

  if (!file.exists(path)) {
    message("⚠️  Cohort file not found at: ", path, " — using simulated data")
    return(NULL)
  }

  message("Loading cohort data from: ", path)

  ext <- tools::file_ext(path)
  df <- if (ext == "xlsx") {
    readxl::read_excel(path) |> janitor::clean_names()
  } else {
    readr::read_csv(path, show_col_types = FALSE) |> janitor::clean_names()
  }

  # Standardize datetime columns
  dt_cols <- c(
    "release_date_mmddyyyy", "walla_walla_barge",
    "mcnary_juvenile", "john_day_juvenile", "bonneville_juvenile",
    "estuary_detectors", "avian_mortality",
    "bonneville_adult", "the_dalles_adult", "john_day_adult",
    "mcnary_adult", "burlingame", "nursery_bridge"
  )

  for (col in dt_cols) {
    if (col %in% names(df)) {
      df[[col]] <- lubridate::as_datetime(df[[col]])
    }
  }

  df
}

# ── Compute real attrition counts from cohort CSV ────────────────────────────
compute_real_counts <- function(df) {
  if (is.null(df)) return(NULL)

  tibble::tibble(
    station        = c("release", "mcnary_juv", "johnday_juv",
                       "bonneville_juv", "estuary", "avian_kill",
                       "bonneville_adult", "thedalles_adult",
                       "johnday_adult", "mcnary_adult",
                       "burlingame", "nursery_bridge"),
    real_count     = c(
      nrow(df),
      sum(!is.na(df$mcnary_juvenile)),
      sum(!is.na(df$john_day_juvenile)),
      sum(!is.na(df$bonneville_juvenile)),
      sum(!is.na(df$estuary_detectors)),
      sum(!is.na(df$avian_mortality)),
      sum(!is.na(df$bonneville_adult)),
      sum(!is.na(df$the_dalles_adult)),
      sum(!is.na(df$john_day_adult)),
      sum(!is.na(df$mcnary_adult)),
      sum(!is.na(df$burlingame)),
      sum(!is.na(df$nursery_bridge))
    )
  )
}

# ── Load avian hotspot KMZ ────────────────────────────────────────────────────
load_avian_kmz <- function(path = "data/hotspots.kmz") {
  if (!file.exists(path)) {
    message("⚠️  KMZ not found at: ", path, " — using default hotspots")
    return(AVIAN_HOTSPOTS_DEFAULT)
  }

  tryCatch({
    # KMZ is a zipped KML — extract and parse
    tmp <- tempdir()
    utils::unzip(path, exdir = tmp)
    kml_file <- list.files(tmp, pattern = "\\.kml$", full.names = TRUE)[1]

    kml <- xml2::read_xml(kml_file)
    ns  <- xml2::xml_ns(kml)

    placemarks <- xml2::xml_find_all(kml, ".//d1:Placemark", ns)

    purrr::map_dfr(placemarks, function(p) {
      name   <- xml2::xml_text(xml2::xml_find_first(p, ".//d1:name", ns))
      coords <- xml2::xml_text(xml2::xml_find_first(p, ".//d1:coordinates", ns))
      coords <- trimws(coords)
      parts  <- strsplit(coords, ",")[[1]]
      tibble::tibble(
        name      = name,
        lon       = as.numeric(parts[1]),
        lat       = as.numeric(parts[2]),
        radius_m  = 1000,
        species   = "Avian Predator"
      )
    })
  }, error = function(e) {
    message("⚠️  KMZ parse error: ", conditionMessage(e), " — using defaults")
    AVIAN_HOTSPOTS_DEFAULT
  })
}