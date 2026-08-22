# ══════════════════════════════════════════════════════════════════════════════
# config/mortality_rates.R
# ALL tunable game parameters live here — edit this file to adjust difficulty,
# mortality causes, death screen images, and narrative text.
# ══════════════════════════════════════════════════════════════════════════════

COHORT_START <- 500

# ── Real survival rates from Walla Walla 500-fish cohort ─────────────────────
# To adjust difficulty, change the `simulated` values only.
# Leave `real` values as-is — they're ground truth.
SURVIVAL <- list(
  # Snake River dams (simulated — no PIT detections in Walla Walla CSV)
  # Per-dam survival ~0.90-0.93 based on published literature
  release_to_iceharbor   = list(real = NA,        simulated = 0.70),  # tributary to Ice Harbor
  iceharbor_to_lowermon  = list(real = NA,        simulated = 0.92),  # per dam ~8% mortality
  lowermon_to_littlegoose= list(real = NA,        simulated = 0.92),
  littlegoose_to_lowergranite = list(real = NA,   simulated = 0.92),
  lowergranite_to_mcnary = list(real = NA,        simulated = 0.88),  # LGR + travel to McNary
  release_to_mcnary      = list(real = 124/500,  simulated = 124/500),
  mcnary_to_johnday      = list(real = 17/124,   simulated = 17/124),
  johnday_to_bonneville  = list(real = 167/17,   simulated = 0.85),   # detection gap — use simulated
  bonneville_to_estuary  = list(real = 7/167,    simulated = 7/167),
  estuary_to_ocean       = list(real = NA,        simulated = 0.80),
  ocean_survival         = list(real = 5/500,    simulated = 5/500),   # SAR
  bonneville_to_thedalles = list(real = 3/5,     simulated = 3/5),
  thedalles_to_johnday   = list(real = 3/3,      simulated = 0.95),
  johnday_to_mcnary      = list(real = 3/3,      simulated = 0.95),
  mcnary_to_burlingame   = list(real = 1/3,      simulated = 1/3),
  burlingame_to_nursery  = list(real = 1/1,      simulated = 0.90),
  # Adult Snake River dam passage (simulated)
  adult_lowergranite_to_lowermon = list(real = NA, simulated = 0.93),
  adult_lowermon_to_littlegoose  = list(real = NA, simulated = 0.93),
  adult_littlegoose_to_iceharbor = list(real = NA, simulated = 0.93),
  adult_iceharbor_to_mcnary      = list(real = NA, simulated = 0.93)
)

# ── Mortality cause weights per segment ───────────────────────────────────────
# Must sum to 1.0 per segment.
# These drive which death screen is shown and the narrative text.
MORTALITY_CAUSES <- list(

  release_to_snake = list(
    avian_pelican    = 0.35,
    avian_merganser  = 0.25,
    pikeminnow       = 0.20,
    temperature      = 0.10,
    stranding        = 0.10
  ),

  snake_dam = list(
    dam_lower_granite = 0.35,  # turbine strike, bypass mortality
    pikeminnow        = 0.30,  # tailrace predation
    avian_cormorant   = 0.20,
    supersaturation   = 0.10,
    other             = 0.05
  ),

  snake_to_mcnary = list(
    pikeminnow       = 0.35,
    avian_cormorant  = 0.30,
    temperature      = 0.20,
    other            = 0.15
  ),

  adult_snake_return = list(
    sealion          = 0.20,
    dam_lower_granite = 0.30,
    harvest          = 0.25,
    avian_tern       = 0.10,
    other            = 0.15
  ),

  release_to_mcnary = list(
    avian_pelican    = 0.30,
    avian_merganser  = 0.20,
    pikeminnow       = 0.20,
    temperature      = 0.15,
    stranding        = 0.10,
    other            = 0.05
  ),

  mcnary_to_johnday = list(
    dam_mcnary       = 0.30,
    pikeminnow       = 0.25,
    avian_cormorant  = 0.20,
    temperature      = 0.15,
    supersaturation  = 0.10
  ),

  johnday_to_bonneville = list(
    dam_john_day     = 0.35,
    pikeminnow       = 0.25,
    avian_cormorant  = 0.20,
    temperature      = 0.15,
    supersaturation  = 0.05
  ),

  bonneville_to_estuary = list(
    dam_bonneville   = 0.30,
    avian_tern       = 0.35,   # Caspian terns peak near Bonneville
    predator_bass    = 0.20,
    sealion          = 0.15
  ),

  estuary = list(
    avian_tern       = 0.40,   # East Sand Island tern colony
    avian_cormorant  = 0.25,
    sealion          = 0.20,
    other            = 0.15
  ),

  ocean = list(
    ocean_harvest    = 0.30,
    ocean_orca       = 0.20,
    ocean_warmblob   = 0.25,
    ocean_shark      = 0.15,
    other            = 0.10
  ),

  adult_return = list(
    sealion          = 0.30,   # Bonneville tailrace sea lions
    avian_tern       = 0.15,
    dam_passage      = 0.25,
    harvest          = 0.20,
    other            = 0.10
  )
)

# ── Death screen image map ────────────────────────────────────────────────────
# key = mortality cause code, value = filename in www/death_screens/
# Replace placeholder URLs with local paths once artist delivers PNGs:
#   e.g. "www/death_screens/avian_pelican.png"
DEATH_IMAGES <- list(
  avian_pelican   = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Pelecanus_occidentalis_-Morro_Bay%2C_California%2C_USA-8.jpg/640px-Pelecanus_occidentalis_-Morro_Bay%2C_California%2C_USA-8.jpg",
  avian_merganser = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Mergus-merganser-001.jpg/640px-Mergus-merganser-001.jpg",
  avian_tern      = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Caspian_Tern_Hydroprogne_caspia.jpg/640px-Caspian_Tern_Hydroprogne_caspia.jpg",
  avian_cormorant = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Double-crested_Cormorant.jpg/640px-Double-crested_Cormorant.jpg",
  dam_lower_granite = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Lower_Granite_Dam.jpg/640px-Lower_Granite_Dam.jpg",
  dam_mcnary      = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/McNary_Dam.jpg/640px-McNary_Dam.jpg",
  dam_john_day    = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/John_Day_Dam.jpg/640px-John_Day_Dam.jpg",
  dam_thedalles   = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/The_Dalles_Dam.jpg/640px-The_Dalles_Dam.jpg",
  dam_bonneville  = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Bonneville_Dam_from_Washington_state_side.jpg/640px-Bonneville_Dam_from_Washington_state_side.jpg",
  pikeminnow      = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Ptychocheilus_oregonensis.jpg/640px-Ptychocheilus_oregonensis.jpg",
  sealion         = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/California_sea_lion_-_Flickr_-_GregTheBusker.jpg/640px-California_sea_lion_-_Flickr_-_GregTheBusker.jpg",
  predator_bass   = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Smallmouth_bass_jack_Dempsey.jpg/640px-Smallmouth_bass_jack_Dempsey.jpg",
  ocean_harvest   = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Gili_Air_-_Fishing_nets.jpg/640px-Gili_Air_-_Fishing_nets.jpg",
  ocean_orca      = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Killerwhales_jumping.jpg/640px-Killerwhales_jumping.jpg",
  ocean_warmblob  = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Kelp_forest_at_Monterey_Bay_Aquarium.jpg/640px-Kelp_forest_at_Monterey_Bay_Aquarium.jpg",
  ocean_shark     = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/White_shark.jpg/640px-White_shark.jpg",
  temperature     = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image-Shallow_water_hydrothermal_vent.jpg/640px-Image-Shallow_water_hydrothermal_vent.jpg",
  supersaturation = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Spillway_at_Bonneville_Dam.jpg/640px-Spillway_at_Bonneville_Dam.jpg",
  win_spawning    = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Chinook_Salmon_Adult_Male.jpg/640px-Chinook_Salmon_Adult_Male.jpg",
  placeholder     = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Gatto_europeo4.jpg/320px-Gatto_europeo4.jpg"
)

# ── Death narrative text ──────────────────────────────────────────────────────
# {n} is replaced with the number of fish killed in that event
DEATH_NARRATIVES <- list(
  avian_pelican   = "A flock of American White Pelicans was waiting. {n} of your fish never saw them coming.",
  avian_merganser = "Common Mergansers patrol every riffle in the Walla Walla basin. {n} fish were picked off.",
  avian_tern      = "Caspian Terns from East Sand Island colony intercepted your fish in the estuary. {n} fish eaten.",
  avian_cormorant = "Double-crested Cormorants are relentless divers. {n} of your fish were taken from below.",
  dam_lower_granite = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Lower_Granite_Dam.jpg/640px-Lower_Granite_Dam.jpg",
  dam_lower_granite = "{n} fish were killed or injured at Lower Granite Dam — the first of four Snake River dams. This dam alone blocks access to 140 miles of spawning habitat.",
  dam_thedalles   = "{n} fish were killed or injured at The Dalles Dam. This dam flooded Celilo Falls in 1957 — one of the oldest fishing sites in North America.",
  dam_mcnary      = "{n} fish were killed or injured passing through McNary Dam's turbines.",
  dam_john_day    = "John Day Reservoir's slow, warm water weakened your fish. {n} did not survive the dam.",
  dam_bonneville  = "{n} fish were lost at Bonneville Dam — the last dam before the ocean.",
  pikeminnow      = "Northern Pikeminnow lurk at every dam tailrace. {n} juvenile salmon became a meal.",
  sealion         = "California Sea Lions have learned to wait below Bonneville Dam. {n} returning adults were taken.",
  predator_bass   = "Smallmouth Bass thrive in warm reservoir water — they weren't here before the dams. {n} fish lost.",
  ocean_harvest   = "{n} of your fish were caught by commercial fishing vessels in the Pacific.",
  ocean_orca      = "Southern Resident Orcas depend on Chinook salmon to survive. {n} fish were taken.",
  ocean_warmblob  = "A warm water anomaly crashed the prey base. {n} fish starved in the open ocean.",
  ocean_shark     = "{n} fish were taken by sharks during their ocean residence.",
  temperature     = "Water temperatures in the reservoir exceeded 68°F — lethal for salmon. {n} fish died.",
  supersaturation = "Spill at the dam caused nitrogen supersaturation — like the bends in scuba diving. {n} fish died.",
  stranding       = "{n} juvenile fish were stranded in irrigation diversions and never made it back to the river.",
  other           = "{n} fish were lost to unknown causes — a reminder of how much we still don't know."
)

# ── Ocean phase events ────────────────────────────────────────────────────────
# Random events during the 1-2 year ocean phase
# Each has a probability of occurring and a mortality hit (proportion of remaining fish)
OCEAN_EVENTS <- list(
  list(
    id       = "el_nino",
    label    = "🌊 El Niño Year",
    prob     = 0.30,
    kill_pct = 0.40,
    cause    = "ocean_warmblob",
    text     = "El Niño brought warm water and crashed the prey base. Survival plummeted."
  ),
  list(
    id       = "good_upwelling",
    label    = "💨 Strong Upwelling",
    prob     = 0.40,
    kill_pct = -0.10,   # negative = bonus survival
    cause    = NULL,
    text     = "Strong coastal upwelling brought cold, nutrient-rich water. Your fish thrived!"
  ),
  list(
    id       = "high_harvest",
    label    = "🎣 High Harvest Year",
    prob     = 0.25,
    kill_pct = 0.20,
    cause    = "ocean_harvest",
    text     = "High commercial harvest quotas this year — more of your fish were caught."
  ),
  list(
    id       = "orca_year",
    label    = "🐋 Orca Predation",
    prob     = 0.20,
    kill_pct = 0.10,
    cause    = "ocean_orca",
    text     = "Southern Resident Orcas are starving — they depend entirely on Chinook salmon."
  )
)

# ── Win condition ─────────────────────────────────────────────────────────────
WIN_STATION    <- "nursery_bridge"
WIN_MINIMUM    <- 1    # at least 1 fish must reach Nursery Bridge to win