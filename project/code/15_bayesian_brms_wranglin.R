
# Header ------------------------------------------------------------------

pacman::p_load(
  tidyverse,
  brms, 
  plm, 
  rstanarm
)

source("./project/code/07_data_merge.R")


# Data Wrangling ----------------------------------------------------------

temp_mort_prices$dates <- as.Date(temp_mort_prices$dates)

full_data <- temp_mort_prices %>%
  filter(!is.na(gas_ppi)) %>%
  filter(!is.na(temperature)) %>%
  filter(!is.na(age_adjusted_mortality))

# combine filter conditions and avoid converting date to factor
data_temp <- full_data %>% 
  filter(nuts_level == 3) %>%  
  group_by(nuts_code, year, month, week)  %>% 
  mutate(date = paste(year, month, week, sep = "-")) 

# Generate corresponding row numbers
row_numbers <- 1:length(c(unique(data_temp$date)))

# Create crosswalk for numbering
df <- data.frame("date" = c(unique(data_temp$date)), "row_number" = row_numbers)

data_temp_1 <- data_temp %>%
  left_join(df) %>% 
  filter(!(dates >= as.Date("2020-03-01") & dates <= as.Date("2022-03-05"))) %>%
  select(!dates)

breaks <- c(-Inf, 0, 5, 10, 15, 20, 25, 30, Inf)
labels <- c("<0", "0-5", "5-10", "10-15", "15-20", "20-25", "25-30", ">30")

data_temp_2 <- data_temp_1 %>% 
  mutate(temp_bin = cut(temperature, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE))

pdata <- pdata.frame(data_temp_2, index = c("nuts_code","date"))

pdata$lag_gas <- lag(pdata$gas_ppi, 8)

pdata$lag_elect <- lag(pdata$elect_ppi, 8)

pdata$temp_bin <- relevel(pdata$temp_bin, ref = "10-15")

pdata <- pdata %>% mutate(winter = as.integer(case_when(
  month %in% c(11, 12, 1, 2, 3) ~ "1", 
  month %in% c(4, 5, 6, 7, 8, 9, 10) ~ "0")))

dfpdata <- as.data.frame(pdata)

dfpdata_nuts <- dfpdata %>% 
  filter(!is.na(lag_gas)) %>%
  mutate(country = as.factor(substr(nuts_code, 1, 2))) %>%
  mutate(nuts_1 = as.factor(substr(nuts_code, 1, 3))) %>%
  mutate(nuts_2 = as.factor(substr(nuts_code, 1, 4))) %>%
  mutate(nuts_3 = as.factor(substr(nuts_code, 1, 5))) 

