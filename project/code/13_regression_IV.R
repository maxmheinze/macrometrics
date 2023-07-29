
# Header ------------------------------------------------------------------

rm(list = ls())

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate, 
  fixest, 
  plm, 
  nlme, 
  lme4, 
  zoo, 
  broom)

source("./project/code/07_data_merge.R")


ec_shares_hh <- read_csv("./project/data/ec_shares_hh.csv")


# Data Wrangling ----------------------------------------------------------

temp_mort_prices$dates <- as.Date(temp_mort_prices$dates)

# combine filter conditions and avoid converting date to factor
data_temp <- temp_mort_prices %>% 
  filter(nuts_level == 0  & 
           !(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-05"))) %>%
  mutate(age_adjusted_mortality = age_adjusted_mortality*100000) %>%
  group_by(nuts_code, year, month, week)  %>% 
  mutate(date = paste(year, month, week, sep = "-")) %>%
  select(!dates)

breaks <- c(-Inf, 0, 5, 10, 15, 20, 25, 30, Inf)
labels <- c("<0", "0-5", "5-10", "10-15", "15-20", "20-25", "25-30", ">30")

data_temp <- data_temp %>% 
  mutate(temp_bin = cut(temperature, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE))

pdata <- pdata.frame(data_temp, index = c("nuts_code","date"))

pdata$lag_pcap <- lag(pdata$gas_ppi, 8)

pdata$lag_pecep <- lag(pdata$elect_ppi, 8)

pdata <- na.omit(pdata, cols = "temp_bin")

pdata$temp_bin <- relevel(pdata$temp_bin, ref = "10-15")



# linear interpolation for electricity share of ec ------------------------

ec_shares_hh_1 <- ec_shares_hh %>% 
  rename(nuts_code = ccode) %>% 
  filter(energy_carrier == "Natural gas") %>%
  select(nuts_code, shares, year) 

all_years <- 2017:2023

# Expand the data frame
df_full <- ec_shares_hh_1 %>%
  tidyr::complete(nuts_code, year = all_years) %>%
  group_by(nuts_code)

predictions <- round(predict(lm(shares ~ year *nuts_code, df_full), newdata = df_full), 2)
predictions 

df_full$shares[is.na(df_full$shares)] <- predictions[is.na(df_full$shares)]

df_full$shares <- pmax(df_full$shares, 0)

final <- pdata %>%
  left_join(df_full, by = c("nuts_code", "year")) 





# Shift Share Regression --------------------------------------------------


reg_1 = plm(age_adjusted_mortality ~ I(log(lag_pcap/lag_pecep)*shares), 
            data = final, 
            model = "within", 
            effect = "twoways")
summary(reg_1)

reg_2 = plm(age_adjusted_mortality ~ I(log(lag_pcap/lag_pecep)*shares), 
             data = (final %>% filter(month %in% c(11, 12, 1, 2, 3))), 
             model = "within", 
             effect = "twoways")
summary(reg_2)


reg_3 = plm(age_adjusted_mortality ~ I(log(lag_pcap/lag_pecep)*shares), 
            data = final, 
            model = "within", 
            effect = "twoways")
summary(reg_3)


