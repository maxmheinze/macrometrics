
# Header ------------------------------------------------------------------

pacman::p_load(
  tidyverse,
  brms
)

source("./project/code/07_data_merge.R")


# Load Data, Subset Columns -----------------------------------------------

full_data <- temp_mort_prices %>%
  filter(!is.na(gas_ppi)) %>%
  filter(!is.na(temperature)) %>%
  filter(!is.na(age_adjusted_mortality))


# Fit Model ---------------------------------------------------------------


# Fit the model
model <- brm(
  formula = age_adjusted_mortality ~ gas_ppi * temperature + (1 | nuts_code),
  data = full_data,
  family = gaussian(),
  iter = 2000, 
  chains = 4
)

# Check the summary of the model
summary(model)



# From Chat GPT, needs check ----------------------------------------------


# Fit the model
model <- brm(
  formula = age_adjusted_mortality ~ gas_ppi * temperature * year + (1 | nuts_code),
  data = your_dataframe, # replace with your actual dataframe name
  family = gaussian(), # adjust if needed; gaussian is for continuous outcomes
  iter = 2000, 
  chains = 4
)

# Check the summary of the model
summary(model)





your_dataframe$nuts0 <- substr(your_dataframe$nuts_code, 1, 2)
your_dataframe$nuts1 <- substr(your_dataframe$nuts_code, 1, 3)
your_dataframe$nuts2 <- substr(your_dataframe$nuts_code, 1, 4)
your_dataframe$nuts3 <- your_dataframe$nuts_code





# Fit the model
model <- brm(
  formula = age_adjusted_mortality ~ gas_ppi * temperature * year + (1 | nuts0/nuts1/nuts2/nuts3),
  data = your_dataframe, 
  family = gaussian(), 
  iter = 2000, 
  chains = 4
)

# Check the summary of the model
summary(model)



# Gugus Input -------------------------------------------------------------


# DATA WRANGLING ----------------------------------------------------------

#just let it run through

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

# Trying out some mixed models --------------------------------------------


#lmer uses the same syntax as brms 

model_lmer <- lmer(age_adjusted_mortality ~ log(lag_gas) * temp_bin + (1|country/nuts_1/nuts_2/nuts_3) + (1|date), data = dfpdata_nuts)
summary(model_lmer)







