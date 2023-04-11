# Header ------------------------------------------------------------------

rm(list = ls())
gc()

pacman::p_load(
  tidyverse,
  urca,
  vars
)


# Read in Data ------------------------------------------------------------

kpdata <- read.table("./assignment1/data/data_kilian_park_2009.txt", header = FALSE)
colnames(kpdata) <- c("oil_prod_change", "econ_act_real", "oil_price_real", "div_growth_change_real")

# Estimating the VAR ------------------------------------------------------

var_model <- VAR(kpdata, p = 1, type = "const")
coefficients <- coef(var_model)
residuals <- resid(var_model)
print(coefficients)

# Computing impulse response function

irf1 <- irf(var_model, impulse = "oil_price_real", response = "oil_prod_change", n.ahead = 15)
irf2 <- irf(var_model, impulse = "oil_price_real", response = "econ_act_real", n.ahead = 15)
irf3 <- irf(var_model, impulse = "oil_price_real", response = "oil_price_real", n.ahead = 15)


