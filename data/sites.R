# ══════════════════════════════════════════════════════════════════════════════
# data/sites.R
# Detection station metadata — coordinates, names, river km, type
# Add new stations here without touching any other file
# ══════════════════════════════════════════════════════════════════════════════

STATIONS <- tibble::tribble(
  ~id,                  ~label,                              ~lat,      ~lon,       ~rkm,  ~type,      ~river,
  # Release site
  "release",            "South Fork Walla Walla River",      45.9738,  -118.0207,  1050,  "release",  "Walla Walla",
  # Four Lower Snake River Dams (simulated — no PIT detections in your CSV)
  "iceharbor_juv",      "Ice Harbor Dam (Juvenile)",         46.2480,  -118.8760,   539,  "dam",      "Snake",
  "lowermon_juv",       "Lower Monumental Dam (Juvenile)",   46.5620,  -118.5370,   592,  "dam",      "Snake",
  "littlegoose_juv",    "Little Goose Dam (Juvenile)",       46.5870,  -118.0280,   638,  "dam",      "Snake",
  "lowergranite_juv",   "Lower Granite Dam (Juvenile)",      46.6600,  -117.4300,   695,  "dam",      "Snake",
  # Columbia River dams (real PIT data from your CSV)
  "mcnary_juv",         "McNary Dam (Juvenile)",             45.9294,  -119.2982,   469,  "dam",      "Columbia",
  "johnday_juv",        "John Day Dam (Juvenile)",           45.7154,  -120.6953,   347,  "dam",      "Columbia",
  "bonneville_juv",     "Bonneville Dam (Juvenile)",         45.6441,  -121.9408,   234,  "dam",      "Columbia",
  "estuary",            "Columbia River Estuary",            46.2500,  -123.9000,     0,  "estuary",  "Columbia",
  "ocean",              "Pacific Ocean",                     46.5000,  -124.5000,    NA,  "ocean",    "Pacific",
  # Adult return — Columbia
  "bonneville_adult",   "Bonneville Dam (Adult Ladder)",     45.6441,  -121.9408,   234,  "dam",      "Columbia",
  "thedalles_adult",    "The Dalles Dam (Adult Ladder)",     45.6044,  -121.1317,   307,  "dam",      "Columbia",
  "johnday_adult",      "John Day Dam (Adult Ladder)",       45.7154,  -120.6953,   347,  "dam",      "Columbia",
  "mcnary_adult",       "McNary Dam (Adult Ladder)",         45.9294,  -119.2982,   469,  "dam",      "Columbia",
  # Adult return — Four Lower Snake River Dams
  "iceharbor_adult",    "Ice Harbor Dam (Adult Ladder)",     46.2480,  -118.8760,   539,  "dam",      "Snake",
  "lowermon_adult",     "Lower Monumental Dam (Adult)",      46.5620,  -118.5370,   592,  "dam",      "Snake",
  "littlegoose_adult",  "Little Goose Dam (Adult Ladder)",   46.5870,  -118.0280,   638,  "dam",      "Snake",
  "lowergranite_adult", "Lower Granite Dam (Adult Ladder)",  46.6600,  -117.4300,   695,  "dam",      "Snake",
  # Home watershed
  "burlingame",         "Burlingame Dam — Walla Walla R.",   46.0631,  -118.3819,   530,  "weir",     "Walla Walla",
  "nursery_bridge",     "Nursery Bridge — Home! 🏆",         46.0100,  -118.3500,   560,  "spawning", "Walla Walla"
)

# ── Avian predation hotspot zones (from KMZ — replaced by parse_data.R) ───────
AVIAN_HOTSPOTS_DEFAULT <- tibble::tribble(
  ~name,                        ~lat,      ~lon,      ~radius_m, ~species,
  "East Sand Island Terns",     46.2641,  -123.9731,  2000,      "Caspian Tern",
  "Crescent Island Cormorants", 46.0000,  -119.0000,  1500,      "Double-crested Cormorant",
  "Walla Walla Pelicans",       46.1000,  -118.5000,  1000,      "American White Pelican",
  "McNary Tailrace Birds",      45.9294,  -119.2982,   800,      "Mixed Avian"
)

# ── Station order — outbound then return ──────────────────────────────────────
STATIONS_OUTBOUND <- c(
  "release",
  "iceharbor_juv", "lowermon_juv", "littlegoose_juv", "lowergranite_juv",
  "mcnary_juv", "johnday_juv", "bonneville_juv",
  "estuary", "ocean"
)

STATIONS_RETURN <- c(
  "bonneville_adult", "thedalles_adult", "johnday_adult", "mcnary_adult",
  "iceharbor_adult", "lowermon_adult", "littlegoose_adult", "lowergranite_adult",
  "burlingame", "nursery_bridge"
)

# ── Segment definitions ───────────────────────────────────────────────────────
SEGMENTS <- tibble::tribble(
  ~from,                ~to,                  ~mortality_key,             ~phase,     ~has_real_data,
  "release",            "iceharbor_juv",      "release_to_snake",         "outbound", FALSE,
  "iceharbor_juv",      "lowermon_juv",       "snake_dam",                "outbound", FALSE,
  "lowermon_juv",       "littlegoose_juv",    "snake_dam",                "outbound", FALSE,
  "littlegoose_juv",    "lowergranite_juv",   "snake_dam",                "outbound", FALSE,
  "lowergranite_juv",   "mcnary_juv",         "snake_to_mcnary",          "outbound", FALSE,
  "mcnary_juv",         "johnday_juv",        "mcnary_to_johnday",        "outbound", TRUE,
  "johnday_juv",        "bonneville_juv",     "johnday_to_bonneville",    "outbound", TRUE,
  "bonneville_juv",     "estuary",            "bonneville_to_estuary",    "outbound", TRUE,
  "estuary",            "ocean",              "estuary",                  "outbound", TRUE,
  "ocean",              "bonneville_adult",   "ocean",                    "return",   TRUE,
  "bonneville_adult",   "thedalles_adult",    "adult_return",             "return",   TRUE,
  "thedalles_adult",    "johnday_adult",      "adult_return",             "return",   TRUE,
  "johnday_adult",      "mcnary_adult",       "adult_return",             "return",   TRUE,
  "mcnary_adult",       "iceharbor_adult",    "adult_snake_return",       "return",   FALSE,
  "iceharbor_adult",    "lowermon_adult",     "adult_snake_return",       "return",   FALSE,
  "lowermon_adult",     "littlegoose_adult",  "adult_snake_return",       "return",   FALSE,
  "littlegoose_adult",  "lowergranite_adult", "adult_snake_return",       "return",   FALSE,
  "lowergranite_adult", "burlingame",         "adult_snake_return",       "return",   FALSE,
  "burlingame",         "nursery_bridge",     "adult_return",             "return",   TRUE
)
