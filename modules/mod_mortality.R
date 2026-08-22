# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_mortality.R
# Death screen — shows artist image, cause, narrative, fish count drop
# ══════════════════════════════════════════════════════════════════════════════

mod_mortality_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("death_panel"))
}

mod_mortality_server <- function(id, mortality_event) {
  moduleServer(id, function(input, output, session) {

    output$death_panel <- renderUI({
      ev <- mortality_event()
      req(!is.null(ev))

      if (ev$n_killed == 0) return(NULL)

      img_src   <- get_death_image(ev$cause)
      narrative <- format_narrative(ev$cause, ev$n_killed)
      cause_label <- gsub("_", " ", toupper(ev$cause))

      div(
        class = "mortality-panel",
        style = "border: 2px solid #c0392b; border-radius: 8px;
                 background: #1a0a0a; color: white; overflow: hidden;
                 margin-bottom: 12px;",

        # Image
        div(
          style = "position: relative;",
          tags$img(
            src   = img_src,
            style = "width: 100%; max-height: 220px; object-fit: cover;
                     display: block; opacity: 0.85;"
          ),
          div(
            style = "position: absolute; bottom: 0; left: 0; right: 0;
                     background: linear-gradient(transparent, #1a0a0a);
                     height: 80px;"
          ),
          div(
            style = "position: absolute; top: 8px; right: 8px;
                     background: #c0392b; color: white; padding: 4px 10px;
                     border-radius: 4px; font-size: 0.75em; font-weight: bold;",
            cause_label
          )
        ),

        # Narrative
        div(
          style = "padding: 12px 16px;",
          div(
            style = "font-size: 1.5em; font-weight: 900; color: #c0392b;
                     margin-bottom: 4px;",
            paste0("💀 -", ev$n_killed, " fish")
          ),
          p(style = "margin: 0; color: #ddd; font-size: 0.9em;", narrative),

          # Conservation context
          if (!is.null(ev$context)) {
            div(
              style = "margin-top: 10px; padding: 8px; background: #0d1f2d;
                       border-left: 3px solid #4fc3f7; border-radius: 2px;
                       font-size: 0.82em; color: #aad4e8;",
              tags$b("Why this happens: "), ev$context
            )
          }
        )
      )
    })
  })
}
