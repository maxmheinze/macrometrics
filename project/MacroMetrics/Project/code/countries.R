pacman::p_load("tidyverse", "lubridate")


#reading ion country mortality (attention with the semicolon) and then 
country_mortality
view(country_mortality)


country_mortality <- read_delim("Project/raw/demo_r_mwk3_t__custom_6877865_linear.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE)

country_mortality_edited <- country_mortality %>%
  mutate(year = substr(TIME_PERIOD, 1, 4)) %>% #editing the time format
  mutate(week = substr(TIME_PERIOD, 7, 8)) %>% #editing the time format by adding new column
  mutate(year = as.numeric(year)) %>%
  mutate(week = as.numeric(week)) %>% 
  select(!TIME_PERIOD) %>% #Leaving one column out
  rename("deaths" = "OBS_VALUE") # renaming OBS_VALUE to deaths
  

