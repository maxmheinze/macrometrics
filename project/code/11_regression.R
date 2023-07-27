
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
  #mutate(temperature = temperature + 273.15) %>%
  filter(!(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-31"))) 

data_temp <- data_temp %>% 
  mutate(temp_bin = case_when(
      temperature < 0 ~ "<0",
      temperature >= 0 & temperature < 5 ~ "0-5",
      temperature >= 5 & temperature < 10 ~ "5-10",
      temperature >= 10 & temperature < 15 ~ "10-15",
      temperature >= 15 & temperature < 20 ~ "15-20",
      temperature >= 20 & temperature < 25 ~ "20-25",
      temperature >= 25 & temperature < 30 ~ "25-30",
      temperature >= 30 ~ ">30")) 

pdata <- pdata.frame(data_temp, index = c("nuts_code","date"))

pdata$lag_pcap <- lag(pdata$gas_ppi, 8)

pdata <- pdata %>% 
  mutate(temp_bin = as_factor(pdata$temp_bin))

pdata <- na.omit(pdata, cols = "temp_bin")

pdata$temp_bin <- relevel(pdata$temp_bin, ref = "15-20")


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





reg_2 = plm(age_adjusted_mortality ~ log(lag_pcap), 
            effect = "twoways",
            model = "within",
            data = pdata)

summary(reg_2)


reg_3 = plm(age_adjusted_mortality ~ log(lag_pcap), 
            effect = "twoways",    
            model = "within",
            data = pdata %>% filter(month %in% c(10, 11, 12, 1, 2, 3)))

summary(reg_3)




reg_4 = plm(age_adjusted_mortality ~ log(lag_pcap) + temperature + I(temperature^2) + log(lag_pcap):temperature + log(lag_pcap):I(temperature^2), 
            effect = "twoways",
            model = "within",
            data = pdata)

summary(reg_4)


reg_5 = plm(age_adjusted_mortality ~ log(elect_ppi) + temperature + I(temperature^2) + log(elect_ppi):temperature + log(elect_ppi):I(temperature^2), 
            effect = "twoways",
            model = "within",
            data = pdata)

summary(reg_5)


reg_6 = plm(age_adjusted_mortality ~ log(elect_ppi) + temperature + I(temperature^2) + log(elect_ppi):temperature + log(elect_ppi):I(temperature^2), 
            effect = "twoways",
            data = pdata)

summary(reg_6)


plot(260:300, -1.5166e+02 + -4.5153e+00 * (260:300) + 7.8668e-03 * I((260:300)^2) + 1.0503e+00 * (260:300) + (-1.8161e-03 * (I((260:300))^2)))


reg_7 = plm(age_adjusted_mortality ~  log(lag_pcap) + temperature + log(lag_pcap):temperature, 
            effect = "twoways",
            model = "within",
            data = pdata %>% filter(month %in% c(11, 12, 1, 2)))

summary(reg_7)



reg_8 = plm(age_adjusted_mortality ~  log(lag_pcap) + temp_bin + log(lag_pcap):temp_bin, 
            effect = "twoways",
            model = "within",
            data = pdata)

summary(reg_8)


reg_9 = plm(log(age_adjusted_mortality) ~ temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")

summary(reg_9)


reg_9 = plm((age_adjusted_mortality) ~ temp_bin + log(gas_ppi) + log(gas_ppi):temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")

summary(reg_9)

reg_10 = plm(age_adjusted_mortality ~ temp_bin + log(lag_pcap) + log(lag_pcap):temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")

summary(reg_10)



