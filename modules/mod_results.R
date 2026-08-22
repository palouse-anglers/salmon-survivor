# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_results.R
# End screen — win (fish reached Nursery Bridge) or lose
# ══════════════════════════════════════════════════════════════════════════════

mod_results_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("results_panel"))
}

mod_results_server <- function(id, final_count, journey_log, on_restart) {
  moduleServer(id, function(input, output, session) {

    output$results_panel <- renderUI({
      n   <- final_count()
      won <- n >= WIN_MINIMUM
      log <- journey_log()

      if (won) {
        # WIN SCREEN
        div(
          style = "background: linear-gradient(135deg, #0d2a1a, #1a4a2a);
                   border: 2px solid #2d8a4e; border-radius: 12px;
                   padding: 24px; color: white; text-align: center;",

          tags$img(
            src   = DEATH_IMAGES[["win_spawning"]],
            style = "width:100%; max-height:240px; object-fit:cover;
                     border-radius:8px; margin-bottom:16px; opacity:0.9;"
          ),

          h2(style = "color: #2d8a4e;", "🏆 You Made It Home!"),

          p(style = "font-size: 1.1em; color: #aaddbb;",
            paste0(n, " fish out of ", COHORT_START,
                   " returned to spawn at Nursery Bridge.")),

          div(
            style = "background:#071a0e; padding:16px; border-radius:8px;
                     margin: 16px 0; text-align:left;",
            p(style = "margin:0; color:#aaddbb; font-size:0.9em;",
              "After ", sample(300:900, 1), " days and 900 miles, your fish dug
               their redds in the gravel of the South Fork Walla Walla River.
               They spawned, and they died — but their bodies will fertilize
               this stream for years. Their offspring will make this same journey.")
          ),

          # Journey summary table
          h5(style = "color:#aaddbb; text-align:left;", "Your Journey:"),
          tableOutput(session$ns("journey_table")),

          actionButton(session$ns("restart"), "🔄 Run New Cohort",
                       class = "btn-success btn-lg")
        )

      } else {
        # LOSE SCREEN
        div(
          style = "background: linear-gradient(135deg, #1a0a0a, #2a1010);
                   border: 2px solid #c0392b; border-radius: 12px;
                   padding: 24px; color: white; text-align: center;",

          h2(style = "color: #c0392b;", "💀 No Fish Made It Home"),

          p(style = "color: #ddaaaa; font-size: 1em;",
            paste0("Your cohort of ", COHORT_START,
                   " fish was reduced to zero before reaching Nursery Bridge.",
                   " This happens. In 2015, Snake River chinook SAR was 0.35%.")),

          div(
            style = "background:#1a0707; padding:16px; border-radius:8px;
                     margin: 16px 0; text-align:left;",
            p(style = "margin:0; color:#ddaaaa; font-size:0.9em;",
              "In the real Walla Walla Basin data, only 1 fish out of 500
               was confirmed back at Nursery Bridge. Snake River salmon and
               steelhead are listed as Threatened under the Endangered Species Act
               — and this is why.")
          ),

          h5(style = "color:#ddaaaa; text-align:left;", "Where Your Fish Were Lost:"),
          tableOutput(session$ns("journey_table")),

          actionButton(session$ns("restart"), "🔄 Try Again",
                       class = "btn-danger btn-lg")
        )
      }
    })

    output$journey_table <- renderTable({
      log <- journey_log()
      req(!is.null(log))
      log |>
        dplyr::select(label, n_arrive, n_killed, cause) |>
        dplyr::mutate(
          cause = ifelse(is.na(cause), "—", gsub("_", " ", cause)),
          n_killed = ifelse(n_killed == 0, "—", as.character(n_killed))
        ) |>
        dplyr::rename(
          Station    = label,
          `Fish Alive` = n_arrive,
          `Fish Lost`  = n_killed,
          `Cause`      = cause
        )
    }, striped = TRUE, hover = TRUE, bordered = TRUE,
       align = "lccl")

    observeEvent(input$restart, { on_restart() })
  })
}
