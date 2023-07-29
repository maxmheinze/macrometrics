

# Header ------------------------------------------------------------------

rm(list = ls())

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate, 
  brms, 
  plm, 
  nlme, 
  lme4, 
  lmerTest 
)

source("./project/code/07_data_merge.R")

# reading in data ---------------------------------------------------------


#### FASTER IMPLEMENTATION

temp_mort_prices$dates <- as.Date(temp_mort_prices$dates)

# combine filter conditions and avoid converting date to factor
data_temp <- temp_mort_prices %>% 
  filter(!(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-05"))) %>%
  mutate(age_adjusted_mortality = age_adjusted_mortality*100000) %>%
  group_by(nuts_code, year, month, week)  %>% 
  mutate(date = paste(year, month, week, sep = "-"))

breaks <- c(-Inf, 0, 5, 10, 15, 20, 25, 30, Inf)
labels <- c("<0", "0-5", "5-10", "10-15", "15-20", "20-25", "25-30", ">30")

data_temp <- data_temp %>% 
  mutate(temp_bin = cut(temperature, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE))

#### 

#data_temp <- data_temp %>% 
#  mutate(temp_bin = case_when(
#      temperature < 0 ~ "<0",
#      temperature >= 0 & temperature < 5 ~ "0-5",
#      temperature >= 5 & temperature < 10 ~ "5-10",
#      temperature >= 10 & temperature < 15 ~ "10-15",
#      temperature >= 15 & temperature < 20 ~ "15-20",
#      temperature >= 20 & temperature < 25 ~ "20-25",
#      temperature >= 25 & temperature < 30 ~ "25-30",
#      temperature >= 30 ~ ">30")) 

pdata <- pdata.frame(data_temp, index = c("nuts_code","date"))

pdata$lag_pcap <- lag(pdata$gas_ppi, 8)

pdata$lag_pecep <- lag(pdata$elect_ppi, 8)

#pdata <- pdata %>% 
#  mutate(temp_bin = as_factor(pdata$temp_bin))

pdata <- na.omit(pdata, cols = "temp_bin")

pdata$temp_bin <- relevel(pdata$temp_bin, ref = "10-15")

pdata <- tibble(pdata)




# Fit the model
fit <- brm(
  age_adjusted_mortality ~ temp_bin + lag_pcap + (1 | nuts_code) + (1 | nuts_level) + (1 | date), 
  data = pdata, 
  family = gaussian()
)

intercept.only <- lme(age_adjusted_mortality ~ temp_bin + log(lag_pcap) | nuts_code, 
                      pdata, method = "ML")
summary(intercept.only)

fit <- lmer(age_adjusted_mortality ~ temp_bin + lag_pcap + date + (1 | nuts_code) + (1 | nuts_level), data = pdata)

# Fit the model
fit <- lmer(age_adjusted_mortality ~ nuts_code + date + (1 | nuts_code), data = pdata)

+ lag_pcap + date + nuts_level + (1 | nuts_code)
# Print the model summary
summary(fit)


model <- brm(
  formula = age_adjusted_mortality ~ temp_bin + lag_pcap + (1|nuts_code),
  data = pdata,
  family = gaussian(),
  iter = 2000, # number of iterations
  chains = 4 # number of Markov chains
)
summary(model)

model <- lmer(age_adjusted_mortality ~ nuts_code + (1|nuts_level), data = pdata)

summary(model)
