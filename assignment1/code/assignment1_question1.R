
# Header ------------------------------------------------------------------

rm(list = ls())
gc()

pacman::p_load(
  tidyverse,
  urca
  )


# Read in Data ------------------------------------------------------------

fred <- read.csv("./assignment1/data/fred.csv")[-1,]


# Create the function -----------------------------------------------------

ts_explode <- function(input_vector, start_with_latest = FALSE) {
  # The function is called ts_explode because a single vector explodes into an entire data frame. Boom!
  
  # Package dplyr required for lag() function
  require(dplyr)
  
  # Reverse input vector if user specifies it is sorted latest to earliest
  input_vector <- if (start_with_latest == FALSE) {
    input_vector
  } else {
    rev(input_vector)
  } 
  
  # Do the transformations, assign transformed vectors
  original <- input_vector
  log_transformed <- log(input_vector)
  mom_growth <- input_vector/dplyr::lag(input_vector, 1) - 1
  yoy_growth <- input_vector/dplyr::lag(input_vector, 12) - 1
  yoy_growth_lagged <- dplyr::lag(input_vector, 12)/dplyr::lag(input_vector, 24) - 1
  
  # Create a data frame to export, reverse ordering back to original in case start_with_latest = TRUE was specified
  export_df <- if (start_with_latest == FALSE) {
    data.frame(original, log_transformed, mom_growth, yoy_growth, yoy_growth_lagged)
  } else {
    data.frame(original = rev(original), 
               log_transformed = rev(log_transformed), 
               mom_growth = rev(mom_growth), 
               yoy_growth = rev(yoy_growth), 
               yoy_growth_lagged = rev(yoy_growth_lagged))
  }
  
  # Display warnings regarding ordering and units of growth rates
  warning("By default, ts_explode() assumes that values are ordered from earliest to latest. If your vector is ordered from latest to earliest, specify `start_with_latest = TRUE`!")
  warning("Growth rates are given in decimals, not in percent!")
  
  # Return the data frame
  return(export_df)
}



# Prepare Industrial Production Data Frame --------------------------------

ind_prod <- fred$sasdate %>%
  cbind(ts_explode(fred$INDPRO)) %>%
  as_tibble() %>%
  mutate(date = lubridate::mdy(`.`)) %>%
  select(-`.`) %>%
  relocate(date, .before = original)


# Create Log Plot ---------------------------------------------------------

ind_prod %>%
  ggplot() +
  geom_line(aes(x = date, y = log_transformed)) +
  labs(title = "U.S. Industrial Production (logged)",
       x = "Date",
       y = "Log of Industrial Production") +
  ylim(3,5) +
  theme_bw()

ggsave("./assignment1/output/plot_logged.png", plot = last_plot(), width = 6, height = 4)


# Create Growth Plot ------------------------------------------------------

ind_prod %>%
  ggplot() +
  geom_line(aes(x = date, y = yoy_growth)) +
  labs(title = "U.S. Industrial Production (year-on-year growth)",
       x = "Date",
       y = "Year-on-Year Growth of Industrial Production") +
  theme_bw()

ggsave("./assignment1/output/plot_yoy.png", plot = last_plot(), width = 6, height = 4)


# Assess Properties of Logged Industrial Production and its Year Growth Rate --

# ACF plot and ADF test(s) of Logged Industrial Production

stats::acf(ind_prod$log_transformed[!is.na(ind_prod$log_transformed)], main = "ACF of Logged Industrial Production")

urtest1a = ur.df(ind_prod$log_transformed[!is.na(ind_prod$log_transformed)], type = "trend", selectlags = "AIC")
summary(urtest1a)

urtest2a = ur.df(ind_prod$log_transformed[!is.na(ind_prod$log_transformed)], type = "drift", selectlags = "AIC")
summary(urtest2a)

# ACF plot and ADF test(s) of Year-on-Year Growth Rate


stats::acf(ind_prod$yoy_growth[!is.na(ind_prod$yoy_growth)], main = "ACF of YoY Growth of Industrial Production")

urtest1b = ur.df(ind_prod$yoy_growth[!is.na(ind_prod$yoy_growth)], type = "trend", selectlags = "AIC")
summary(urtest1b)

urtest2b = ur.df(ind_prod$yoy_growth[!is.na(ind_prod$yoy_growth)], type = "drift", selectlags = "AIC")
summary(urtest2b)



# Estimate AR model -------------------------------------------------------


ar.ols(ind_prod$log_transformed[!is.na(ind_prod$log_transformed)])


# Function for the Dickey-Fuller test: urca::ur.df()

