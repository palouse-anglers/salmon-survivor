# 🐟 Salmon Survivor

An interactive R Shiny game teaching high school students about Pacific salmon and steelhead migration, dam impacts, and conservation — built on real PIT tag data from the Walla Walla Basin.

---

## The Game

Students guide a cohort of **500 juvenile steelhead** from the South Fork Walla Walla River through the Columbia-Snake River dam system, across the Pacific Ocean, and back home to spawn.

**Real data backbone:**
- 500 fish released April 2024
- 124 detected at McNary Dam
- 7 reached the Columbia Estuary
- 7 PIT tags recovered at avian predator colonies
- 5 returned to Bonneville Dam as adults (2026)
- **1 fish confirmed at Nursery Bridge — home**

**Win condition:** Get at least 1 fish back to Nursery Bridge.

---

## How It Works

### Pre-Game Quiz (3 questions)
Before releasing the cohort, students answer habitat BMP questions:
- Beaver dam analogues
- Agricultural tillage practices
- Pool/woody debris habitat restoration

Each correct answer adds **+25 fish** to the starting cohort (max 575).

### Migration
The cohort moves through real detection stations. At each stop:
- Real survival rates from Walla Walla PIT tag data applied
- Mortality cause shown with artist illustration
- **Math displayed explicitly:** base mortality − quiz bonus = net loss

### In-Game Conservation Questions
Questions pop at trigger stations. Correct answers save fish:

| Station | Topic | Bonus |
|---------|-------|-------|
| Lower Monumental Dam | Spill programs | +10 fish |
| McNary Dam | Pikeminnow bounty program | +10 fish |
| Bonneville Dam (juvenile) | Avian predation / hazing | +10 fish |
| Bonneville Dam (adult) | Sea lion management | +10 fish |
| Burlingame Dam | Fish ladder limitations | +10 fish |

### Ocean Phase
1–3 year time skip with random events: El Niño, harvest, orca predation, good upwelling years.

### Adult Return
Survivors navigate back upstream through the same dams to reach Burlingame and Nursery Bridge.

---

## Migration Route

```
South Fork Walla Walla R. (release)
    ↓
Lower Monumental Dam    [Snake River]
    ↓
Ice Harbor Dam          [Snake River]
    ↓
McNary Dam              [Columbia River] ← real PIT data
    ↓
John Day Dam
    ↓
Bonneville Dam
    ↓
Columbia Estuary
    ↓
~~~ Pacific Ocean (1–3 years) ~~~
    ↓
Bonneville Dam (adult ladder)
    ↓
The Dalles → John Day → McNary
    ↓
Ice Harbor → Lower Monumental
    ↓
Burlingame Dam (Walla Walla R.)
    ↓
Nursery Bridge 🏆
```

---

## File Structure

```
salmon-survivor/
├── app.R                        # Entry point — sources everything
├── ui.R                         # Top-level UI
├── server.R                     # Top-level server
│
├── config/
│   └── mortality_rates.R        # ← TUNE GAME DIFFICULTY HERE
│
├── data/
│   ├── sites.R                  # Station coordinates and order
│   ├── hotspots.R               # Avian predation hotspots (from KMZ)
│   ├── questions.R              # All quiz questions and bonuses
│   └── walla_walla_500.xlsx     # Real 500-fish PIT tag cohort
│
├── R/
│   ├── utils.R                  # Shared helpers
│   ├── parse_data.R             # Loads xlsx cohort + KMZ
│   └── simulate_cohort.R        # Cohort simulation engine
│
├── modules/
│   ├── mod_pregame_quiz.R       # Pre-game habitat BMP quiz
│   ├── mod_ingame_question.R    # In-game conservation question modal
│   ├── mod_cohort.R             # Fish counter widget
│   ├── mod_map.R                # Leaflet migration map
│   ├── mod_mortality.R          # Death screen + math breakdown
│   ├── mod_ocean.R              # Ocean phase + random events
│   ├── mod_quiz.R               # Standalone quiz tab
│   └── mod_results.R            # Win/lose end screen
│
├── www/
│   └── death_screens/           # ← DROP ARTIST PNGs HERE
│       ├── avian_tern.png
│       ├── avian_pelican.png
│       ├── dam_bonneville.png
│       └── ... (see config/mortality_rates.R for full list)
│
└── archive/
    └── single_fish_app.R        # Original single-fish prototype
```

---

## Setup

### Install R packages
```r
install.packages(c(
  "shiny", "bslib", "leaflet", "dplyr", "lubridate",
  "readxl", "readr", "janitor", "httr2", "jsonlite",
  "xml2", "purrr", "tibble", "shinyjs", "shinyWidgets"
))
```

### Run the app
```r
shiny::runApp("salmon-survivor/")
```

---

## Customization

| What you want to change | File to edit |
|------------------------|--------------|
| Survival rates / difficulty | `config/mortality_rates.R` |
| Death screen images | `config/mortality_rates.R` → `DEATH_IMAGES` |
| Death narrative text | `config/mortality_rates.R` → `DEATH_NARRATIVES` |
| Quiz questions | `data/questions.R` |
| Detection stations | `data/sites.R` |
| Predation hotspot map layers | `data/hotspots.R` |
| Ocean random events | `config/mortality_rates.R` → `OCEAN_EVENTS` |

### Adding artist death screen images
1. Save PNG to `www/death_screens/your_image.png`
2. Open `config/mortality_rates.R`
3. Find `DEATH_IMAGES` and replace the placeholder URL with `"death_screens/your_image.png"`

---

## Data Sources

- **PIT tag cohort:** PTAGIS (ptagis.org) — Pacific States Marine Fisheries Commission
- **Avian predation hotspots:** PIT tag recoveries at bird colonies, Walla Walla Basin
- **Survival rates:** Fish Passage Center Comparative Survival Study
- **SAR benchmarks:** NOAA Fisheries / Trout Unlimited Columbia Basin reports

---

## Credits

Built with R Shiny for classroom use.  
Death screen artwork by [Artist Name].  
PIT tag data provided by PTAGIS / [Your Agency].
```
