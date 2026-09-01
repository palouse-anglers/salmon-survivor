# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_map.R
# ══════════════════════════════════════════════════════════════════════════════

mod_map_ui <- function(id) {
  ns <- NS(id)
  div(
    style = "position:relative;",
    # Floating info card over the map
    absolutePanel(
      id     = ns("info_card"),
      top    = 10, left = "50%",
      style  = "transform:translateX(-50%); z-index:500; min-width:280px;
                max-width:400px; display:none;",
      div(
        style = "background:rgba(10,22,40,0.93); border:1px solid #4fc3f7;
                 border-radius:8px; padding:12px 16px; color:white;
                 box-shadow:0 4px 20px rgba(0,0,0,0.7);",
        div(style = "display:flex; justify-content:space-between; align-items:flex-start;",
          uiOutput(ns("card_content")),
          tags$button("✕",
            onclick = sprintf(
              "document.getElementById('%s').style.display='none'",
              ns("info_card")
            ),
            style = "background:none; border:none; color:#aad4e8;
                     font-size:1em; cursor:pointer; padding:0 0 0 10px;
                     flex-shrink:0;"
          )
        )
      )
    ),
    leafletOutput(ns("map"), height = "520px")
  )
}

mod_map_server <- function(id, current_station, station_info_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Draw base map once — no route lines, no flyTo
    output$map <- renderLeaflet({
      leaflet() |>
        # ── Base tile layers ──────────────────────────────────────────────
        leaflet::addProviderTiles("Esri.WorldImagery",   group = "Imagery") |>
        leaflet::addProviderTiles("CartoDB.DarkMatter",  group = "Dark") |>
        leaflet::addProviderTiles("Esri.NatGeoWorldMap", group = "Topo") |>
        leaflet::addProviderTiles("OpenStreetMap",       group = "Street") |>

        # ── USGS Hydrology overlay ────────────────────────────────────────
        leaflet::addWMSTiles(
          baseUrl = "https://basemap.nationalmap.gov/arcgis/services/USGSHydroCached/MapServer/WMSServer?",
          layers  = "0",
          options = leaflet::WMSTileOptions(
            format      = "image/png32",
            version     = "1.3.0",
            minZoom     = 3,
            maxZoom     = 16,
            transparent = TRUE
          ),
          group = "Waterways"
        ) |>

        setView(lng = -119.8, lat = 46.0, zoom = 7) |>

        # ── Station markers (dim) ─────────────────────────────────────────
        addCircleMarkers(
          data        = STATIONS |> dplyr::filter(!is.na(lon)),
          lng         = ~lon, lat = ~lat,
          layerId     = ~id,
          radius      = 6,
          color       = "#4fc3f7", fillColor = "#0d1f35",
          fillOpacity = 0.8, weight = 1.5,
          label       = ~label,
          group       = "Stations"
        ) |>

        # ── Predation hotspots from KMZ ───────────────────────────────────
        addCircles(
          data        = AVIAN_HOTSPOTS,
          lng         = ~lon, lat = ~lat,
          radius      = ~radius_m,
          color       = "#e74c3c", fillColor = "#e74c3c",
          fillOpacity = 0.12, weight = 1,
          label       = ~paste0("\U0001f985 ", name, " \u2014 ", species),
          group       = "Predation Hotspots"
        ) |>

        # ── Layer control ─────────────────────────────────────────────────
        addLayersControl(
          baseGroups    = c("Dark", "Imagery", "Topo", "Street"),
          overlayGroups = c("Waterways", "Stations", "Predation Hotspots"),
          options       = layersControlOptions(collapsed = TRUE)
        ) |>

        showGroup("Waterways") |>
        showGroup("Stations") |>
        showGroup("Predation Hotspots")
    })

    # Update current station marker only — no flyTo
    observe({
      req(current_station())
      stn <- STATIONS |> dplyr::filter(id == current_station())
      req(nrow(stn) > 0, !is.na(stn$lon))

      leafletProxy(ns("map")) |>
        clearGroup("current") |>
        # Glow ring
        addCircleMarkers(
          lng = stn$lon, lat = stn$lat,
          radius = 18, color = "#ff6b35", fillColor = "#ff6b35",
          fillOpacity = 0.18, weight = 2, group = "current"
        ) |>
        # Main dot
        addCircleMarkers(
          lng = stn$lon, lat = stn$lat,
          radius = 9, color = "#ff6b35", fillColor = "#ff6b35",
          fillOpacity = 0.95, weight = 2,
          popup = paste0(
            "<b style='color:#ff6b35;'>", stn$label, "</b>",
            if (!is.na(stn$rkm)) paste0("<br>River km: ", stn$rkm) else ""
          ),
          group = "current"
        )

      # Show the floating info card
      shinyjs::runjs(sprintf(
        "document.getElementById('%s').style.display='block'",
        ns("info_card")
      ))
    })

    # Card content
    output$card_content <- renderUI({
      info <- station_info_data()
      req(!is.null(info))
      tagList(
        div(style = "font-size:0.72em; color:#4fc3f7; text-transform:uppercase;
                     letter-spacing:1px; margin-bottom:2px;",
            info$phase_lbl),
        div(style = "font-weight:700; font-size:0.95em; margin-bottom:4px;",
            info$label),
        if (!is.na(info$rkm))
          div(style = "font-size:0.8em; color:#aad4e8;",
              paste0("\U0001f4cd River km ", info$rkm, " from ocean")),
        if (!is.null(info$real_count))
          div(style = "margin-top:7px; padding:6px 9px; background:#071a2e;
                       border-left:3px solid #4fc3f7; border-radius:3px;
                       font-size:0.78em; color:#aad4e8;",
              tags$b("Real data: "),
              paste0(info$real_count, " of 500 fish detected here"))
      )
    })
  })
}