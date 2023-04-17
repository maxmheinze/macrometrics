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

var_model <- VAR(kpdata, p = 24, type = "const")
coefficients <- coef(var_model)
residuals <- resid(var_model)
print(coefficients)

summary(var_model)

# Computing impulse response function with recursive-design wild bootstrap

set.seed(123) # for reproducibility

nboot <- 1000 # number of bootstrap replications
irf1 <- irf(var_model, impulse = "oil_prod_change", response = "oil_price_real", n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")
irf1$irf$oil_prod_change <- irf1$irf$oil_prod_change * (-1) # Switching signs of shock
irf1$Lower$oil_prod_change <- irf1$Lower$oil_prod_change * (-1) # and of the CIs
irf1$Upper$oil_prod_change <- irf1$Upper$oil_prod_change * (-1)

irf2 <- irf(var_model, impulse ="econ_act_real", response = "oil_price_real", n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")

irf3 <- irf(var_model, impulse = "oil_price_real", response = "oil_price_real", n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")


#Plotting the IRFs to recreate Figure 1

plot(irf1, main="Oil supply shock", ylab="Real price of oil")

plot(irf2, main="Aggregate demand shock", ylab="Real price of oil")

plot(irf3, main="Oil-specific demand shock", ylab="Real price of oil") 


# Replicating Lower Panel Figure 3 ----------------------------------------------------

set.seed(123) # for reproducibility

nboot <- 1000 # number of bootstrap replications
irf4 <- irf(var_model, impulse = "oil_prod_change", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")

irf4$irf$oil_prod_change <- (-1)*irf4$irf$oil_prod_change # Switching signs of shock
irf4$Lower$oil_prod_change <- (-1)*irf4$Lower$oil_prod_change # and of the CIs
irf4$Upper$oil_prod_change <- (-1)*irf4$Upper$oil_prod_change

irf5 <- irf(var_model, impulse = "econ_act_real", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")

irf6 <- irf(var_model, impulse = "oil_price_real", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15, boot = TRUE, nboot = nboot, ci = (0.95), boot.type = "rdwb")


plot(irf4, ylim = c(-3,3), main="Oil supply shock", ylab="Cumulative Real Dividends (Percent)")

plot(irf5, ylim = c(-3,3),  main="Aggregate demand shock", ylab="Cumulative Real Dividends (Percent)")

plot(irf6, ylim = c(-3,3), main="Oil-specific demand shock", ylab="Cumulative Real Dividends (Percent)")



# Replicating Table 2 -----------------------------------------------------

table_2 <- fevd(var_model, n.ahead = 1000)$div_growth_change_real %>%
  magrittr::multiply_by(100) %>%
  cbind(horizon = 1:1000) %>%
  as_tibble() %>%
  dplyr::relocate(horizon, .before = oil_prod_change) %>%
  dplyr::filter(horizon %in% c(1, 2, 3, 12, 1000)) %>%
  mutate(horizon = ifelse(horizon == 1000, Inf, horizon))

table_2



# Stock Market Returns ----------------------------------------------------

fred <- read.csv("./assignment1/data/fred.csv")[-1,]


fred_kp <- fred[169:576,] %>% # only choosing 1.1973 to 12.2006
  as_tibble() %>%
  dplyr::select(S.P.500, CPIAUCSL)


sp_kp <- ts_explode(fred_kp$S.P.500) %>%
  magrittr::set_colnames(c("sp500", "sp500_log", "sp500_mom", "sp500_momlog", "sp500_yoy", "sp500_yoylag")) %>%
  magrittr::extract(-1,) %>% 
  as_tibble()

cpi_kp <- ts_explode(fred_kp$CPIAUCSL) %>%
  magrittr::set_colnames(c("cpi", "cpi_log", "cpi_mom", "cpi_momlog", "cpi_yoy", "cpi_yoylag")) %>%
  magrittr::extract(-1,) %>%
  as_tibble()

real_stock_returns <- sp_kp$sp500_momlog-cpi_kp$cpi_mom

kpdata_2 <- cbind(kpdata, real_stock_returns = 100*real_stock_returns)



# Re-estimating the model -------------------------------------------------


var_model_2 <- VAR(kpdata_2, p = 24, type = "const")

summary(var_model_2)



# Replicating Figure 1 ----------------------------------------------------

set.seed(123) # for reproducibility

nboot <- 1000 # number of bootstrap replications
irf7 <- irf(var_model_2, impulse = "oil_prod_change", response = "oil_price_real", n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")
irf7$irf$oil_prod_change <- irf7$irf$oil_prod_change * (-1) # Switching signs of shock
irf7$Lower$oil_prod_change <- irf7$Lower$oil_prod_change * (-1) # and of the CIs
irf7$Upper$oil_prod_change <- irf7$Upper$oil_prod_change * (-1)

irf8 <- irf(var_model_2, impulse = "econ_act_real", response = "oil_price_real", n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")

irf9 <- irf(var_model_2, impulse = "oil_price_real", response = "oil_price_real", n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")


plot(irf7, ylim = c(-6,12), main="Oil supply shock", ylab="Real price of oil")

plot(irf8, ylim = c(-6,12),  main="Aggregate demand shock", ylab="Real price of oil")

plot(irf9, ylim = c(-6,12), main="Oil-specific demand shock", ylab="Real price of oil")


# Replicating Upper Panel Figure 3 ----------------------------------------------------

set.seed(123) # for reproducibility

nboot <- 1000 # number of bootstrap replications

irf10 <- irf(var_model_2, impulse = "oil_prod_change", response = "real_stock_returns", 
             cumulative = TRUE, n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")

irf10$irf$oil_prod_change <- (-1)*irf10$irf$oil_prod_change # Switching signs of shock
irf10$Lower$oil_prod_change <- (-1)*irf10$Lower$oil_prod_change # and of the CIs
irf10$Upper$oil_prod_change <- (-1)*irf10$Upper$oil_prod_change

irf11 <- irf(var_model_2, impulse = "econ_act_real", response = "real_stock_returns", 
             cumulative = TRUE, n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")

irf12 <- irf(var_model_2, impulse = "oil_price_real", response = "real_stock_returns", 
             cumulative = TRUE, n.ahead = 15, boot = TRUE, nboot = nboot, ci = 0.95, boot.type = "rdwb")


plot(irf10, ylim = c(-3,3), main="Oil supply shock", ylab="Cumulative Real Stock Returns (Percent)")

plot(irf11, ylim = c(-3,3),  main="Aggregate demand shock", ylab="Cumulative Real Stock Returns (Percent)")

plot(irf12, ylim = c(-3,3), main="Oil-specific demand shock", ylab="Cumulative Real Stock Returns (Percent)")

# Replicating Table 1 -----------------------------------------------------

table_1 <- fevd(var_model_2, n.ahead = 1000)$real_stock_returns %>%
  magrittr::multiply_by(100) %>%
  cbind(horizon = 1:1000) %>%
  as_tibble() %>%
  dplyr::relocate(horizon, .before = oil_prod_change) %>%
  dplyr::select(-div_growth_change_real) %>%
  dplyr::filter(horizon %in% c(1, 2, 3, 12, 1000)) %>%
  mutate(horizon = ifelse(horizon == 1000, Inf, horizon))

table_1

