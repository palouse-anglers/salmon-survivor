# ══════════════════════════════════════════════════════════════════════════════
# data/hotspots.R
# Real predation hotspots parsed from Predation_Hot_Spots.kmz
# Name, coordinates, predator species all extracted directly from KMZ
# ══════════════════════════════════════════════════════════════════════════════

AVIAN_HOTSPOTS <- tibble::tribble(
  ~name,                                                          ~lat,             ~lon,              ~radius_m,  ~species,                                   ~mortality_cause,
  "Alpowa Creek Mouth",                                           46.41570499282508, -117.208356257944,  800,       "Pelicans",                                 "avian_pelican",
  "Lower Tucannon River",                                         46.5526741100328,  -118.1765936710937, 1200,      "Walleye, Bass, Northern Pikeminnow",       "pikeminnow",
  "Lower Walla Walla River",                                      46.05710464655545, -118.8704670909373, 1500,      "Bass",                                     "predator_bass",
  "Lake Wallula (50% survival to McNary)",                        46.00229778695942, -118.9871433130448, 3000,      "Walleye, Pikeminnow, Bass, Birds",         "pikeminnow",
  "McNary Dam",                                                   45.93424543934512, -119.2968462198834, 800,       "Dam + Predators",                          "dam_mcnary",
  "Lake Umatilla",                                                45.84723210032379, -119.7431484965494, 2500,      "Walleye, Pikeminnow, Bass, Birds",         "pikeminnow",
  "John Day Dam",                                                 45.71548186541551, -120.6931719475177, 800,       "Dam + Predators",                          "dam_john_day",
  "The Dalles Dam",                                               45.61415879901354, -121.1347482584566, 800,       "Dam + Predators",                          "dam_thedalles",
  "Bonneville Dam",                                               45.64319667992435, -121.9408025639001, 800,       "Dam + Sea Lions",                          "dam_bonneville",
  "Lake Bonneville",                                              45.72052410874779, -121.5253449781077, 2000,      "Birds, Pikeminnow, Bass",                  "predator_bass",
  "Lake Celilo",                                                  45.65605440772831, -120.942064342562,  2000,      "Pikeminnow, Bass",                         "pikeminnow",
  "Bonneville to Estuary",                                        45.61908252139683, -121.9928877449413, 1500,      "Sea Lions, Birds",                         "sealion",
  "Crescent Island",                                              46.09336797360658, -118.9309612004424, 1000,      "Terns, Cormorants, Gulls, Pelicans",       "avian_cormorant",
  "Blalock Islands",                                              45.9124591704281,  -119.624536079019,  1000,      "Tern colonies",                            "avian_tern",
  "Miller Rocks Islands",                                         45.65439370874824, -120.8967928548145, 1000,      "Gull colonies",                            "avian_cormorant"
)