
# Header ------------------------------------------------------------------

pacman::p_load(
  brms,
  rstanarm,
  tidyverse,
  bayestestR
)


# Load Model Output -------------------------------------------------------

load("/Users/heinzemax/Downloads/model3.RData")

load("/Users/gustavpirich/Dropbox/Mac/Downloads/project_output/model_stan_rep_gas.RData")
load("/Users/gustavpirich/Dropbox/Mac/Downloads/project_output/model_stan_rep_elec.RData")

# Produce all posterior plots
plot(model_stan_rep_gas)

# Posterior Predictive Checks
pp_check(model_stan_rep_gas, ndraws = 500)

# Produce a concise summary table
fixef(model_stan_rep_gas)

posterior_interval(model_stan_rep_gas)

# Print Highest Density Intervals
bayestestR::hdi(model_stan_rep_gas, ci = c(0.65, 0.70, 0.80, 0.89, 0.95))

# Produce HDI Plots
plot(bayestestR::hdi(model_stan_rep_gas, ci = c(0.65, 0.70, 0.80, 0.89, 0.95)))
