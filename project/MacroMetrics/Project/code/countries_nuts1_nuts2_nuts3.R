pacman::p_load("tidyverse", "lubridate")

#script to prepare countries_nuts1_nuts2_nuts3
countries_nuts1_nuts2_nuts3 <- read_delim("raw/countries_nuts1_nuts2_nuts3.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)

countries_nuts1_nuts2_nuts3_edited <- countries_nuts1_nuts2_nuts3 %>%
  mutate(year = substr(TIME_PERIOD, 1, 4)) %>% #editing the time format
  mutate(week = substr(TIME_PERIOD, 7, 8)) %>% #editing the time format by adding new column
  mutate(year = as.numeric(year)) %>%
  mutate(week = as.numeric(week)) %>% 
  select(!TIME_PERIOD) 

table(is.na(countries_nuts1_nuts2_nuts3_edited$deaths))
