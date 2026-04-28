library(shiny)
library(leaflet)
library(bslib)
library(dplyr)
library(leaflet.extras)
library(DT)
library(plotly)

# Generate sample rainfall data for Columbia County, WA
set.seed(123)
n_points <- 50

# Generate yearly rainfall data (2019-2023) for each point
years <- 2019:2023
rainfall_yearly <- expand.grid(
  point_id = 1:n_points,
  year = years
) %>%
  mutate(
    rainfall_mm = runif(n(), 0, 100)
  )

rainfall_data <- data.frame(
  point_id = 1:n_points,
  lat = runif(n_points, 46.2, 46.5),
  lon = runif(n_points, -118.1, -117.6),
  rainfall_mm = runif(n_points, 0, 100)
)

# Columbia County boundaries
columbia_bounds <- list(
  min_lat = 46.2,
  max_lat = 46.5,
  min_lon = -118.1,
  max_lon = -117.6
)

ui <- navset_pill(
  nav_panel(
    title = "Map",
    page_sidebar(
      title = "Columbia County Rainfall Visualization",
      theme = bs_theme(bootswatch = "minty"),
      
      sidebar = sidebar(
        title = "Search Location",
        card(
          card_body(
            textInput("search", "Enter coordinates", 
                     placeholder = "46.3232, -117.9698"),
            actionButton("go", "Search", class = "btn-primary"),
            div(style = "margin-top: 10px;",
                textOutput("search_message"))
          )
        ),
        card(
          card_body(
            "Enter coordinates (e.g., '46.3232, -117.9698'). Use the search icon on the map for address search."
          )
        ),
        card(
          card_header("Nearest Point Information"),
          card_body(
            uiOutput("point_info")
          )
        )
      ),
      
      card(
        card_header("Columbia County Rainfall Distribution"),
        card_body(
          leafletOutput("map", height = "70vh")
        )
      )
    )
  ),
  nav_panel(
    title = "Data Table",
    card(
      card_header("Rainfall Data Points"),
      card_body(
        DTOutput("points_table")
      )
    )
  ),
  nav_panel(
    title = "Plots",
    layout_columns(
      card(
        card_header("Yearly Rainfall Trends"),
        card_body(
          plotlyOutput("rainfall_trend")
        )
      ),
      card(
        card_header("Monthly Distribution"),
        card_body(
          plotlyOutput("rainfall_boxplot")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Create reactive values
  search_message <- reactiveVal("")
  selected_point <- reactiveVal(NULL)
  nearest_point_data <- reactiveVal(NULL)
  click_marker <- reactiveVal(NULL)
  
  # Function to find nearest point
  find_nearest_point <- function(click_lat, click_lng) {
    distances <- sqrt((rainfall_data$lat - click_lat)^2 + 
                     (rainfall_data$lon - click_lng)^2)
    nearest_idx <- which.min(distances)
    rainfall_data[nearest_idx, ]
  }
  
  output$search_message <- renderText({
    search_message()
  })
  
  output$point_info <- renderUI({
    point_data <- nearest_point_data()
    if (is.null(point_data)) {
      return(p("Click on the map to see information about the nearest rainfall point."))
    }
    
    div(
      p(strong("Point ID: "), point_data$point_id),
      p(strong("Latitude: "), round(point_data$lat, 4)),
      p(strong("Longitude: "), round(point_data$lon, 4)),
      p(strong("Rainfall: "), round(point_data$rainfall_mm, 1), " mm")
    )
  })
  
  # Initialize the map
  output$map <- renderLeaflet({
    leaflet(rainfall_data) %>%
      addTiles() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        ~lon, ~lat,
        layerId = ~point_id,
        radius = ~rainfall_mm/5,
        color = "blue",
        fillOpacity = 0.7,
        popup = ~paste("Point ID:", point_id, "<br>Rainfall:", round(rainfall_mm, 1), "mm")
      ) %>%
      addSearchOSM() %>%
      setView(lng = -117.95, lat = 46.35, zoom = 10) %>%
      addRectangles(
        lng1 = columbia_bounds$min_lon, 
        lat1 = columbia_bounds$min_lat,
        lng2 = columbia_bounds$max_lon, 
        lat2 = columbia_bounds$max_lat,
        fillColor = "transparent",
        color = "red",
        weight = 2
      )
  })
  
  # Create the data table
  output$points_table <- renderDT({
    dt <- datatable(
      rainfall_data,
      selection = 'single',
      options = list(pageLength = 10),
      rownames = FALSE
    )
    
    if (!is.null(selected_point())) {
      dt %>% formatStyle(
        columns = 0,
        target = 'row',
        backgroundColor = styleEqual(selected_point(), 'yellow')
      )
    } else {
      dt
    }
  })
  
  # Rainfall trend plot
  output$rainfall_trend <- renderPlotly({
    point_data <- nearest_point_data()
    if (is.null(point_data)) {
      return(NULL)
    }
    
    yearly_data <- rainfall_yearly %>%
      filter(point_id == point_data$point_id)
    
    plot_ly(yearly_data, x = ~year, y = ~rainfall_mm, type = 'scatter', mode = 'lines+markers') %>%
      layout(
        title = paste("Yearly Rainfall Trend for Point", point_data$point_id),
        xaxis = list(title = "Year"),
        yaxis = list(title = "Rainfall (mm)")
      )
  })
  
  # Rainfall boxplot
  output$rainfall_boxplot <- renderPlotly({
    point_data <- nearest_point_data()
    if (is.null(point_data)) {
      return(NULL)
    }
    
    yearly_data <- rainfall_yearly %>%
      filter(point_id == point_data$point_id)
    
    plot_ly(yearly_data, y = ~rainfall_mm, type = "box") %>%
      layout(
        title = paste("Rainfall Distribution for Point", point_data$point_id),
        yaxis = list(title = "Rainfall (mm)")
      )
  })
  
  # Update map with click marker
  observe({
    click_data <- click_marker()
    if (!is.null(click_data)) {
      leafletProxy("map") %>%
        clearGroup("click_marker") %>%
        addCircleMarkers(
          lng = click_data$lng, 
          lat = click_data$lat,
          color = "red",
          radius = 8,
          group = "click_marker"
        )
    }
  })
  
  # Handle map clicks
  observeEvent(input$map_click, {
    click <- input$map_click
    nearest <- find_nearest_point(click$lat, click$lng)
    nearest_point_data(nearest)
    selected_point(nearest$point_id)
    click_marker(click)
    
    proxy <- dataTableProxy("points_table")
    proxy %>% selectRows(nearest$point_id)
  })
  
  observeEvent(input$map_marker_click, {
    click <- input$map_marker_click
    clicked_point <- rainfall_data[rainfall_data$point_id == click$id, ]
    nearest_point_data(clicked_point)
    selected_point(click$id)
    
    # Store marker location
    click_marker(list(
      lat = clicked_point$lat,
      lng = clicked_point$lon
    ))
    
    proxy <- dataTableProxy("points_table")
    proxy %>% selectRows(as.numeric(click$id))
  })
  
  observeEvent(input$go, {
    req(input$search)
    proxy <- leafletProxy("map")
    
    if (grepl("^\\s*-?\\d+\\.?\\d*\\s*,\\s*-?\\d+\\.?\\d*\\s*$", input$search)) {
      coords <- as.numeric(strsplit(input$search, ",")[[1]])
      proxy %>% setView(lng = coords[2], lat = coords[1], zoom = 13)
      search_message("Location found!")
    } else {
      search_message("Please enter valid coordinates (e.g., '46.3232, -117.9698')")
    }
  })
}

shinyApp(ui, server)
