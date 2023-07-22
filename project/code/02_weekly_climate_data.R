
# Load Packages, Specify Local File Paths (Because Data is Big) -----------

rm(list = ls())

pacman::p_load(
  tidyverse,
  lubridate,
  readr,
  countrycode
)

# Path for Climate Data CSV
in_path <- "..."



# Read in CSV -------------------------------------------------------------

climate <- read_csv(in_path)



# Climate Data by Country -------------------------------------------------

# climate_weekly <- climate %>%
#   filter(LEVL_CODE == 0) %>%
#   select(CNTR_CODE, climate_variable, date, value) %>%
#   rename(ccode = CNTR_CODE) %>%
#   mutate(cname = countrycode(ccode, "eurostat", "country.name"),
#          week = isoweek(ymd(date)),
#          year = isoyear(ymd(date))) %>%
#   group_by(ccode, cname, climate_variable, week, year) %>%
#   summarize(value = mean(value)) %>%
#   ungroup() %>%
#   arrange(ccode, climate_variable, year, week)
# 
# 
# write_csv(climate_weekly, "./project/data/climate_weekly_by_country.csv")


# Climate Data by NUTS Regions --------------------------------------------

climate_weekly_nuts <- climate %>%
  select(NUTS_ID, LEVL_CODE, NUTS_NAME, climate_variable, date, value) %>%
  rename(nuts_code = NUTS_ID,
         nuts_name = NUTS_NAME,
         nuts_level = LEVL_CODE) %>%
  mutate(week = isoweek(ymd(date)),
         year = isoyear(ymd(date))) %>%
  group_by(nuts_code, nuts_name, nuts_level, climate_variable, week, year) %>%
  summarize(value = mean(value)) %>%
  ungroup() %>%
  arrange(nuts_code, nuts_name, nuts_level, climate_variable, year, week)

humidity_weekly <- climate_weekly_nuts %>%
  filter(climate_variable == "hum") %>%
  select(-climate_variable) %>%
  rename(humidity = value)

temperature_weekly <- climate_weekly_nuts %>%
  filter(climate_variable == "tmp") %>%
  select(-climate_variable) %>%
  rename(temperature = value)


write_csv(humidity_weekly, "./project/data/humidity_weekly.csv")

write_csv(temperature_weekly, "./project/data/temperature_weekly.csv")

