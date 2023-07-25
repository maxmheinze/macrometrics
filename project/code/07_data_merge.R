

# Header ------------------------------------------------------------------

rm(list = ls())

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate, 
  tsibble
)



# Read Data ---------------------------------------------------------------

age_adjusted_weekly_mortality <- read_csv("./project/data/age_adjusted_weekly_mortality.csv")

prices <- read_csv("./project/data/prices.csv")

temperature <- read_csv("./project/data/temperature_weekly.csv")

# Data Merge --------------------------------------------------------------

temp_mort <- temperature %>%
  left_join(age_adjusted_weekly_mortality, by = c("nuts_code", "nuts_level", "week", "year"))

prices_1 <- prices %>%
  mutate(country = countrycode(prices$country_clean, "country.name", "eurostat"))

temp_mort_date <- temp_mort %>% 
  mutate(country = substr(nuts_code, 1, 2)) 

temp_mort_date$dates <- make_datetime(year = temp_mort_date$year) + weeks(temp_mort_date$week)

temp_mort_prices <- temp_mort_date %>% 
  mutate(month = month(dates)) %>%
  left_join(prices_1, by = c("country", "year", "month")) %>%
  select(!c(capital, country, country_code, country_clean)) %>%
  select(nuts_code, nuts_level, dates, year, month, week, temperature, age_adjusted_mortality, gas_ppi, elect_ppi)




