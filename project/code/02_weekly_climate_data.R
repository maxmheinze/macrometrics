
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


# Data Wrangling ----------------------------------------------------------

climate_weekly <- climate %>%
  filter(LEVL_CODE == 0) %>%
  select(CNTR_CODE, climate_variable, date, value) %>%
  rename(ccode = CNTR_CODE) %>%
  mutate(cname = countrycode(ccode, "eurostat", "country.name"),
         week = isoweek(ymd(date)),
         year = isoyear(ymd(date))) %>%
  group_by(ccode, cname, climate_variable, week, year) %>%
  summarize(value = mean(value)) %>%
  ungroup() %>%
  arrange(ccode, climate_variable, year, week)


# Write CSV ---------------------------------------------------------------

write_csv(climate_weekly, "./project/data/climate_weekly.csv")

