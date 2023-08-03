
# Header ------------------------------------------------------------------

pacman::p_load(
  tidyverse,
  brms, 
  plm, 
  rstanarm
)


# Data Wrangling ----------------------------------------------------------

{
source("./project/code/07_data_merge.R")

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

dfpdata <- as.data.frame(pdata)

dfpdata_nuts <- dfpdata %>% 
  mutate(country = as.factor(substr(nuts_code, 1, 2))) %>%
  mutate(nuts_1 = as.factor(substr(nuts_code, 1, 3))) %>%
  mutate(nuts_2 = as.factor(substr(nuts_code, 1, 4))) %>%
  mutate(nuts_3 = as.factor(substr(nuts_code, 1, 5))) 
}


# Reduced Dataset ---------------------------------------------------------

{
  source("./project/code/07_data_merge.R")
  
  temp_mort_prices$dates <- as.Date(temp_mort_prices$dates)
  
  # combine filter conditions and avoid converting date to factor
  data_temp <- temp_mort_prices %>% 
    filter(nuts_level == 2  & 
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
  
  dfpdata <- as.data.frame(pdata)
  
  dfpdata_nuts_2 <- dfpdata %>% 
    mutate(country = as.factor(substr(nuts_code, 1, 2))) %>%
    mutate(nuts_1 = as.factor(substr(nuts_code, 1, 3))) %>%
    mutate(nuts_2 = as.factor(substr(nuts_code, 1, 4)))


data_reduced <- dfpdata_nuts_2 %>%
  filter(!is.na(lag_gas),
         !is.na(temp_bin),
         !is.na(age_adjusted_mortality))
}


# Model 3 -----------------------------------------------------------------

model3 <- brm(
  age_adjusted_mortality ~ 
    1 + log(lag_gas) + temp_bin + log(lag_gas):temp_bin + 
    (1 + log(lag_gas) + temp_bin + log(lag_gas):temp_bin | country/nuts_1) +
    (1 + log(lag_gas) + temp_bin + log(lag_gas):temp_bin | year/month),  
  data = data_reduced, 
  warmup = 500, 
  iter = 1000,
  chains = 4,
  cores = 4,
  seed = 1234,
  prior = set_prior("normal(0,10)", class = "b"),
  refresh = 1
)

save(model3, file = "...") # Too large for GitHub



# Model 5 -----------------------------------------------------------------

model5 <- stan_glmer(
  age_adjusted_mortality ~ 
    1 + log(lag_gas) + temp_bin + log(lag_gas):temp_bin + 
    (1 + log(lag_gas) + temp_bin + log(lag_gas):temp_bin | country) +
    (1 | yearweek),  
  data = data_reduced,
  refresh = 1
)

# Model did not run in time


# rstanarm ----------------------------------------------------------------

stan_lm(age_adjusted_mortality ~ temp_bin*log(lag_gas) + nuts_code + date, 
        data = dfpdata_nuts)

model <- stan_lm(
  age_adjusted_mortality ~ temp_bin*log(lag_gas) + nuts_code + date, 
  data = dfpdata_nuts, 
  family = gaussian(), 
  chains = 2, 
  iter = 200,
  seed = 123
)

model <- stan_glmer(
  age_adjusted_mortality ~ log(lag_gas) + (1 | nuts_3/country),
  data = dfpdata_nuts, 
  family = gaussian(), 
  chains = 4, 
  iter = 100,
  seed = 123
)



