

# Header ------------------------------------------------------------------

rm(list = ls())

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate
)



# Read Data ---------------------------------------------------------------

age_adjusted_weekly_mortality <- read_csv("./project/data/age_adjusted_weekly_mortality.csv")

prices <- read_csv("./project/data/prices.csv")

temperature <- read_csv("./project/data/temperature_weekly.csv")

# Data Merge --------------------------------------------------------------

prices %>% 
