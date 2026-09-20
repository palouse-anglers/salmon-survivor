# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_intro_video.R
# Generic interstitial video screen with a Skip button.
# Supports:
#   - YouTube URLs (youtube.com/watch?v=XXX or youtu.be/XXX) → converted to embed
#   - Any other URL  → used as-is as the iframe src (e.g. DVIDS embed links)
# Calls on_done() when the player clicks Skip.
# ══════════════════════════════════════════════════════════════════════════════

.make_embed_url <- function(url) {
  yt_match <- regmatches(url,
    regexpr("(?<=v=)[^&]+|(?<=youtu\\.be/)[^?]+", url, perl = TRUE))
  if (length(yt_match) > 0 && nchar(yt_match) > 0) {
    paste0("https://www.youtube.com/embed/", yt_match, "?autoplay=1&rel=0")
  } else {
    url  # already an embed src (DVIDS, Vimeo, etc.)
  }
}

mod_intro_video_ui <- function(id, video_url,
                                title   = "Game Overview",
                                btn_lbl = "\u23ed\ufe0f Skip Video \u2192 Start Game") {
  ns        <- NS(id)
  embed_url <- .make_embed_url(video_url)

  div(
    style = "max-width:820px; margin:40px auto; padding:0 16px;",
    div(
      style = "background:linear-gradient(135deg,#0a1628,#0d2f4f);
               border:2px solid #4fc3f7; border-radius:12px;
               padding:28px 32px; color:white; text-align:center;",

      h3(style = "color:#4fc3f7; margin-top:0; margin-bottom:20px;", title),

      # 16:9 responsive wrapper
      div(
        style = "position:relative; padding-bottom:56.25%; height:0;
                 overflow:hidden; border-radius:8px; margin-bottom:20px;
                 box-shadow:0 4px 28px rgba(79,195,247,0.35);",
        tags$iframe(
          src             = embed_url,
          width           = "800",
          height          = "450",
          frameborder     = "0",
          style           = "position:absolute; top:0; left:0;
                             width:100%; height:100%; border:0;",
          allow           = "autoplay; encrypted-media; picture-in-picture",
          allowfullscreen = NA,
          allowtransparency = NA
        )
      ),

      # Game overview text — only shown on the intro video screen
      if (btn_lbl == "\u23ed\ufe0f Skip Video \u2192 Start Game") {
        div(
          style = "background:rgba(255,255,255,0.07); border-radius:8px;
                   padding:16px 20px; margin-bottom:20px; text-align:left;",
          tags$ul(
            style = "margin:0; padding-left:1.4em; line-height:1.9; font-size:1.05em;",
            tags$li("Start with a cohort of ", tags$strong("500 fish")),
            tags$li("Fish will die from ", tags$strong("predation"), " and ", tags$strong("dams"), " during migration"),
            tags$li("Answer quiz questions correctly to ", tags$strong("reduce mortalities")),
            tags$li("Win by having ", tags$strong("at least one fish"), " return home to spawn as an adult")
          )
        )
      },

      actionButton(
        ns("skip"), btn_lbl,
        class = "btn-outline-light btn-lg",
        style = "font-size:1em; padding:10px 28px;"
      )
    )
  )
}

mod_intro_video_server <- function(id, on_done) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$skip, {
      on_done()
    }, ignoreNULL = TRUE, ignoreInit = TRUE)
  })
}
