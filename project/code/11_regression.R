
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
  lmtest, 
  sandwich, 
  stargazer
)

source("./project/code/07_data_merge.R")




# Data Wrangling ----------------------------------------------------------

#data_temp <- temp_mort_prices %>% 
#  filter(nuts_level == 3) %>%
#  mutate(age_adjusted_mortality = age_adjusted_mortality*100000) %>%
#  group_by(nuts_code, year, month, week)  %>% 
#  mutate(date = as.factor(paste(year, month, week, sep = "-")))  %>% 
  #mutate(temperature = temperature + 273.15) %>%
#  filter(!(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-05"))) 

#### FASTER IMPLEMENTATION

temp_mort_prices$dates <- as.Date(temp_mort_prices$dates)

# combine filter conditions and avoid converting date to factor
data_temp <- temp_mort_prices %>% 
  filter(nuts_level == 3  & 
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

pdata$lag_gas <- lag(pdata$gas_ppi, 8)

pdata$lag_elect <- lag(pdata$elect_ppi, 8)

pdata$temp_bin <- relevel(pdata$temp_bin, ref = "10-15")

pdata <- pdata %>% mutate(winter = as.integer(case_when(
  month %in% c(11, 12, 1, 2, 3) ~ "1", 
  month %in% c(4, 5, 6, 7, 8, 9, 10) ~ "0")))

# regression analysis --------------------------------------------------------------


# TABLE 1 -----------------------------------------------------------------

reg_1 = plm(age_adjusted_mortality ~ log(lag_elect), 
            effect = "twoways",    
            model = "within",
            data = pdata)

summary(reg_1)


reg_2 = plm(age_adjusted_mortality ~ log(lag_gas), 
            effect = "twoways",    
            model = "within",
            data = pdata)

summary(reg_2)

reg_3 = plm(age_adjusted_mortality ~ log(lag_elect) + winter* log(lag_elect), 
            effect = "twoways",
            model = "within",
            data = pdata)

summary(reg_3)

reg_4 = plm(age_adjusted_mortality ~ log(lag_gas) + winter*log(lag_gas), 
            effect = "twoways",
            model = "within",
            data = pdata)

summary(reg_4)

stargazer(reg_1, reg_2, reg_3, reg_4, 
          se=list(coeftest(reg_1, vcovHC(reg_1,type="HC0",cluster="group"))[,"Std. Error"],
                  coeftest(reg_2, vcovHC(reg_2,type="HC0",cluster="group"))[,"Std. Error"],
                  coeftest(reg_3, vcovHC(reg_3,type="HC0",cluster="group"))[,"Std. Error"],
                  coeftest(reg_4, vcovHC(reg_4,type="HC0",cluster="group"))[,"Std. Error"]))



# TABLE 1 END -------------------------------------------------------------



# TABLE 2 -----------------------------------------------------------------


# TABLE 2 END -------------------------------------------------------------


# temperature -------------------------------------------------------------

reg_3 = plm(age_adjusted_mortality ~ temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")
summary(reg_3, vcov=vcovHC(reg_3,type="HC0",cluster="group"))

reg_4 = plm(age_adjusted_mortality ~ temp_bin + log(lag_gas) + log(lag_gas):temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")
summary(reg_4, vcov=vcovHC(reg_4,type="HC0",cluster="group"))

lmtest::coeftest(reg_4, vcov=vcovHC(reg_4,type="HC0",cluster="group"))

reg_5 = plm(age_adjusted_mortality ~ temp_bin + log(lag_elect) + log(lag_elect):temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")
summary(reg_5, vcov=vcovHC(reg_5,type="HC0",cluster="group"))

lmtest::coeftest(reg_5, vcov=vcovHC(reg_5,type="HC0",cluster="group"))


stargazer(reg_3, reg_4, reg_5, 
          se=list(coeftest(reg_3, vcovHC(reg_3,type="HC0",cluster="group"))[,"Std. Error"],
                  coeftest(reg_4, vcovHC(reg_4,type="HC0",cluster="group"))[,"Std. Error"],
                  coeftest(reg_5, vcovHC(reg_5,type="HC0",cluster="group"))[,"Std. Error"]))




reg_5 = plm(age_adjusted_mortality ~ temp_bin + log(lag_elect) + log(lag_elect):temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")
summary(reg_5)

lmtest::coeftest(reg_5, vcov=vcovHC(reg_5,type="HC0",cluster="group"))

reg_5 = plm(age_adjusted_mortality ~ log(lag_gas) + temperature + I(temperature^2) + log(lag_gas):temperature + log(lag_gas):I(temperature^2), 
            effect = "twoways",
            model = "within",
            data = pdata %>% mutate(temperature = temperature + 273.15))

summary(reg_5)

reg_6 = plm(age_adjusted_mortality ~ log(lag_elect) + temperature + I(temperature^2) + log(lag_elect):temperature + log(lag_elect):I(temperature^2), 
            effect = "twoways",
            model = "within",
            data = pdata %>% mutate(temperature = temperature + 273.15))

summary(reg_6, clutster = "nuts_code")





# Garbage -----------------------------------------------------------------



reg <- feols(age_adjusted_mortality ~ temperature +  temperature^2 | nuts_code + date, data_temp)

lowest_mortality = (-coef(reg)["temperature"] / (2*coef(reg)["I(temperature^2)"])) #- 273.15

feols(age_adjusted_mortality ~ temperature +  temperature^2 + temperature^3 | nuts_code + date, data_temp)



feols(age_adjusted_mortality ~ log(gas_ppi) + temperature + I(temperature^2) + log(gas_ppi):temperature + log(gas_ppi):I(temperature^2) | nuts_code + date, data_temp)


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


plot(260:300, -1.5166e+02 + -4.5153e+00 * (260:300) + 7.8668e-03 * I((260:300))^2 + 1.0503e+00 * (260:300) + (-1.8161e-03 * (I((260:300))^2)))


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


reg_9 = plm((age_adjusted_mortality) ~ temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")

summary(reg_9)


reg_9 = plm((age_adjusted_mortality) ~ temp_bin + log(lag_pcap) + log(lag_pcap):temp_bin, 
            data = pdata, 
            model = "within", 
            effect = "twoways")

summary(reg_9)

reg_10 = plm((age_adjusted_mortality) ~ temp_bin + (lag_pcap) + (lag_pcap):temp_bin, 
             data = pdata, 
             model = "within", 
             effect = "twoways")

summary(reg_10)


reg_12 = plm((age_adjusted_mortality) ~ temp_bin + log(lag_pcap/lag_pecep)*temp_bin, 
             data = pdata, 
             model = "within", 
             effect = "twoways")
summary(reg_12)


# Trying out some mixed models --------------------------------------------

dfpdata <- as.data.frame(pdata)

dfpdata_nuts <- dfpdata %>% 
  mutate(country = as.factor(substr(nuts_code, 1, 2))) %>%
  mutate(nuts_1 = as.factor(substr(nuts_code, 1, 3))) %>%
  mutate(nuts_2 = as.factor(substr(nuts_code, 1, 4))) %>%
  mutate(nuts_3 = as.factor(substr(nuts_code, 1, 5))) %>%
  
model_lmer <- lmer(age_adjusted_mortality ~ log(lag_gas) * temp_bin + (1|country/nuts_1/nuts_2/nuts_3) + (1|date), data = dfpdata)
summary(model_lmer)

