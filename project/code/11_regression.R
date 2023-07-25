
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
  filter(nuts_level == 1) %>%
  mutate(age_adjusted_mortality = age_adjusted_mortality*100000) %>%
  group_by(nuts_code, year, month, week)  %>% 
  mutate(date = as.factor(paste(year, month, week, sep = "-")))  %>% 
  filter(!(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-31"))) 


# Regression --------------------------------------------------------------

feols(age_adjusted_mortality ~ log(gas_ppi) + temperature +  temperature^2| nuts_code + dates, data_temp)

feols(age_adjusted_mortality ~ log(gas_ppi) + temperature + temperature^2 + temperature*log(gas_ppi)| nuts_code + period, data_temp)

reg = lm(age_adjusted_mortality ~ date + nuts_code + gas_ppi, data_temp)

reg_1 = plm(age_adjusted_mortality ~  temperature + I(temperature^2) + I(log(gas_ppi)*temperature) + log(gas_ppi), 
          index = c("nuts_code", "date"),
          effect = "twoways",
          data = data_temp)

summary(reg_1)


reg_2 = plm(age_adjusted_mortality ~  temperature + I(temperature^2) + I(lag(log(gas_ppi),8L)*temperature) + lag(log(gas_ppi),8L), 
            index = c("nuts_code", "date"),
            effect = "twoways",
            data = data_temp)

summary(reg_2)


reg_3 = plm(age_adjusted_mortality ~  I(lag(log(gas_ppi),8L)^temperature), 
            index = c("nuts_code", "date"),
            effect = "twoways",
            data = data_temp)

summary(reg_3)

