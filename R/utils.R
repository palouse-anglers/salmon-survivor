# ══════════════════════════════════════════════════════════════════════════════
# R/utils.R
# Shared helper functions
# ══════════════════════════════════════════════════════════════════════════════

`%||%` <- function(a, b) if (!is.null(a) && length(a) > 0 && !is.na(a[1])) a else b

# ── Fish emoji counter ────────────────────────────────────────────────────────
# Returns a visual string of fish emoji scaled to n (max 50 shown)
fish_emoji_bar <- function(n, max_show = 50, total = COHORT_START) {
  if (n <= 0) return("💀 No fish remaining")
  n_show  <- min(n, max_show)
  scale   <- ceiling(total / max_show)
  emoji   <- paste(rep("🐟", n_show), collapse = "")
  if (n > max_show) {
    paste0(emoji, sprintf(" × %d  (%d fish)", scale, n))
  } else {
    paste0(emoji, sprintf("  (%d fish)", n))
  }
}

# ── Format death narrative ────────────────────────────────────────────────────
format_narrative <- function(cause, n_killed) {
  template <- DEATH_NARRATIVES[[cause]] %||%
    DEATH_NARRATIVES[["other"]]
  gsub("\\{n\\}", n_killed, template)
}

# ── Get death image URL/path ──────────────────────────────────────────────────
get_death_image <- function(cause) {
  DEATH_IMAGES[[cause]] %||% DEATH_IMAGES[["placeholder"]]
}

# ── Phase label ───────────────────────────────────────────────────────────────
phase_label <- function(phase) {
  switch(phase,
    outbound = "⬇️ Outbound Migration — Juvenile",
    ocean    = "🌊 Ocean Phase",
    return   = "⬆️ Adult Return Migration",
    phase
  )
}

# ── Pct of original cohort ───────────────────────────────────────────────────
pct_remaining <- function(n, total = COHORT_START) {
  sprintf("%.1f%%", n / total * 100)
}

# ── Color for cohort counter based on % remaining ────────────────────────────
counter_color <- function(n, total = COHORT_START) {
  pct <- n / total
  if (pct > 0.50) "#2d8a4e"       # green
  else if (pct > 0.20) "#e67e22"  # orange
  else if (pct > 0.05) "#c0392b"  # red
  else "#7f0000"                  # dark red
}
