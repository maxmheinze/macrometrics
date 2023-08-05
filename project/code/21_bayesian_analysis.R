
# Header ------------------------------------------------------------------

pacman::p_load(
  brms,
  rstanarm,
  tidyverse,
  bayestestR
)


# Load Model Output -------------------------------------------------------

load("/Users/heinzemax/Downloads/model3.RData")

# Produce all posterior plots
plot(model3)

# Posterior Predictive Checks
pp_check(model3, ndraws = 100)

# Produce a concise summary table
fixef(model3)

# Print Highest Density Intervals
bayestestR::hdi(model3, ci = c(0.65, 0.70, 0.80, 0.89, 0.95))

# Produce HDI Plots
plot(bayestestR::hdi(model3, ci = c(0.65, 0.70, 0.80, 0.89, 0.95)))
