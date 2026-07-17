
tags <- data.table::fread("../Downloads/Complete Tag History.csv")

tags <- tags %>%
  janitor::clean_names()

nrow(tags)

tags <-  tags %>%
mutate(date=date(mdy_hms(obs_date_time_value))) %>%
  distinct(tag_code,date, .keep_all = TRUE)

nrow(tags)

tags %>% 
  filter(is.na(date)) %>%
  nrow()

# If that returns fish with both outbound AND 
# return detections, we have a real complete life cycle in the data. Those fish ARE your win condition.

two_way <- tags |>
  mutate(month = month(date),
         direction = ifelse(month %in% 3:7, "outbound", "return")) |>
  group_by(tag_code) |>
  summarise(has_outbound = any(direction == "outbound"),
            has_return   = any(direction == "return")) |>
  filter(has_outbound & has_return)
