# ══════════════════════════════════════════════════════════════════════════════
# modules/mod_quiz.R
# Quiz tab — 5 questions drawn randomly from the pool each game
# ══════════════════════════════════════════════════════════════════════════════

# ── Old questions (replaced) ──────────────────────────────────────────────────
# QUIZ_QUESTIONS <- list(
#   list(
#     q        = "Out of 500 juvenile salmon released from the Walla Walla Basin, how many were confirmed returning home as adults?",
#     choices  = c("About 50 (10%)", "About 25 (5%)", "About 5 (1%)", "Just 1 (0.2%)"),
#     correct  = 4,
#     explain  = "Only 1 fish out of 500 was confirmed at Nursery Bridge — a 0.2% return rate."
#   ),
#   list(
#     q        = "In the real Walla Walla data, avian predators killed 7 fish. How many fish made it past the estuary?",
#     choices  = c("50 fish", "20 fish", "7 fish", "100 fish"),
#     correct  = 3,
#     explain  = "Exactly 7 fish were detected in the estuary — the same number killed by birds."
#   ),
#   list(
#     q        = "What does SAR stand for, and what rate is needed just to prevent population decline?",
#     choices  = c("Salmon Adult Ratio — 10%", "Smolt-to-Adult Return — 2%",
#                  "Spawner Assessment Rate — 5%", "Seasonal Adult Return — 4%"),
#     correct  = 2,
#     explain  = "SAR = Smolt-to-Adult Return. A 2% SAR is the minimum to maintain population levels."
#   ),
#   list(
#     q        = "Why do salmon from the John Day and Yakima rivers have much higher survival rates than Snake River salmon?",
#     choices  = c("They are a different, hardier species",
#                  "They receive more hatchery supplementation",
#                  "They pass through fewer dams",
#                  "They have better ocean conditions"),
#     correct  = 3,
#     explain  = "Snake River fish must pass 8 dams. John Day fish pass only 3-4."
#   ),
#   list(
#     q        = "A PIT tag recovered at a bird colony tells scientists what?",
#     choices  = c("The fish survived and spawned successfully",
#                  "The exact location and date the fish was eaten by a bird",
#                  "The fish was caught by a fisherman",
#                  "The fish made it to the ocean"),
#     correct  = 2,
#     explain  = "PIT tag readers at bird colonies scan regurgitated tags and bones."
#   )
# )

# ── Full question pool (28 questions) ─────────────────────────────────────────
QUIZ_QUESTION_POOL <- list(
  list(
    q       = "When young Chinook salmon in the Walla Walla River get ready to head downstream to the ocean, their bodies turn silvery and their scales get shiny. What is this change called?",
    choices = c("Smoltification", "Hibernation", "Camouflage", "Molting"),
    correct = 1,
    explain = "Smoltification is the physiological process that prepares juvenile salmon for life in salt water — including silvery colouring, scale changes, and shifts in how their kidneys and gills handle salt."
  ),
  list(
    q       = "Why do juvenile salmon usually leave the Walla Walla River and migrate downstream in spring?",
    choices = c(
      "The water becomes too cold for them to survive",
      "Rising snowmelt increases river flow and helps carry them downstream towards the ocean",
      "They are following adult salmon to food sources",
      "Predators disappear from the river every spring"
    ),
    correct = 2,
    explain = "Spring snowmelt raises river levels and current speed, giving smolts the flow energy they need to move quickly downstream toward the ocean."
  ),
  list(
    q       = "On their way to the ocean, young salmon must pass several large dams on the Columbia and Snake Rivers. What is one of the biggest dangers a dam creates for them?",
    choices = c(
      "Dams make the river water too clear to swim in",
      "Dams add extra food that slows the fish down",
      "Passing through the turbines can injure or kill them",
      "Dams make the current too fast to be dangerous"
    ),
    correct = 3,
    explain = "Turbine blades, pressure changes, and cavitation can injure or kill smolts passing through hydroelectric dams — one of the leading causes of mortality for Snake River salmon."
  ),
  list(
    q       = "What is a 'juvenile bypass system' at a dam?",
    choices = c(
      "A pipe that drains water out of the reservoir",
      "A feeding station built for young salmon",
      "A road built for maintenance trucks",
      "A route of screens and pipes that lets young salmon avoid the turbines"
    ),
    correct = 4,
    explain = "Juvenile bypass systems use screens to divert smolts away from turbine intakes and route them safely around the dam through dedicated pipes and channels."
  ),
  list(
    q       = "Sometimes biologists collect young salmon at a dam and move them downstream in a truck or barge instead of letting them swim the whole way. Why?",
    choices = c(
      "Because young salmon are not able to swim at all",
      "To help the fish skip the dangers of passing through several dams and reservoirs",
      "To make the fish grow bigger before release",
      "Because it is required for every salmon every year"
    ),
    correct = 2,
    explain = "Transportation programs barge or truck smolts past multiple dams and slow reservoirs, improving survival by reducing both turbine passage and the predation gauntlet in reservoir habitat."
  ),
  list(
    q       = "The slow-moving water that pools up behind a dam is called a reservoir. Why can reservoirs be risky for young salmon swimming downstream?",
    choices = c(
      "Slower water gives predators more time to find and catch them",
      "Reservoirs are completely frozen year-round",
      "Reservoirs push salmon back upstream",
      "Reservoirs have no water in them at all"
    ),
    correct = 1,
    explain = "Reservoirs replace fast-moving river habitat with slow, warm, predator-rich water. Smolts spend more time exposed to northern pikeminnow, birds, and other predators than they would in a free-flowing river."
  ),
  list(
    q       = "Northern pikeminnow are a fish native to the Columbia River. Why do they matter so much to young salmon?",
    choices = c(
      "Pikeminnow help build fish ladders",
      "Pikeminnow eat only algae and plants",
      "Pikeminnow live only in the ocean, far from salmon",
      "Pikeminnow eat large numbers of juvenile salmon, especially near dams"
    ),
    correct = 4,
    explain = "Northern pikeminnow are voracious predators that congregate below dams where disoriented smolts are easy targets. A single large pikeminnow can consume hundreds of juveniles in a season."
  ),
  list(
    q       = "Caspian terns and cormorants nest on islands in the Columbia River. Why can these birds be a problem for young salmon?",
    choices = c(
      "The birds build small dams in the estuary",
      "The birds only eat insects that live on the riverbank",
      "The birds dive into the water and eat juvenile salmon",
      "The birds scare pikeminnow away from salmon"
    ),
    correct = 3,
    explain = "Caspian terns and double-crested cormorants nest in large colonies directly over the salmon migration corridor and dive to catch smolts. PIT tags recovered at nest sites confirm they consume thousands of tagged fish annually."
  ),
  list(
    q       = "When water rushes over a dam's spillway, it can trap tiny bubbles of air and push extra gas into the river. If a young salmon absorbs too much of this dissolved gas, what can happen?",
    choices = c(
      "It grows an extra set of gills",
      "Its scales change to a brighter color",
      "Nothing happens — dissolved gas is harmless to fish",
      "It can develop gas bubble disease, similar to the bends in scuba divers"
    ),
    correct = 4,
    explain = "Total dissolved gas supersaturation from spill can cause gas bubble disease — bubbles form in the blood and tissues of fish, similar to decompression sickness. Biologists balance spill benefits against this risk."
  ),
  list(
    q       = "Biologists often insert a tiny electronic tag called a PIT tag into a young salmon. What is this tag used for?",
    choices = c(
      "Helping the fish swim faster through turbines",
      "Automatically feeding the fish in the river",
      "Tracking when and where the fish passes monitoring stations on its journey",
      "Changing the color of the fish's scales"
    ),
    correct = 3,
    explain = "PIT (Passive Integrated Transponder) tags are passive RFID chips detected by antenna arrays at dams and other monitoring stations, letting biologists reconstruct each fish's journey and calculate survival rates."
  ),
  list(
    q       = "Before reaching the open ocean, young salmon spend time in the estuary, where the river mixes with the sea. Why is this stopover important?",
    choices = c(
      "It is where they lay their eggs for the first time",
      "It lets their bodies gradually adjust to salt water while they feed and grow",
      "It is where their adipose fin grows in",
      "It has no real importance to a salmon's survival"
    ),
    correct = 2,
    explain = "The estuary is a transition zone where smolts complete osmoregulatory adjustments to salt water, build up energy reserves, and grow before entering the open Pacific — all critical for ocean survival."
  ),
  list(
    q       = "What change happens inside a young salmon's body that lets it survive in salty ocean water after growing up in fresh water?",
    choices = c(
      "Its gills and kidneys start working differently to manage salt",
      "Its bones turn into cartilage",
      "It stops needing to breathe through gills",
      "It grows a brand-new stomach"
    ),
    correct = 1,
    explain = "During smoltification, the gills switch from actively taking in salt (freshwater mode) to actively excreting it, and the kidneys reduce urine output — allowing the fish to stay hydrated in salt water."
  ),
  list(
    q       = "About how long do Chinook salmon from the Walla Walla River typically stay in the ocean, feeding and growing, before they return to spawn?",
    choices = c(
      "Only a few days",
      "Exactly ten years for every single fish",
      "Roughly one to five years, depending on the run",
      "They never actually enter the ocean"
    ),
    correct = 3,
    explain = "Walla Walla Chinook are anadromous — they spend one to five years at sea (varying by individual and run type) before hormones trigger the return migration to their natal stream."
  ),
  list(
    q       = "While living in the ocean, Chinook salmon face predators such as orcas, seals, sea lions, and sharks. What helps salmon avoid being eaten by many of these predators?",
    choices = c(
      "Making loud calls to warn each other of danger",
      "Growing sharp spines along their backs",
      "Staying completely still for months at a time",
      "Traveling in schools and having silvery, countershaded coloring that blends with the light"
    ),
    correct = 4,
    explain = "Countershading (dark back, silver belly) makes salmon harder to see from above or below. Schooling behaviour also confuses predators and reduces each individual's risk of being caught."
  ),
  list(
    q       = "Conditions in the ocean, like water temperature and how much food is available, change from year to year. How can these changing ocean conditions affect salmon?",
    choices = c(
      "Poor ocean conditions can mean less food, so fewer young salmon survive to adulthood",
      "Ocean conditions never have any effect on salmon",
      "Warmer ocean water always helps salmon grow faster and survive better",
      "Only what happens in freshwater rivers matters to salmon"
    ),
    correct = 1,
    explain = "Ocean productivity — driven by upwelling, temperature, and prey availability — is one of the strongest determinants of salmon survival. Poor conditions (e.g., warm 'blob' events) can dramatically reduce marine survival rates."
  ),
  list(
    q       = "When it's time to come home, how do adult Chinook salmon find their way back to the Walla Walla River instead of some other river?",
    choices = c(
      "They follow ocean currents completely at random",
      "They imprinted on the unique smell of their home stream as juveniles and follow that scent back",
      "They travel together with fish from every other river",
      "They rely only on the position of the sun to navigate"
    ),
    correct = 2,
    explain = "Olfactory imprinting during the juvenile stage creates a chemical 'memory' of the home stream's unique scent signature. Adults use this memory — plus magnetic sensing and ocean cues — to navigate thousands of miles back."
  ),
  list(
    q       = "Adult salmon swimming upstream to spawn stop eating and live off stored body fat. Why is this such a demanding part of their journey?",
    choices = c(
      "They must swim hundreds of miles upstream and past dams while using up limited energy",
      "They actually eat more food than ever during this trip",
      "The river flows downstream faster than they can possibly swim",
      "They are able to rest in one place for several months"
    ),
    correct = 1,
    explain = "Adult Chinook may swim 900+ miles upstream, ascending fish ladders at multiple dams, all without eating. They rely entirely on stored lipids and protein — fish that enter the river in poor condition rarely reach spawning grounds."
  ),
  list(
    q       = "Just like young salmon heading downstream, adult salmon returning upstream must get past the same large dams. What structure helps adults climb past a dam?",
    choices = c(
      "An elevator built only for boats",
      "A dry tunnel drilled straight through solid rock",
      "A net that lifts fish up and over the dam",
      "A fish ladder made of a series of pools that step upward like stairs"
    ),
    correct = 4,
    explain = "Fish ladders are a series of stepped pools that allow adult salmon to rest and then leap upward incrementally, eventually passing over the dam. Their effectiveness varies by dam design and river conditions."
  ),
  list(
    q       = "As Chinook salmon get closer to spawning, their bodies change dramatically — males may develop a hooked jaw and both sexes can turn darker or reddish. What causes these changes?",
    choices = c(
      "The changes are caused only by eating different food",
      "These changes happen only in hatchery-raised fish",
      "Hormones triggered as the fish approaches spawning cause these physical changes",
      "The changes are random and don't mean anything"
    ),
    correct = 3,
    explain = "A hormonal cascade driven by reproductive maturation causes the kype (hooked jaw), colour changes, and body shape shifts. These secondary sexual characteristics signal reproductive readiness and play a role in mate selection."
  ),
  list(
    q       = "A female Chinook salmon digs a nest in the streambed gravel called a redd to lay her eggs. What happens to most adult Chinook salmon after they finish spawning?",
    choices = c(
      "They swim back to the ocean to spawn again the following year",
      "They die within a week or two, and their bodies return nutrients to the river ecosystem",
      "They stay and live in the river for the rest of their lives",
      "They transform back into juvenile salmon"
    ),
    correct = 2,
    explain = "Pacific salmon are semelparous — they spawn once and die. Decomposing carcasses deliver marine-derived nutrients (nitrogen, phosphorus, carbon) into otherwise nutrient-poor headwater streams, feeding insects, trees, and the next generation of fish."
  ),
  list(
    q       = "What does it mean when scientists call a salmon 'wild'?",
    choices = c(
      "It hatched and grew up in a river from parents that spawned naturally, without any hatchery involved",
      "It has never been seen by a person",
      "It lives only in the deep ocean",
      "It is older than five years"
    ),
    correct = 1,
    explain = "'Wild' refers to fish whose entire life cycle — from egg to adult — occurs naturally in the river, with no hatchery intervention at any stage. This is distinct from 'natural-origin' fish that may have hatchery-origin parents."
  ),
  list(
    q       = "Looking at a salmon's tail, how could you get a clue that it is likely of wild origin rather than hatchery origin?",
    choices = c(
      "It has a much longer tail than any hatchery fish",
      "It is always larger than a hatchery-raised fish",
      "It swims only at night",
      "It still has its small adipose fin, since hatcheries usually clip that fin before release"
    ),
    correct = 4,
    explain = "Most hatcheries clip the adipose fin before releasing fish so that anglers and managers can identify hatchery fish. An intact adipose fin suggests — though doesn't guarantee — wild origin."
  ),
  list(
    q       = "Many wild Chinook salmon and steelhead populations in the Snake and Columbia River basins, including runs that use the Walla Walla River, have declined so much that they now receive special federal protection. What law protects them?",
    choices = c(
      "The Clean Water Act",
      "The Endangered Species Act",
      "The Clean Air Act",
      "The Farm Bill"
    ),
    correct = 2,
    explain = "Snake River Chinook salmon were listed under the Endangered Species Act in 1992. ESA listing triggers federal consultation requirements and recovery planning — but also highlights how precarious these populations have become."
  ),
  list(
    q       = "Within a single wild salmon population, some fish migrate to the ocean earlier, some later, and some spend different numbers of years there before returning. Why do biologists especially value this kind of diversity?",
    choices = c(
      "It means the fish are confused about when to migrate",
      "It provides no real benefit to the population",
      "It spreads out the risk, so a bad year for one group of fish doesn't wipe out the whole population",
      "It happens only in hatchery-raised fish"
    ),
    correct = 3,
    explain = "This 'portfolio effect' — diversity in life-history timing — means that even if ocean or freshwater conditions are bad for one group, other groups may still succeed. It is a key buffer against extinction and is lost when populations decline."
  ),
  list(
    q       = "Wild salmon populations are naturally adapted over many generations to the specific streams where their ancestors spawn. Why does this matter for river restoration projects like reconnecting floodplains or removing levees?",
    choices = c(
      "Protecting and restoring a population's home habitat helps preserve traits that are specially suited to that exact place",
      "It means every wild salmon population is identical to every other",
      "It means restoration work cannot affect wild salmon at all",
      "Local adaptation only matters to hatchery fish"
    ),
    correct = 1,
    explain = "Local adaptation means each population has evolved traits (timing, body size, physiology) matched to its specific habitat. Restoring that habitat allows those locally adapted traits to be expressed and selected for, boosting long-term survival."
  ),
  list(
    q       = "Unlike hatchery-raised salmon, what must wild juvenile salmon do from the very start of their lives in the river?",
    choices = c(
      "Wait for food to be delivered on a set feeding schedule",
      "Grow up together in a concrete raceway",
      "Wait for people to release them on a chosen date",
      "Find their own food and avoid predators in a natural environment from day one"
    ),
    correct = 4,
    explain = "Wild juveniles emerge from redds into the stream and must immediately begin foraging for invertebrates and avoiding predators with no human support — selecting for the behavioural and physiological traits that matter in the wild."
  ),
  list(
    q       = "Wild salmon dig their redds in gravel with good water flow so oxygen can reach the eggs. Why is finding high-quality spawning gravel especially critical for wild fish?",
    choices = c(
      "Their eggs must survive and develop completely on their own in the streambed, with no hatchery help",
      "Wild eggs are collected every year and moved to a hatchery building",
      "Wild salmon do not actually lay their eggs in gravel",
      "Gravel quality only matters for adult salmon swimming upstream"
    ),
    correct = 1,
    explain = "Hatcheries control incubation conditions artificially. Wild eggs, by contrast, are entirely dependent on adequate intergravel flow to deliver oxygen and remove metabolic waste. Fine sediment from erosion can suffocate entire redds."
  ),
  list(
    q       = "Sometimes hatchery-origin salmon spawn naturally alongside wild salmon in the same stream. Why do fisheries biologists watch this closely?",
    choices = c(
      "It always makes the wild population stronger and healthier",
      "It has no effect on the wild population's genetics",
      "Over time it can reduce the genetic fitness and local adaptation of the wild population",
      "It causes the stream itself to change course"
    ),
    correct = 3,
    explain = "Hatchery fish are selected for traits that perform well in artificial conditions, not wild rivers. When they interbreed with wild fish, locally adapted genes can be diluted over generations, reducing the wild population's fitness in its home environment."
  )
)

# ── Number of questions drawn per game ───────────────────────────────────────
QUIZ_N <- 5

# ── UI ────────────────────────────────────────────────────────────────────────
mod_quiz_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("question_ui")),
    hr(),
    uiOutput(ns("feedback_ui"))
  )
}

# ── Server ────────────────────────────────────────────────────────────────────
mod_quiz_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      questions = sample(QUIZ_QUESTION_POOL, QUIZ_N),  # random draw on load
      index     = 1,
      score     = 0,
      answered  = FALSE,
      correct   = NULL
    )

    output$question_ui <- renderUI({
      idx <- rv$index
      if (idx > length(rv$questions)) {
        return(div(
          class = "alert alert-success",
          h4("\U0001f389 Quiz Complete!"),
          p(paste("Score:", rv$score, "out of", length(rv$questions))),
          actionButton(ns("restart_quiz"), "Try Again", class = "btn-success")
        ))
      }

      q <- rv$questions[[idx]]
      tagList(
        p(class = "text-muted mb-1",
          paste("Question", idx, "of", length(rv$questions))),
        h5(q$q, style = "color: #e8f4fd;"),
        div(
          lapply(seq_along(q$choices), function(i) {
            btn_class <- if (rv$answered) {
              if (i == q$correct) "btn-success w-100 mb-2 text-start"
              else if (!rv$correct && !is.null(input[[paste0("ans_", i)]]) &&
                       input[[paste0("ans_", i)]] > 0)
                "btn-danger w-100 mb-2 text-start"
              else "btn-outline-secondary w-100 mb-2 text-start"
            } else {
              "btn-outline-primary w-100 mb-2 text-start"
            }
            actionButton(
              ns(paste0("ans_", i)), q$choices[i],
              class = btn_class,
              style = "color: #e8f4fd; white-space: normal;"
            )
          })
        )
      )
    })

    output$feedback_ui <- renderUI({
      req(rv$answered)
      idx <- rv$index
      if (idx > length(rv$questions)) return(NULL)
      q   <- rv$questions[[idx]]

      tagList(
        div(
          class = if (rv$correct) "alert alert-success" else "alert alert-danger",
          if (rv$correct) "\u2705 Correct!" else "\u274c Not quite.",
          br(), q$explain
        ),
        actionButton(ns("next_q"), "Next \u2192", class = "btn-primary")
      )
    })

    # Answer button handlers
    lapply(seq_len(4), function(i) {
      observeEvent(input[[paste0("ans_", i)]], {
        if (!rv$answered) {
          q          <- rv$questions[[rv$index]]
          rv$correct  <- (i == q$correct)
          if (rv$correct) rv$score <- rv$score + 1
          rv$answered <- TRUE
        }
      }, ignoreNULL = TRUE, ignoreInit = TRUE)
    })

    observeEvent(input$next_q, {
      rv$index    <- rv$index + 1
      rv$answered <- FALSE
      rv$correct  <- NULL
    })

    observeEvent(input$restart_quiz, {
      rv$questions <- sample(QUIZ_QUESTION_POOL, QUIZ_N)  # new random draw
      rv$index     <- 1
      rv$score     <- 0
      rv$answered  <- FALSE
      rv$correct   <- NULL
    })
  })
}
