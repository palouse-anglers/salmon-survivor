library(readxl)
library(dplyr)

df <- read_xlsx("C:/Users/Steve/salmon-survivor/500 2024 Tags.xlsx")

fish <- df %>%
  janitor::clean_names()

glimpse(fish)

# All are from South Fork Walla Walla River 
fish %>%
  distinct(release_site_name)

# How many fish detected at each checkpoint
detection_cols <- c(
  "Walla Walla Barge", "McNary Juvenile", "John Day Juvenile",
  "Bonneville Juvenile", "Estuary Detectors", "AVIAN MORTALITY",
  "Bonneville Adult", "The Dalles Adult", "John Day Adult",
  "McNary Adult", "Burlingame", "Nursery Bridge"
)

# Fish per check point 
df |>
  summarise(across(all_of(detection_cols), \(x) sum(!is.na(x)))) |>
  tidyr::pivot_longer(everything(), names_to = "checkpoint", values_to = "n_detected") |>
  arrange(desc(n_detected))


# Release dates and fish counts per date
df |>
  count(`Release Date MMDDYYYY`, name = "n_fish") |>
  arrange(`Release Date MMDDYYYY`)


# How many fish made it to adult detectors (any adult site)
df |>
  mutate(
    adult_detected = !is.na(`Bonneville Adult`) | !is.na(`The Dalles Adult`) |
                     !is.na(`John Day Adult`)   | !is.na(`McNary Adult`) |
                     !is.na(Burlingame)          | !is.na(`Nursery Bridge`),
    avian_mortality = !is.na(`AVIAN MORTALITY`)
  ) |>
  summarise(
    total          = n(),
    adult_returns  = sum(adult_detected),
    avian_kills    = sum(avian_mortality),
    pct_return     = round(mean(adult_detected) * 100, 1),
    pct_avian      = round(mean(avian_mortality) * 100, 1)
  )




salmon-survivor/
└── www/
    └── death_screens/
        ├── avian_tern.png          # Caspian tern — estuary/Columbia mouth
        ├── avian_cormorant.png     # Cormorant — East Sand Island
        ├── avian_pelican.png       # Pelican — local Walla Walla hotspots
        ├── avian_merganser.png     # Merganser — tributaries
        ├── dam_lower_granite.png   # Lower Granite Dam painting
        ├── dam_mcnary.png          # McNary Dam
        ├── dam_bonneville.png      # Bonneville Dam
        ├── dam_john_day.png        # John Day Dam
        ├── predator_pikeminnow.png # Northern Pikeminnow
        ├── predator_sealion.png    # Sea Lion — Bonneville tailrace
        ├── predator_bass.png       # Smallmouth Bass — reservoirs
        ├── ocean_harvest.png       # Commercial fishing
        ├── ocean_orca.png          # Orca
        ├── ocean_warmblob.png      # El Niño / warm blob
        ├── win_spawning.png        # WIN screen — fish on redd
        └── placeholder.png         # fallback for missing images
    └── ui_images/
        ├── logo.png
        ├── juvenile_salmon.png
        └── adult_salmon.png