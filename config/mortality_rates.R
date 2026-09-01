# ══════════════════════════════════════════════════════════════════════════════
# config/mortality_rates.R
# ALL tunable game parameters — edit here to adjust difficulty
# ══════════════════════════════════════════════════════════════════════════════

COHORT_START     <- 500
PREGAME_BONUS_PER_Q <- 25

# ── Mortality kills per station ───────────────────────────────────────────────
# Based on real Walla Walla data scaled to 500 fish
# Edit these numbers to tune difficulty
MORTALITY <- list(
  # Outbound
  lower_ww         = list(kill = 40,  cause = "predator_bass",    label = "Bass Predation"),
  crescent_island  = list(kill = 80,  cause = "avian_cormorant",  label = "Avian Predation"),
  lake_wallula     = list(kill = 60,  cause = "pikeminnow",       label = "Mixed Predation"),
  mcnary_juv       = list(kill = 70,  cause = "dam_mcnary",       label = "Dam Mortality"),
  blalock_islands  = list(kill = 50,  cause = "avian_tern",       label = "Tern Colony"),
  lake_umatilla    = list(kill = 40,  cause = "pikeminnow",       label = "Reservoir Predation"),
  johnday_juv      = list(kill = 55,  cause = "dam_john_day",     label = "Dam Mortality"),
  miller_rocks     = list(kill = 30,  cause = "avian_cormorant",  label = "Gull Colony"),
  lake_celilo      = list(kill = 25,  cause = "pikeminnow",       label = "Reservoir Predation"),
  thedalles_juv    = list(kill = 40,  cause = "dam_thedalles",    label = "Dam Mortality"),
  lake_bonneville  = list(kill = 20,  cause = "predator_bass",    label = "Reservoir Predation"),
  bonneville_juv   = list(kill = 15,  cause = "dam_bonneville",   label = "Dam Mortality"),
  estuary          = list(kill = 7,   cause = "avian_tern",       label = "Estuary Predation"),
  # Ocean
  ocean_orca       = list(kill = 5,   cause = "ocean_orca",       label = "Orca Predation"),
  ocean_fishing    = list(kill = 8,   cause = "ocean_harvest",    label = "Commercial Fishing"),
  # Adult return
  adult_fishing    = list(kill = 2,   cause = "ocean_harvest",    label = "Sport Fishing"),
  adult_sealion    = list(kill = 1,   cause = "sealion",          label = "Sea Lion Predation"),
  adult_warmwater  = list(kill = 1,   cause = "temperature",      label = "Warm Water Stress"),
  adult_dams       = list(kill = 1,   cause = "dam_bonneville",   label = "Adult Dam Passage"),
  adult_tire       = list(kill = 2,   cause = "tire_chemical",    label = "Tire Chemical 6PPD"),
  adult_agrunoff   = list(kill = 1,   cause = "ag_runoff",        label = "Agricultural Runoff")
)

# ── Death screen images ───────────────────────────────────────────────────────
# Replace URLs with local paths once artist delivers PNGs:
#   e.g. "death_screens/avian_pelican.png"
DEATH_IMAGES <- list(
  avian_pelican   = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Pelecanus_occidentalis_-Morro_Bay%2C_California%2C_USA-8.jpg/640px-Pelecanus_occidentalis_-Morro_Bay%2C_California%2C_USA-8.jpg",
  avian_merganser = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Mergus-merganser-001.jpg/640px-Mergus-merganser-001.jpg",
  avian_tern      = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Caspian_Tern_Hydroprogne_caspia.jpg/640px-Caspian_Tern_Hydroprogne_caspia.jpg",
  avian_cormorant = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Double-crested_Cormorant.jpg/640px-Double-crested_Cormorant.jpg",
  dam_mcnary      = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/McNary_Dam.jpg/640px-McNary_Dam.jpg",
  dam_john_day    = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/John_Day_Dam.jpg/640px-John_Day_Dam.jpg",
  dam_thedalles   = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/The_Dalles_Dam.jpg/640px-The_Dalles_Dam.jpg",
  dam_bonneville  = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Bonneville_Dam_from_Washington_state_side.jpg/640px-Bonneville_Dam_from_Washington_state_side.jpg",
  pikeminnow      = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Ptychocheilus_oregonensis.jpg/640px-Ptychocheilus_oregonensis.jpg",
  predator_bass   = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Smallmouth_bass_jack_Dempsey.jpg/640px-Smallmouth_bass_jack_Dempsey.jpg",
  sealion         = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/California_sea_lion_-_Flickr_-_GregTheBusker.jpg/640px-California_sea_lion_-_Flickr_-_GregTheBusker.jpg",
  ocean_harvest   = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Gili_Air_-_Fishing_nets.jpg/640px-Gili_Air_-_Fishing_nets.jpg",
  ocean_orca      = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Killerwhales_jumping.jpg/640px-Killerwhales_jumping.jpg",
  temperature     = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Drought_fish_kill.jpg/640px-Drought_fish_kill.jpg",
  tire_chemical   = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Tire_track_in_mud.jpg/640px-Tire_track_in_mud.jpg",
  ag_runoff       = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Algal_bloom_lake_erie_2011.jpg/640px-Algal_bloom_lake_erie_2011.jpg",
  win_spawning    = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Chinook_Salmon_Adult_Male.jpg/640px-Chinook_Salmon_Adult_Male.jpg",
  placeholder     = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Gatto_europeo4.jpg/320px-Gatto_europeo4.jpg"
)

# ── Death narratives ──────────────────────────────────────────────────────────
# {n} replaced with number killed, {remaining} with survivors
DEATH_NARRATIVES <- list(
  avian_pelican   = "A flock of American White Pelicans was waiting. {n} of your fish never saw them coming.",
  avian_merganser = "Common Mergansers patrol every riffle. {n} fish were picked off before they could react.",
  avian_tern      = "Caspian Terns dove from above. {n} of your fish were taken at the surface.",
  avian_cormorant = "Double-crested Cormorants are relentless divers. {n} of your fish were taken from below.",
  dam_mcnary      = "{n} fish were killed or injured passing through McNary Dam's turbines.",
  dam_john_day    = "John Day Reservoir's slow warm water weakened your fish. {n} did not survive the dam.",
  dam_thedalles   = "{n} fish were lost at The Dalles Dam — built in 1957, it flooded the sacred fishing site at Celilo Falls.",
  dam_bonneville  = "{n} fish were lost at Bonneville Dam — the first major Columbia River dam, built in 1938.",
  pikeminnow      = "Northern Pikeminnow lurk at every dam tailrace. {n} juvenile salmon became a meal.",
  predator_bass   = "Smallmouth Bass thrive in the warm reservoir water created by dams. They weren't here before. {n} fish lost.",
  sealion         = "California Sea Lions have learned to wait below Bonneville Dam. {n} returning adults were taken.",
  ocean_harvest   = "{n} of your fish were caught by commercial fishing vessels in the Pacific.",
  ocean_orca      = "Southern Resident Orcas depend almost entirely on Chinook salmon to survive. {n} fish were taken — a reminder that salmon feed more than just people.",
  temperature     = "Water temperatures in the reservoir exceeded 68°F — lethal for salmon. {n} fish died of thermal stress.",
  tire_chemical   = "{n} adult fish were killed by 6PPD-quinone — a chemical from tire rubber that washes off roads during rain. Identified by UW researchers in 2020. No fix yet at scale.",
  ag_runoff       = "{n} fish were killed by agricultural runoff — pesticides, excess nutrients, and sediment from irrigation returns reduce dissolved oxygen and poison fish directly.",
  supersaturation = "Spill at the dam caused nitrogen supersaturation — like the bends in scuba diving. {n} fish died.",
  other           = "{n} fish were lost to unknown causes — a reminder of how much we still don't know."
)

# ── Win condition ─────────────────────────────────────────────────────────────
WIN_MINIMUM <- 1