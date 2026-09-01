# ══════════════════════════════════════════════════════════════════════════════
# data/sites.R
# Station order, coordinates, and metadata
# ══════════════════════════════════════════════════════════════════════════════

# ── Random start locations ────────────────────────────────────────────────────
START_LOCATIONS <- list(
  list(
    id      = "sfww",
    label   = "South Fork Walla Walla River",
    lat     = 45.9738, lon = -118.0207,
    flavor  = "You hatched in the cold gravel of the South Fork Walla Walla River. The water is clear and cold. You have spent two years growing strong."
  ),
  list(
    id      = "burlingame",
    label   = "Burlingame Dam Pool",
    lat     = 46.0631, lon = -118.3819,
    flavor  = "You grew up in the deep pool below Burlingame Dam. The concrete structure looms above you. Today you feel the urge to move."
  ),
  list(
    id      = "nursery",
    label   = "Nursery Bridge",
    lat     = 46.0100, lon = -118.3500,
    flavor  = "Nursery Bridge pool has been your home for two winters. The days are getting longer. Something tells you it is time to go."
  )
)

# ── All stations in order ─────────────────────────────────────────────────────
STATIONS <- tibble::tribble(
  ~id,                   ~label,                          ~lat,      ~lon,       ~rkm,   ~type,      ~river,
  # Outbound
  "lower_ww",            "Lower Walla Walla River",       46.0571,  -118.8705,   NA,    "predation", "Walla Walla",
  "crescent_island",     "Crescent Island",               46.0934,  -118.9310,   NA,    "predation", "Snake",
  "lake_wallula",        "Lake Wallula",                  46.0023,  -118.9871,   NA,    "predation", "Snake/Columbia",
  "quiz_1",              "Conservation Stop #1",          46.0000,  -119.1000,   NA,    "quiz",      NA,
  "mcnary_juv",          "McNary Dam",                    45.9342,  -119.2968,   469,   "dam",       "Columbia",
  "blalock_islands",     "Blalock Islands",               45.9125,  -119.6245,   NA,    "predation", "Columbia",
  "lake_umatilla",       "Lake Umatilla",                 45.8472,  -119.7431,   NA,    "predation", "Columbia",
  "quiz_2",              "Conservation Stop #2",          45.8000,  -120.0000,   NA,    "quiz",      NA,
  "johnday_juv",         "John Day Dam",                  45.7155,  -120.6932,   347,   "dam",       "Columbia",
  "miller_rocks",        "Miller Rocks Islands",          45.6544,  -120.8968,   NA,    "predation", "Columbia",
  "lake_celilo",         "Lake Celilo",                   45.6561,  -120.9421,   NA,    "predation", "Columbia",
  "quiz_3",              "Conservation Stop #3",          45.6300,  -121.0500,   NA,    "quiz",      NA,
  "thedalles_juv",       "The Dalles Dam",                45.6142,  -121.1347,   307,   "dam",       "Columbia",
  "lake_bonneville",     "Lake Bonneville",               45.7205,  -121.5253,   NA,    "predation", "Columbia",
  "bonneville_juv",      "Bonneville Dam",                45.6432,  -121.9408,   234,   "dam",       "Columbia",
  "estuary",             "Columbia River Estuary",        46.2500,  -123.9000,   0,     "estuary",   "Columbia",
  # Ocean
  "ocean_orca",          "Pacific Ocean — Orca",          46.5000,  -124.8000,   NA,    "ocean",     "Pacific",
  "ocean_fishing",       "Pacific Ocean — Fishing",       46.8000,  -125.5000,   NA,    "ocean",     "Pacific",
  "ocean_end",           "Pacific Ocean — Years Pass...", 47.0000,  -126.0000,   NA,    "ocean",     "Pacific",
  # Adult return
  "adult_fishing",       "Adult Return — Sport Fishing",  46.2500,  -123.5000,   NA,    "predation", "Columbia",
  "adult_sealion",       "Bonneville — Sea Lion Gauntlet",45.6432,  -121.9408,   234,   "predation", "Columbia",
  "adult_warmwater",     "Warm Water Migration",          45.8000,  -120.5000,   NA,    "hazard",    "Columbia",
  "adult_dams",          "Adult Dam Passage",             45.9000,  -119.5000,   NA,    "dam",       "Columbia",
  "adult_tire",          "Tire Chemical / 6PPD Runoff",   46.0200,  -118.9000,   NA,    "hazard",    "Walla Walla",
  "adult_agrunoff",      "Agricultural Runoff",           46.0400,  -118.6000,   NA,    "hazard",    "Walla Walla",
  "home",                "Home Spawning Grounds 🏆",      NA,        NA,          NA,    "spawning",  "Walla Walla"
)

# ── Station sequences ─────────────────────────────────────────────────────────
STATIONS_OUTBOUND <- c(
  "lower_ww", "crescent_island", "lake_wallula",
  "quiz_1",
  "mcnary_juv", "blalock_islands", "lake_umatilla",
  "quiz_2",
  "johnday_juv", "miller_rocks", "lake_celilo",
  "quiz_3",
  "thedalles_juv", "lake_bonneville", "bonneville_juv",
  "estuary"
)

STATIONS_OCEAN <- c(
  "ocean_orca", "ocean_fishing", "ocean_end"
)

STATIONS_RETURN <- c(
  "adult_fishing", "adult_sealion", "adult_warmwater",
  "adult_dams", "adult_tire", "adult_agrunoff",
  "home"
)

# ── Avian predation hotspots (from KMZ) ───────────────────────────────────────
AVIAN_HOTSPOTS <- tibble::tribble(
  ~name,                          ~lat,      ~lon,      ~radius_m, ~species,
  "Alpowa Creek Mouth",           46.4157,  -117.2084,  800,       "Pelicans",
  "Lower Tucannon River",         46.5527,  -118.1766,  1200,      "Walleye, Bass, Pikeminnow",
  "Lower Walla Walla River",      46.0571,  -118.8705,  1500,      "Bass",
  "Lake Wallula",                 46.0023,  -118.9871,  3000,      "Walleye, Pikeminnow, Bass, Birds",
  "McNary Dam",                   45.9342,  -119.2968,  800,       "Dam + Predators",
  "Lake Umatilla",                45.8472,  -119.7431,  2500,      "Walleye, Pikeminnow, Bass, Birds",
  "John Day Dam",                 45.7155,  -120.6932,  800,       "Dam + Predators",
  "The Dalles Dam",               45.6142,  -121.1347,  800,       "Dam + Predators",
  "Bonneville Dam",               45.6432,  -121.9408,  800,       "Dam + Sea Lions",
  "Lake Bonneville",              45.7205,  -121.5253,  2000,      "Birds, Pikeminnow, Bass",
  "Lake Celilo",                  45.6561,  -120.9421,  2000,      "Pikeminnow, Bass",
  "Bonneville to Estuary",        45.6191,  -121.9929,  1500,      "Sea Lions, Birds",
  "Crescent Island",              46.0934,  -118.9310,  1000,      "Terns, Cormorants, Gulls, Pelicans",
  "Blalock Islands",              45.9125,  -119.6245,  1000,      "Tern colonies",
  "Miller Rocks Islands",         45.6544,  -120.8968,  1000,      "Gull colonies"
)