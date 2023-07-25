
# Header ------------------------------------------------------------------

rm(list = ls())

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate, 
  fixest, 
  plm
)

source("./project/code/07_data_merge.R")




# Data Wrangling ----------------------------------------------------------

data_temp <- temp_mort_prices %>% 
  filter(nuts_level == 3) %>%
  mutate(age_adjusted_mortality = age_adjusted_mortality*100000) %>%
  mutate(period = paste(year, month, week, sep = "-")) %>%
  group_by(nuts_code, period) 


# Regression --------------------------------------------------------------

feols(age_adjusted_mortality ~ temperature + temperature^2 + gas_ppi* temperature | nuts_code + period, data_temp)

feols(age_adjusted_mortality ~ log(gas_ppi) + temperature + temperature^2| nuts_code + period, panel.id = c("nuts_code", "period"), data_temp %>% filter(!between(dates, as.Date("2020-02-01"), as.Date("2022-03-01"))))

filter(!(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-31")))

df <- pdata.frame(data_temp,index=c("nuts_code","period"))  
df <- transform(data_temp, l_value=lag(gas_ppi,1))   
