

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

temp_mort <- temperature %>%
  left_join(age_adjusted_weekly_mortality, by = c("nuts_code", "nuts_level", "week", "year"))

prices_1 <- prices %>%
  mutate(country = countrycode(prices$country_clean, "country.name", "eurostat"))

temp_mort_prices <- temp_mort %>% 
  mutate(country = substr(nuts_code, 1, 2)) 
  #mutate(month = format(as.Date(paste(1, week, year), "%u %U %Y"), "%B"))
  #left_join(prices_1, by = c("country", "year", "month"))

temp_mort_prices %>%
  mutate(
    x = as.POSIXct(strptime(paste0(x, "-1"), format = "%Y-%W-%u")),
    month = format(x, "%m"),
    week = 1 + as.integer(format(, "%d")) %/% 7)

# Replace NA values in the Date column with a specified date
replacement_date <- as.Date("2020-12-31")
euromomo_score$Date[is.na(euromomo_score$Date)] <- replacement_date
  
# Add month column
euromomo_score$month <- month(euromomo_score$Date)
  
  