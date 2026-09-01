# ══════════════════════════════════════════════════════════════════════════════
# data/questions.R
# All quiz questions — pre-game, in-game, and ocean/return
# ══════════════════════════════════════════════════════════════════════════════

PREGAME_BONUS_PER_Q <- 25

# ── Pre-game: Juvenile Habitat BMPs ──────────────────────────────────────────
PREGAME_QUESTIONS <- list(
  list(
    id         = "bda",
    q          = "A beaver dam analogue (BDA) is installed in a tributary. What is the most likely benefit for juvenile steelhead?",
    choices    = c(
      "It blocks adult salmon from migrating upstream",
      "It creates deeper pools, traps sediment, raises the water table, and cools stream temperatures",
      "It makes the water hotter",
      "It increases water velocity which helps smolts migrate faster"
    ),
    correct    = 2,
    explain    = "BDAs slow water velocity causing sediment to drop out of suspension. They raise the water table, create pool habitat, and cool temperatures through hyporheic exchange — all critical for juvenile survival.",
    bonus_text = "BDA installed — cooler water and better rearing habitat"
  ),
  list(
    id         = "tillage",
    q          = "A farmer upstream switches from conventional tillage to no-till practices. How does this help juvenile steelhead?",
    choices    = c(
      "No-till fields produce more food that washes into the stream",
      "It reduces fine sediment runoff that clogs spawning gravel and gill surfaces",
      "It lowers stream velocity making it easier for juveniles to swim",
      "It has no effect on fish — tillage only affects crops"
    ),
    correct    = 2,
    explain    = "Reduced sediment keeps spawning gravel clean and water clear. Juveniles have higher survival when they're not fighting clogged gills and buried redds.",
    bonus_text = "No-till farming adopted — reduced sediment in spawning gravels"
  ),
  list(
    id         = "pools",
    q          = "Crews install large woody debris in a straightened stream reach. What happens to juvenile steelhead survival?",
    choices    = c(
      "The logs block fish passage and increase mortality",
      "Water velocity increases, helping smolts migrate faster",
      "Logs create pools, slow flow, and cool water — improving juvenile rearing habitat",
      "Logs increase predation risk with no survival benefit"
    ),
    correct    = 3,
    explain    = "Pool habitat is critical for juvenile rearing. Deeper, cooler pools with structure give fish refuge from predators and thermal stress.",
    bonus_text = "Large woody debris installed — pool habitat restored"
  )
)

# ── In-game questions — keyed to station id ───────────────────────────────────
# fish_back = fish returned to cohort if answered correctly
INGAME_QUESTIONS <- list(

  quiz_1 = list(
    id         = "quiz_1",
    title      = "Conservation Stop #1",
    q          = "What is a 'spill program' at a dam and why does it help juvenile salmon?",
    choices    = c(
      "Water is released downstream to flush fish through faster",
      "Water passes over the spillway instead of through turbines, reducing injury and mortality",
      "Fish are collected and trucked around the dam",
      "The dam is partially dismantled during migration season"
    ),
    correct    = 2,
    explain    = "Spill bypasses turbines entirely. Studies show spill can double juvenile survival at some dams — but it reduces power generation, creating a real tradeoff.",
    fish_back  = 20,
    bonus_text = "Spill program knowledge — 20 fish saved at McNary"
  ),

  quiz_2 = list(
    id         = "quiz_2",
    title      = "Conservation Stop #2",
    q          = "The Columbia Basin Pikeminnow Sport Reward Program pays anglers to catch northern pikeminnow. Why?",
    choices    = c(
      "Pikeminnow are an invasive species that need to be eradicated",
      "Pikeminnow are a valuable food fish that supports local economies",
      "Each large pikeminnow removed can save 50–800 juvenile salmon per year",
      "Pikeminnow compete with salmon for spawning habitat"
    ),
    correct    = 3,
    explain    = "A single large pikeminnow can eat hundreds of smolts per season. The bounty program removes over 100,000 pikeminnow annually — one of the most cost-effective salmon survival tools available.",
    fish_back  = 20,
    bonus_text = "Pikeminnow bounty knowledge — 20 fish saved below John Day"
  ),

  quiz_3 = list(
    id         = "quiz_3",
    title      = "Conservation Stop #3",
    q          = "Why do Caspian Terns and cormorants concentrate at sites like Miller Rocks and Blalock Islands during salmon migration?",
    choices    = c(
      "The islands provide nesting habitat directly over the salmon migration corridor",
      "The water is warmer near islands which attracts more fish",
      "Islands are protected from human disturbance by law",
      "Prevailing winds push salmon toward island shorelines"
    ),
    correct    = 1,
    explain    = "Nesting colonies position birds directly over the migration corridor. At peak migration a single colony can consume thousands of PIT-tagged smolts — we know because the tags are recovered at nest sites.",
    fish_back  = 20,
    bonus_text = "Avian predation knowledge — 20 fish saved near The Dalles"
  ),

  ocean_fishing = list(
    id         = "ocean_fishing",
    title      = "Ocean Quiz",
    q          = "Commercial fishing fleets target salmon in the Pacific. Which fishing method has the highest salmon bycatch?",
    choices    = c(
      "Fly fishing",
      "Drift gillnets and trawl nets which catch non-target species",
      "Pole and line fishing",
      "Fish traps"
    ),
    correct    = 2,
    explain    = "Drift gillnets and trawls are non-selective — they catch whatever swims into them. Bycatch of non-target salmon species is a major issue. Some fisheries have moved to more selective gear.",
    fish_back  = 15,
    bonus_text = "Fisheries knowledge — 15 fish avoided commercial nets"
  ),

  adult_tire = list(
    id         = "adult_tire",
    title      = "Water Quality Quiz",
    q          = "Researchers discovered that coho salmon were dying in urban streams from a chemical called 6PPD-quinone. Where does it come from?",
    choices    = c(
      "Agricultural pesticides sprayed on nearby fields",
      "A byproduct of tire rubber that washes off roads during rain events",
      "Chlorine from municipal water treatment plants",
      "Industrial wastewater from manufacturing facilities"
    ),
    correct    = 2,
    explain    = "6PPD is added to tires to prevent cracking. When tires wear on roads, the chemical washes into streams during rain. It's nearly 100% lethal to coho — identified by UW researchers in 2020. No fix yet at scale.",
    fish_back  = 15,
    bonus_text = "Water quality knowledge — 15 fish survived chemical exposure"
  )
)