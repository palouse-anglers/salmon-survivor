library(shiny)
library(bslib)
library(leaflet)
library(dplyr)
library(lubridate)
library(httr2)
library(jsonlite)
library(ggplot2)
library(shinyWidgets)

# ── Interrogation site metadata (Columbia/Snake mainstem) ─────────────────────
sites <- tibble::tribble(
  ~code,  ~name,                          ~lat,     ~lon,      ~river,          ~rkm,  ~type,
  "GRS",  "Grande Ronde River",           45.901,  -117.018,  "Snake",           NA,  "tributary",
  "LGR",  "Lower Granite Dam",            46.660,  -117.430,  "Snake",          695,  "dam",
  "GOA",  "Little Goose Dam",             46.587,  -118.028,  "Snake",          638,  "dam",
  "LMA",  "Lower Monumental Dam",         46.562,  -118.537,  "Snake",          592,  "dam",
  "IHR",  "Ice Harbor Dam",               46.248,  -118.876,  "Snake",          539,  "dam",
  "MCN",  "McNary Dam",                   45.930,  -119.298,  "Columbia",       469,  "dam",
  "JDA",  "John Day Dam",                 45.715,  -120.695,  "Columbia",       348,  "dam",
  "TDA",  "The Dalles Dam",               45.604,  -121.132,  "Columbia",       307,  "dam",
  "BON",  "Bonneville Dam",               45.644,  -121.941,  "Columbia",       235,  "dam",
  "EST",  "Columbia River Estuary",       46.245,  -123.900,  "Columbia",         0,  "estuary"
)

dam_facts <- list(
  LGR = list(
    threat = "Lower Granite Dam blocks salmon from ~140 miles of spawning habitat in the upper Snake River. Fish ladders help adults return, but juvenile survival through turbines is only ~85–95% per dam.",
    conservation = "Fish passage facilities at Lower Granite include bypass systems that collect juveniles and route them around turbines.",
    fun = "Lower Granite Dam was completed in 1975 and is the furthest upstream dam on the Snake River reachable from the ocean."
  ),
  GOA = list(
    threat = "Spill programs — where water is intentionally passed over the dam instead of through turbines — can improve juvenile survival significantly.",
    conservation = "The Fish Passage Center monitors survival rates and advocates for increased spill.",
    fun = "Little Goose Dam's reservoir covers the site of the historic Almota Ferry crossing."
  ),
  LMA = list(
    threat = "Elevated water temperatures in reservoirs behind dams stress salmon — they evolved in cold, fast-moving water.",
    conservation = "Flow augmentation from upstream reservoirs can help cool water and boost migration speed.",
    fun = "Lower Monumental Dam sits near the confluence of the Tucannon and Snake Rivers."
  ),
  IHR = list(
    threat = "Barging programs transport some juvenile fish past multiple dams in tank trucks or barges to improve survival.",
    conservation = "While barging boosts short-term survival, some research shows in-river migrants may have better adult return rates.",
    fun = "Ice Harbor was the first of the four lower Snake River dams to be completed, in 1962."
  ),
  MCN = list(
    threat = "McNary Dam is a major confluence point — it sits right where the Snake River meets the Columbia.",
    conservation = "The McNary juvenile bypass system is one of the most extensively monitored in the basin.",
    fun = "PIT tag readers at McNary have been detecting fish since 1989!"
  ),
  JDA = list(
    threat = "John Day Reservoir is the longest reservoir on the Columbia River (~107 miles) — slow, warm water that can be tough for juvenile salmon.",
    conservation = "Passage improvements have included turbine upgrades to reduce fish injury.",
    fun = "John Day Dam produces about 2,160 megawatts of power — enough for about 1.5 million homes."
  ),
  TDA = list(
    threat = "The Dalles Dam flooded Celilo Falls in 1957 — one of the oldest continuously inhabited places in North America and a critical Native American fishing site.",
    conservation = "Tribes retain treaty fishing rights at other Columbia River sites and are active in salmon recovery.",
    fun = "The Dalles is considered the eastern gateway to the Columbia River Gorge."
  ),
  BON = list(
    threat = "Bonneville Dam was the first major Columbia River dam, completed in 1938. It fundamentally changed the river ecosystem.",
    conservation = "Bonneville has some of the most studied fish passage in the world — its ladders have counted millions of adult salmon.",
    fun = "The adult fish counting window at Bonneville Dam is open to the public — you can watch salmon swim by in person!"
  ),
  EST = list(
    threat = "The Columbia River estuary has lost ~75% of its historical wetland habitat due to diking, filling, and development.",
    conservation = "Estuary restoration projects are removing dikes to reconnect floodplains for juvenile salmon rearing.",
    fun = "After spending 1–3 years in the ocean, adult salmon will return to this very spot and navigate all the way back upstream to spawn!"
  )
)

# ── Realistic simulated detection history ─────────────────────────────────────
simulate_fish <- function(species = "Chinook", origin = "Wild") {
  tag <- paste0("3D9.", paste(sample(c(0:9, LETTERS[1:6]), 10, replace = TRUE), collapse = ""))
  
  start_date <- as.POSIXct("2024-04-15") + runif(1, -10, 10) * 86400
  
  # Survival probabilities per dam (varies by species)
  surv <- if (species == "Chinook") 0.92 else 0.89
  
  detections <- list()
  current_time <- start_date
  survived <- TRUE
  
  # Tag site
  detections[[1]] <- list(
    site_code = "GRS",
    site_name = "Tagging Site — Grande Ronde River",
    obs_time = format(current_time, "%Y-%m-%d %H:%M"),
    event = "mark",
    lat = 45.901, lon = -117.018
  )
  
  for (i in seq_len(nrow(sites))) {
    s <- sites[i, ]
    if (s$code == "GRS") next
    if (!survived) break
    
    # Travel time between sites
    travel_days <- if (s$type == "dam") runif(1, 2, 6) else runif(1, 3, 10)
    current_time <- current_time + travel_days * 86400
    
    # Survive this dam?
    if (s$type == "dam") {
      survived <- runif(1) < surv
    }
    
    if (survived || s$code == "BON") {  # always show last detection
      detections[[length(detections) + 1]] <- list(
        site_code = s$code,
        site_name = s$name,
        obs_time = format(current_time, "%Y-%m-%d %H:%M"),
        event = if (!survived && s$type == "dam") "last_detection" else "observation",
        lat = s$lat, lon = s$lon
      )
      if (!survived) break
    }
  }
  
  list(
    tag = tag,
    species = species,
    origin = origin,
    weight_g = if (species == "Chinook") round(runif(1, 15, 40)) else round(runif(1, 10, 25)),
    length_mm = if (species == "Chinook") round(runif(1, 90, 140)) else round(runif(1, 80, 120)),
    detections = detections,
    survived_to_ocean = survived
  )
}

# ── PTAGIS API helper ──────────────────────────────────────────────────────────
fetch_ptagis_tag <- function(tag_code, api_key) {
  tryCatch({
    resp <- request("https://api.ptagis.org") |>
      req_url_path_paste("data/observations", tag_code) |>
      req_headers("apiKey" = api_key) |>
      req_perform()
    
    data <- resp_body_json(resp)
    # Parse into our detections format
    detections <- lapply(data, function(d) {
      site_meta <- sites[sites$code == d$siteCode, ]
      list(
        site_code = d$siteCode,
        site_name = if (nrow(site_meta) > 0) site_meta$name else d$siteCode,
        obs_time = d$observationTime,
        event = "observation",
        lat = if (nrow(site_meta) > 0) site_meta$lat else NA,
        lon = if (nrow(site_meta) > 0) site_meta$lon else NA
      )
    })
    list(success = TRUE, detections = detections)
  }, error = function(e) {
    list(success = FALSE, error = conditionMessage(e))
  })
}

# ── Life stage helper ──────────────────────────────────────────────────────────
get_life_stage <- function(site_code) {
  switch(site_code,
    GRS = "🐟 Fry / Parr — You were just tagged! You've spent 1–2 years growing up in your home stream.",
    LGR = , GOA = , LMA = "🐠 Smolt — Your body is changing! You're smoltifying — adapting from freshwater to prepare for the ocean.",
    IHR = , MCN = "🌊 Smolt migration — You're moving fast through the Snake–Columbia corridor. Every day counts!",
    JDA = , TDA = "🌊 Lower Columbia migration — You're getting close to the ocean. You can almost smell the salt water!",
    BON = "🚪 Bonneville — The last dam! Beyond this point you'll enter the estuary, then the Pacific Ocean.",
    EST = "🌊 Ocean entry — You made it to the Pacific! You'll spend 1–3 years in the ocean before returning to spawn.",
    "Migration in progress..."
  )
}

# ── Quiz questions ─────────────────────────────────────────────────────────────
quiz_bank <- list(
  list(
    q = "How does a PIT tag work?",
    choices = c(
      "It uses GPS to track the fish by satellite",
      "It's a passive chip that emits a unique ID when scanned by an antenna",
      "It transmits radio signals every 30 minutes",
      "It measures water temperature and reports to scientists"
    ),
    correct = 2,
    explanation = "A PIT (Passive Integrated Transponder) tag has no battery! Antennas at dams emit a radio field that powers the tag just long enough to read its unique code. That's why it can last the fish's entire lifetime."
  ),
  list(
    q = "What is 'smoltification'?",
    choices = c(
      "When salmon choose their spawning gravel",
      "The process of salmon returning from the ocean",
      "Physiological changes that prepare a salmon for saltwater",
      "When salmon reach sexual maturity"
    ),
    correct = 3,
    explanation = "Smoltification is a dramatic transformation — salmon change their osmoregulation (salt balance), coloring, and behavior to prepare for ocean life. Timing is critical; disrupted migration timing can mean fish smoltify at the wrong time."
  ),
  list(
    q = "What is one major effect of dams on juvenile salmon?",
    choices = c(
      "Dams provide more food for salmon",
      "Dams slow water, raising temperatures and slowing migration",
      "Dams keep predators away from salmon",
      "Dams have no effect on salmon migration"
    ),
    correct = 2,
    explanation = "Reservoirs behind dams are slow and warm — the opposite of the cold, fast streams salmon evolved in. Slower migration means fish may smoltify at the wrong time, use up energy reserves, and face more predators."
  ),
  list(
    q = "What percentage of Columbia River salmon habitat was blocked by dams?",
    choices = c("About 10%", "About 30%", "About 55%", "About 70%"),
    correct = 3,
    explanation = "Dams blocked access to roughly 55% of historical salmon habitat in the Columbia River Basin — including prime spawning areas in the upper Snake River and its tributaries."
  ),
  list(
    q = "What is 'Pacific salmon semelparous' mean?",
    choices = c(
      "They can survive in both fresh and salt water",
      "They die after spawning once",
      "They return to the exact stream where they were born",
      "They migrate thousands of miles"
    ),
    correct = 2,
    explanation = "Pacific salmon (Chinook, coho, sockeye, etc.) are semelparous — they spawn once and die. Their decomposing bodies become a nutrient pulse that fertilizes the stream ecosystem, feeding insects, trees, and even bears!"
  )
)

# ═══════════════════════════════════════════════════════════════════════════════
# UI
# ═══════════════════════════════════════════════════════════════════════════════

ui <- page_navbar(
  title = tags$span(
    tags$img(src = "https://em-content.zobj.net/source/apple/391/fish_1f41f.png",
             height = "28px", style = "margin-right:6px; vertical-align:middle;"),
    "Salmon Journey — PIT Tag Explorer"
  ),
  theme = bs_theme(
    bootswatch = "flatly",
    primary = "#1a6e8a",
    success = "#2d8a4e",
    base_font = font_google("Inter")
  ),
  
  # ── TAB 1: Start / Fish Selection ──────────────────────────────────────────
  nav_panel("🎣 Choose Your Fish",
    layout_columns(
      col_widths = c(4, 8),
      
      card(
        card_header("🔬 Your Fish"),
        card_body(
          selectInput("species", "Species:", 
                      choices = c("Chinook Salmon" = "Chinook", 
                                  "Steelhead" = "Steelhead")),
          selectInput("origin", "Origin:",
                      choices = c("Wild" = "Wild", "Hatchery" = "Hatchery")),
          hr(),
          h6("Use Real PTAGIS Data (optional):"),
          textInput("api_key", "API Key:", placeholder = "Request from ptagis.org"),
          textInput("tag_code", "PIT Tag Code:", placeholder = "e.g. 3D9.1C2C5D3F87"),
          hr(),
          actionButton("new_fish", "🎲 Simulate New Fish", 
                       class = "btn-primary w-100 mb-2"),
          actionButton("fetch_fish", "📡 Fetch Real Tag", 
                       class = "btn-outline-secondary w-100")
        )
      ),
      
      card(
        card_header("About Your Fish"),
        card_body(
          uiOutput("fish_profile"),
          hr(),
          uiOutput("species_info")
        )
      )
    )
  ),
  
  # ── TAB 2: Migration Journey ───────────────────────────────────────────────
  nav_panel("🗺️ Migration Journey",
    layout_columns(
      col_widths = c(7, 5),
      
      card(
        card_header("Columbia-Snake River Basin"),
        card_body(
          padding = 0,
          leafletOutput("migration_map", height = "520px")
        )
      ),
      
      card(
        card_header("Detection Log"),
        card_body(
          uiOutput("detection_controls"),
          hr(),
          uiOutput("detection_panel")
        )
      )
    )
  ),
  
  # ── TAB 3: Dam Facts ───────────────────────────────────────────────────────
  nav_panel("🏗️ Dam Deep Dives",
    layout_columns(
      col_widths = c(4, 8),
      
      card(
        card_header("Select a Dam"),
        card_body(
          selectInput("selected_dam", "Dam:", 
                      choices = setNames(sites$code[sites$type == "dam"], 
                                        sites$name[sites$type == "dam"])),
          uiOutput("dam_detail_card")
        )
      ),
      
      card(
        card_header("Four Lower Snake River Dams — The Big Debate"),
        card_body(
          p("The four lower Snake River dams (Lower Granite, Little Goose, Lower Monumental, Ice Harbor) are at the center of one of the biggest salmon conservation debates in the Pacific Northwest."),
          layout_columns(
            col_widths = c(6, 6),
            card(
              card_header(style = "background:#d9534f; color:white;", "Arguments for Removal"),
              card_body(
                tags$ul(
                  tags$li("Would open ~140 miles of prime Snake River spawning habitat"),
                  tags$li("Salmon survival improves dramatically without 4 extra dams"),
                  tags$li("Four dams produce only ~4–5% of regional electricity"),
                  tags$li("Tribal treaty rights depend on healthy salmon runs"),
                  tags$li("ESA-listed fish populations continue to decline")
                )
              )
            ),
            card(
              card_header(style = "background:#5cb85c; color:white;", "Arguments Against Removal"),
              card_body(
                tags$ul(
                  tags$li("Dams provide cheap, carbon-free hydroelectric power"),
                  tags$li("Barge transportation on Snake River supports agriculture"),
                  tags$li("Reservoir recreation and irrigation water benefits"),
                  tags$li("Fish passage improvements have increased survival rates"),
                  tags$li("Other factors (ocean conditions, harvest) also limit salmon")
                )
              )
            )
          ),
          p(em("What do YOU think? There's no easy answer — it involves tradeoffs between energy, food, culture, and conservation."), 
            style = "margin-top:12px; font-style:italic; color:#555;")
        )
      )
    )
  ),
  
  # ── TAB 4: Quiz ───────────────────────────────────────────────────────────
  nav_panel("🧠 Quiz",
    layout_columns(
      col_widths = c(7, 5),
      
      card(
        card_header("Test Your Knowledge"),
        card_body(
          uiOutput("quiz_ui"),
          hr(),
          uiOutput("quiz_feedback")
        )
      ),
      
      card(
        card_header("Your Score"),
        card_body(
          uiOutput("score_display"),
          hr(),
          h6("Key Vocabulary"),
          tags$dl(
            tags$dt("PIT Tag"), tags$dd("Passive Integrated Transponder — a tiny rice-sized chip implanted in fish."),
            tags$dt("Smoltification"), tags$dd("Physiological transformation preparing juvenile salmon for saltwater."),
            tags$dt("Semelparous"), tags$dd("Reproducing only once, then dying (all Pacific salmon species)."),
            tags$dt("Anadromous"), tags$dd("Fish that migrate from freshwater to ocean and back to freshwater to spawn."),
            tags$dt("River Kilometer (RKm)"), tags$dd("Distance from the river mouth — used to locate detection sites."),
            tags$dt("Smolt-to-Adult Return (SAR)"), tags$dd("Percentage of juveniles that survive to return as adults — a key metric for dam impacts.")
          )
        )
      )
    )
  )
)

# ═══════════════════════════════════════════════════════════════════════════════
# SERVER
# ═══════════════════════════════════════════════════════════════════════════════

server <- function(input, output, session) {
  
  rv <- reactiveValues(
    fish = NULL,
    current_step = 0,
    quiz_index = 1,
    quiz_score = 0,
    quiz_answered = FALSE,
    quiz_correct = NULL,
    message = NULL
  )
  
  # Initialize with a simulated fish on load
  observe({
    if (is.null(rv$fish)) {
      rv$fish <- simulate_fish("Chinook", "Wild")
      rv$current_step <- 0
    }
  })
  
  # ── New simulated fish ───────────────────────────────────────────────────
  observeEvent(input$new_fish, {
    rv$fish <- simulate_fish(input$species, input$origin)
    rv$current_step <- 0
    rv$message <- NULL
    showNotification("New fish simulated! Head to the Migration Journey tab.", type = "message")
  })
  
  # ── Fetch real PTAGIS data ─────────────────────────────────────────────
  observeEvent(input$fetch_fish, {
    req(input$api_key, input$tag_code)
    withProgress(message = "Fetching from PTAGIS...", {
      result <- fetch_ptagis_tag(trimws(input$tag_code), trimws(input$api_key))
      if (result$success) {
        rv$fish <- list(
          tag = input$tag_code,
          species = input$species,
          origin = input$origin,
          weight_g = NA,
          length_mm = NA,
          detections = result$detections,
          survived_to_ocean = TRUE
        )
        rv$current_step <- 0
        showNotification("Real tag data loaded!", type = "message")
      } else {
        showNotification(paste("API error:", result$error), type = "error")
      }
    })
  })
  
  # ── Fish profile ───────────────────────────────────────────────────────
  output$fish_profile <- renderUI({
    req(rv$fish)
    f <- rv$fish
    n_detections <- length(f$detections)
    
    tagList(
      tags$table(class = "table table-sm",
        tags$tbody(
          tags$tr(tags$th("Tag ID"), tags$td(tags$code(f$tag))),
          tags$tr(tags$th("Species"), tags$td(f$species)),
          tags$tr(tags$th("Origin"), tags$td(f$origin)),
          if (!is.na(f$weight_g)) tags$tr(tags$th("Weight"), tags$td(paste(f$weight_g, "g"))),
          if (!is.na(f$length_mm)) tags$tr(tags$th("Length"), tags$td(paste(f$length_mm, "mm"))),
          tags$tr(tags$th("Detections"), tags$td(paste(n_detections, "sites"))),
          tags$tr(tags$th("Outcome"), 
                  tags$td(if (f$survived_to_ocean) 
                    tags$span("🌊 Reached Ocean", style = "color:#2d8a4e; font-weight:bold;")
                  else 
                    tags$span("💀 Did not survive", style = "color:#c0392b;")))
        )
      )
    )
  })
  
  output$species_info <- renderUI({
    req(rv$fish)
    if (rv$fish$species == "Chinook") {
      tagList(
        h6("Chinook Salmon (Oncorhynchus tshawytscha)"),
        p("Also called 'King Salmon' — the largest Pacific salmon species. 
          Chinook can weigh up to 130 lbs! Spring/summer Chinook are especially 
          important to tribes and ecosystems of the Columbia Basin."),
        tags$ul(
          tags$li("Ocean life: 1–5 years"),
          tags$li("Spawning migration: May–September"),
          tags$li("Status: Several runs listed under ESA")
        )
      )
    } else {
      tagList(
        h6("Steelhead (Oncorhynchus mykiss)"),
        p("Steelhead are the ocean-going form of rainbow trout. 
          Uniquely, some steelhead survive spawning and return to the ocean — 
          they can spawn multiple times!"),
        tags$ul(
          tags$li("Ocean life: 1–4 years"),
          tags$li("Can survive spawning (iteroparous)"),
          tags$li("Status: Multiple ESUs listed under ESA")
        )
      )
    }
  })
  
  # ── Migration Map ────────────────────────────────────────────────────────
  output$migration_map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = TRUE)) |>
      addProviderTiles("CartoDB.Positron") |>
      setView(lng = -119.5, lat = 46.2, zoom = 7) |>
      addPolylines(
        lng = sites$lon, lat = sites$lat,
        color = "#1a6e8a", weight = 2, opacity = 0.4,
        dashArray = "5,5"
      ) |>
      addCircleMarkers(
        data = sites,
        lng = ~lon, lat = ~lat,
        radius = 8,
        color = "#1a6e8a",
        fillColor = "#ffffff",
        fillOpacity = 0.9,
        weight = 2,
        label = ~paste(code, "-", name),
        layerId = ~code
      )
  })
  
  # Update map as user steps through detections
  observe({
    req(rv$fish, rv$current_step > 0)
    f <- rv$fish
    step <- min(rv$current_step, length(f$detections))
    
    visited <- f$detections[1:step]
    v_df <- data.frame(
      lat = sapply(visited, `[[`, "lat"),
      lon = sapply(visited, `[[`, "lon"),
      code = sapply(visited, `[[`, "site_code"),
      name = sapply(visited, `[[`, "site_name"),
      event = sapply(visited, `[[`, "event")
    )
    v_df <- v_df[!is.na(v_df$lat), ]
    
    pal_color <- ifelse(v_df$event == "mark", "#f39c12",
                 ifelse(v_df$event == "last_detection", "#c0392b", "#2d8a4e"))
    
    leafletProxy("migration_map") |>
      clearMarkers() |>
      addCircleMarkers(
        data = sites, lng = ~lon, lat = ~lat,
        radius = 6, color = "#aaa", fillColor = "#eee",
        fillOpacity = 0.6, weight = 1,
        label = ~paste(code, "-", name)
      ) |>
      addCircleMarkers(
        data = v_df, lng = ~lon, lat = ~lat,
        radius = 12,
        color = pal_color,
        fillColor = pal_color,
        fillOpacity = 0.85,
        weight = 2,
        popup = ~paste0("<b>", name, "</b><br>Detected: ", 
                       sapply(visited[seq_len(nrow(v_df))], `[[`, "obs_time"))
      ) |>
      addPolylines(
        data = v_df, lng = ~lon, lat = ~lat,
        color = "#e74c3c", weight = 3, opacity = 0.7
      )
    
    # Pan to current location
    current <- visited[[step]]
    if (!is.na(current$lat)) {
      leafletProxy("migration_map") |>
        flyTo(lng = current$lon, lat = current$lat, zoom = 9)
    }
  })
  
  # ── Detection controls ───────────────────────────────────────────────────
  output$detection_controls <- renderUI({
    req(rv$fish)
    n <- length(rv$fish$detections)
    tagList(
      div(style = "display:flex; gap:8px; align-items:center; flex-wrap:wrap;",
        actionButton("prev_step", "◀ Previous", class = "btn-outline-secondary btn-sm"),
        actionButton("next_step", "Next ▶", class = "btn-primary btn-sm"),
        actionButton("auto_play", "▶▶ Auto Play", class = "btn-outline-success btn-sm"),
        span(style = "color:#777; font-size:0.9em;",
             textOutput("step_counter", inline = TRUE))
      ),
      progressBar(
        id = "migration_progress",
        value = if (n > 0) round(rv$current_step / n * 100) else 0,
        display_pct = TRUE,
        status = "success"
      )
    )
  })
  
  output$step_counter <- renderText({
    req(rv$fish)
    paste0("Stop ", rv$current_step, " of ", length(rv$fish$detections))
  })
  
  observeEvent(input$prev_step, {
    rv$current_step <- max(0, rv$current_step - 1)
  })
  
  observeEvent(input$next_step, {
    req(rv$fish)
    rv$current_step <- min(length(rv$fish$detections), rv$current_step + 1)
  })
  
  # Auto-play
  auto_timer <- reactiveVal(NULL)
  observeEvent(input$auto_play, {
    if (!is.null(auto_timer())) {
      auto_timer(NULL)
    } else {
      t <- observe({
        invalidateLater(1800)
        isolate({
          req(rv$fish)
          if (rv$current_step < length(rv$fish$detections)) {
            rv$current_step <- rv$current_step + 1
          } else {
            auto_timer(NULL)
          }
        })
      })
      auto_timer(t)
    }
  })
  
  # ── Detection panel (narrative) ──────────────────────────────────────────
  output$detection_panel <- renderUI({
    req(rv$fish)
    
    if (rv$current_step == 0) {
      return(tagList(
        div(class = "alert alert-info",
          h5("🐟 Your fish is ready!"),
          p(paste("Tag:", rv$fish$tag)),
          p("Press 'Next ▶' to begin the migration journey, or 'Auto Play' to watch automatically."),
          p("Your fish starts in the Snake River headwaters and will attempt to migrate 
            through multiple dams to reach the Pacific Ocean.")
        )
      ))
    }
    
    step <- min(rv$current_step, length(rv$fish$detections))
    det <- rv$fish$detections[[step]]
    code <- det$site_code
    
    is_last <- det$event == "last_detection"
    is_ocean <- code == "EST"
    
    # Look up dam facts
    facts <- dam_facts[[code]]
    
    alert_class <- if (is_last) "alert-danger" else if (is_ocean) "alert-success" else "alert-primary"
    
    tagList(
      div(class = paste("alert", alert_class),
        if (is_last) {
          tagList(
            h5("💀 Last Detection"),
            p(paste("Your fish was last detected at", det$site_name, "on", det$obs_time)),
            p("This fish did not survive to the ocean. Mortality at dams is a real challenge — 
              typically 5–15% of fish don't make it past each dam.")
          )
        } else if (is_ocean) {
          tagList(
            h5("🌊 Reached the Pacific Ocean!"),
            p(paste("Detection time:", det$obs_time)),
            p("Your fish made it! After 1–3 years in the ocean, 
              this fish will return as an adult to spawn in its home stream — 
              navigating all those dams in reverse.")
          )
        } else {
          tagList(
            h5(paste("📡 Detected at:", det$site_name)),
            p(paste("Detection time:", det$obs_time)),
            p(em(get_life_stage(code)))
          )
        }
      ),
      
      if (!is.null(facts)) {
        tagList(
          hr(),
          div(
            tags$b("⚠️ Threat:"), p(facts$threat), br(),
            tags$b("🔬 Conservation:"), p(facts$conservation), br(),
            tags$b("💡 Fun Fact:"), p(facts$fun)
          )
        )
      }
    )
  })
  
  # ── Dam details tab ──────────────────────────────────────────────────────
  output$dam_detail_card <- renderUI({
    req(input$selected_dam)
    code <- input$selected_dam
    s <- sites[sites$code == code, ]
    facts <- dam_facts[[code]]
    
    tagList(
      h5(s$name),
      tags$table(class = "table table-sm table-bordered",
        tags$tbody(
          tags$tr(tags$th("River"), tags$td(s$river)),
          tags$tr(tags$th("River km from mouth"), tags$td(s$rkm)),
          tags$tr(tags$th("Site code"), tags$td(tags$code(s$code)))
        )
      ),
      if (!is.null(facts)) {
        tagList(
          div(class = "alert alert-warning", tags$b("Threat: "), facts$threat),
          div(class = "alert alert-success", tags$b("Conservation: "), facts$conservation),
          div(class = "alert alert-info", tags$b("Fun fact: "), facts$fun)
        )
      }
    )
  })
  
  # ── Quiz ─────────────────────────────────────────────────────────────────
  output$quiz_ui <- renderUI({
    idx <- rv$quiz_index
    if (idx > length(quiz_bank)) {
      return(div(class = "alert alert-success",
        h4("🎉 Quiz Complete!"),
        p(paste("You scored", rv$quiz_score, "out of", length(quiz_bank), "questions!")),
        actionButton("restart_quiz", "Try Again", class = "btn-primary")
      ))
    }
    
    q <- quiz_bank[[idx]]
    tagList(
      p(class = "text-muted", paste("Question", idx, "of", length(quiz_bank))),
      h5(q$q),
      div(
        lapply(seq_along(q$choices), function(i) {
          btn_class <- if (rv$quiz_answered) {
            if (i == q$correct) "btn-success w-100 mb-2"
            else if (!is.null(rv$quiz_correct) && !rv$quiz_correct && i == input$quiz_answer) 
              "btn-danger w-100 mb-2"
            else "btn-outline-secondary w-100 mb-2"
          } else {
            "btn-outline-primary w-100 mb-2"
          }
          actionButton(
            paste0("quiz_answer_", i),
            label = q$choices[i],
            class = btn_class,
            style = "text-align:left;"
          )
        })
      )
    )
  })
  
  output$quiz_feedback <- renderUI({
    req(rv$quiz_answered)
    idx <- rv$quiz_index
    if (idx > length(quiz_bank)) return(NULL)
    q <- quiz_bank[[idx]]
    
    tagList(
      div(
        class = if (rv$quiz_correct) "alert alert-success" else "alert alert-danger",
        if (rv$quiz_correct) "✅ Correct!" else "❌ Not quite...",
        br(),
        q$explanation
      ),
      if (!is.null(rv$quiz_correct)) {
        actionButton("next_question", "Next Question →", class = "btn-primary")
      }
    )
  })
  
  # Handle quiz answer buttons
  lapply(1:4, function(i) {
    observeEvent(input[[paste0("quiz_answer_", i)]], {
      if (!rv$quiz_answered) {
        q <- quiz_bank[[rv$quiz_index]]
        correct <- (i == q$correct)
        rv$quiz_correct <- correct
        rv$quiz_answered <- TRUE
        if (correct) rv$quiz_score <- rv$quiz_score + 1
      }
    }, ignoreNULL = TRUE)
  })
  
  observeEvent(input$next_question, {
    rv$quiz_index <- rv$quiz_index + 1
    rv$quiz_answered <- FALSE
    rv$quiz_correct <- NULL
  })
  
  observeEvent(input$restart_quiz, {
    rv$quiz_index <- 1
    rv$quiz_score <- 0
    rv$quiz_answered <- FALSE
    rv$quiz_correct <- NULL
  })
  
  output$score_display <- renderUI({
    total <- length(quiz_bank)
    score <- rv$quiz_score
    pct <- if (rv$quiz_index > 1) round(score / min(rv$quiz_index - 1, total) * 100) else 0
    
    tagList(
      h3(paste(score, "/", total), style = "color:#1a6e8a; font-weight:bold;"),
      progressBar("score_bar", value = pct, display_pct = TRUE,
                  status = if (pct >= 80) "success" else if (pct >= 50) "warning" else "danger"),
      if (pct == 100 && rv$quiz_index > total) 
        div(class = "alert alert-success mt-2", "🏆 Perfect score! You're a salmon expert!")
    )
  })
  
  # Update progress bar reactively
  observe({
    req(rv$fish)
    n <- length(rv$fish$detections)
    if (n > 0) {
      updateProgressBar(session, "migration_progress",
                        value = round(rv$current_step / n * 100))
    }
  })
}

shinyApp(ui, server)
