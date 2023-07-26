
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
  filter(nuts_level == 2) %>%
  mutate(age_adjusted_mortality = age_adjusted_mortality*100000) %>%
  group_by(nuts_code, year, month, week)  %>% 
  mutate(date = as.factor(paste(year, month, week, sep = "-")))  %>% 
  mutate(temperature = temperature + 273.15) %>%
  filter(!(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-31"))) 


# Regression --------------------------------------------------------------



# Effect of temperature on mortality --------------------------------------

reg <-feols(age_adjusted_mortality ~ temperature +  temperature^2 | nuts_code + date, data_temp)

lowest_mortality = (-coef(reg)["temperature"] / (2*coef(reg)["I(temperature^2)"])) - 273.15

feols(age_adjusted_mortality ~ temperature +  temperature^2 + temperature^3 | nuts_code + date, data_temp)



feols(age_adjusted_mortality ~ log(gas_ppi) + temperature + I(temperature^2) + log(gas_ppi):temperature + log(gas_ppi):I(temperature^2) | nuts_code + date, data_temp)


feols(age_adjusted_mortality ~ l(log(gas_ppi),8) | nuts_code + date, data_temp %>% filter(month %in% c("11", "12", "1", "2")))


feols(age_adjusted_mortality ~ log(gas_ppi) + temperature + temperature^2 + temperature*log(gas_ppi)| nuts_code + year + month  + week, data_temp)

reg = lm(age_adjusted_mortality ~ date + nuts_code + gas_ppi, data_temp)




# lagged regression with plm ----------------------------------------------

pdata <- pdata.frame(data_temp, index = c("nuts_code","date"))

pdata$lag_pcap <- lag(pdata$gas_ppi, 8)


reg_2 = plm(age_adjusted_mortality ~ lag_pcap, 
            effect = "twoways",
            data = pdata)

summary(reg_2)


reg_3 = plm(age_adjusted_mortality ~ (lag_pcap), 
            effect = "twoways",
            data = pdata %>% filter(month %in% c(11, 12, 1, 2)))

summary(reg_3)



reg_4 = plm(age_adjusted_mortality ~ log(gas_ppi) + temperature + I(temperature^2) + log(gas_ppi):temperature + log(gas_ppi):I(temperature^2), 
            effect = "twoways",
            data = pdata)

summary(reg_4)




reg_4 = plm(age_adjusted_mortality ~ log(elec_ppi) + temperature + I(temperature^2) + log(gas_ppi):temperature + log(gas_ppi):I(temperature^2), 
            effect = "twoways",
            data = pdata)

summary(reg_4)



