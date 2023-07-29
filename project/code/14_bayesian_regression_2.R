
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










