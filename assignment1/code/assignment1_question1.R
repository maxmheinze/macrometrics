
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

# Assessing time series properties --------------------------------------------

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


# Estimating AR model -------------------------------------------------------

ar_model_yoygrowth = ar.ols(ind_prod$yoy_growth[!is.na(ind_prod$yoy_growth)])
summary(ar_model_yoygrowth)

# Generate forecasts for the next year
forecasts <- predict(ar_model_yoygrowth, n.ahead = 12)
print(forecasts)

# Extract the forecasted values and the corresponding time period
forecasted_values <- as.vector(forecasts$pred)
time_period <- seq_along(forecasted_values) + length(ind_prod$yoy_growth)

# Plot the forecasts
plot(time_period, forecasted_values, type = "l", 
     main = "AR Model Forecasts", xlab = "Time", ylab = "Forecasts")

# Average YoY growth rate
mean(ind_prod$yoy_growth[!is.na(ind_prod$yoy_growth)])

# Forecast change in original time series based on forecasted year-on-year growth rate
last_observed_original <- tail(ind_prod$original, n = 1)
forecasted_change <- last_observed_original * forecasted_values

# Combine original time series with forecasted change
forecasted_original <- c(ind_prod$original, forecasted_change)

# Define time periods for forecasted changes
time_period_forecasted_change <- seq_along(forecasted_original)

# Plot forecasted changes
plot(time_period_forecasted_change, forecasted_original, type = "l", 
     xlab = "Time Period", ylab = "Forecasted Changes",
     main = "Forecasted Changes in Original Time Series")

# Bonus (AR Model of (Logged) Industrial Production-----------------------------

# Define function to calculate RMSE for AR model with given lag order
calculate_rmse <- function(lag_order, holdout_period, ind_prod) {
  
  # Exclude the holdout period from the end of the sample
  train_data <- ind_prod$log_transformed[1:(length(ind_prod$log_transformed) - holdout_period)]
  
  # Estimate AR model
  ar_model <- ar.ols(train_data, aic = FALSE, order.max = lag_order)
  
  # Produce forecasts for the holdout period
  forecasts <- predict(ar_model, n.ahead = holdout_period)
  
  # Extract predicted values for the holdout period
  predicted_values <- forecasts$pred
  
  # Extract realized values for the holdout period
  realized_values <- ind_prod$log_transformed[(length(ind_prod$log_transformed) - holdout_period + 1):length(ind_prod$log_transformed)]
  
  # Remove missing values from predicted_values and realized_values
  predicted_values <- na.omit(predicted_values)
  realized_values <- na.omit(realized_values)
  
  # Check and adjust length of predicted_values and realized_values
  if (length(predicted_values) > length(realized_values)) {
    predicted_values <- predicted_values[1:length(realized_values)]
  } else if (length(realized_values) > length(predicted_values)) {
    realized_values <- realized_values[1:length(predicted_values)]
  }
  
  # Compute RMSE
  rmse <- sqrt(mean((predicted_values - realized_values)^2))
  return(rmse)
}

# Specify lag orders to compare
lag_orders <- c(1, 2, 3, 4, 5, 6, 7, 8)

# Specify holdout periods to compare
holdout_periods <- c(6, 12, 24)

# Initialize matrix to store RMSE results
results <- matrix(NA, nrow = length(lag_orders), ncol = length(holdout_periods))

# Iterate over lag orders and holdout periods to calculate RMSE for each model
for (i in 1:length(lag_orders)) {
  for (j in 1:length(holdout_periods)) {
    rmse <- calculate_rmse(lag_orders[i], holdout_periods[j], ind_prod)
    results[i, j] <- rmse
  }
}

# Print RMSE results
print(results)

