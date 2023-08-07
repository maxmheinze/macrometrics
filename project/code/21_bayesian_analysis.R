# Header ------------------------------------------------------------------

pacman::p_load(
  brms,
  rstanarm,
  tidyverse,
  bayestestR
)


# Load Model Output -------------------------------------------------------

load("...")

current_model <- model8

# Produce all posterior plots
plot(current_model)

# Posterior Predictive Checks
pp_check(current_model, ndraws = 100)

# Produce a concise summary table
fixef(current_model)

posterior_interval(current_model)

# Print Highest Density Intervals
bayestestR::hdi(current_model, ci = c(0.65, 0.70, 0.80, 0.89, 0.95))

# Produce HDI Plots
plot(bayestestR::hdi(current_model, ci = c(0.65, 0.70, 0.80, 0.89, 0.95)))