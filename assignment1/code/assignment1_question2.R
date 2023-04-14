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

# Computing impulse response function

irf1 <- irf(var_model, impulse = "oil_prod_change", response = "oil_price_real", n.ahead = 15)
irf1$irf$oil_prod_change <- irf1$irf$oil_prod_change * (-1) # Switching signs of shock
irf1$Lower$oil_prod_change <- irf1$Lower$oil_prod_change * (-1) # and of the CIs
irf1$Upper$oil_prod_change <- irf1$Upper$oil_prod_change * (-1)

irf2 <- irf(var_model, impulse = "econ_act_real", response = "oil_price_real", n.ahead = 15)

irf3 <- irf(var_model, impulse = "oil_price_real", response = "oil_price_real", n.ahead = 15)

#Plotting the IRFs to recreate Figure 1

plot(irf1, main="Oil supply shock", ylab="Real price of oil")

plot(irf2, main="Aggregate demand shock", ylab="Real price of oil")

plot(irf3, main="Oil-specific demand shock", ylab="Real price of oil") 



# Replicating Figure 3 ----------------------------------------------------

irf4 <- irf(var_model, impulse = "oil_price_real", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15)

plot(irf4, ylim = c(-3,3), main="Oil-specific demand shock", ylab="Cumulative Real Dividends (Percent)")


irf5 <- irf(var_model, impulse = "econ_act_real", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15)

plot(irf5, ylim = c(-3,3),  main="Aggregate demand shock", ylab="Cumulative Real Dividends (Percent)")


irf6 <- irf(var_model, impulse = "oil_prod_change", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15)

irf6$irf$oil_prod_change <- (-1)*irf6$irf$oil_prod_change # Switching signs of shock
irf6$Lower$oil_prod_change <- (-1)*irf6$Lower$oil_prod_change # and of the CIs
irf6$Upper$oil_prod_change <- (-1)*irf6$Upper$oil_prod_change

plot(irf6, ylim = c(-3,3), main="Oil supply shock", ylab="Cumulative Real Dividends (Percent)")



# Replicating Table 2 -----------------------------------------------------

table_2 <- fevd(var_model, n.ahead = 1000)$div_growth_change_real %>%
  `*`(100) %>%
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
  `colnames<-`(c("sp500", "sp500_log", "sp500_mom", "sp500_momlog", "sp500_yoy", "sp500_yoylag")) %>%
  `[`(-1,) %>% # Kilian&Park data set has only 407 rows so maybe they also omitted the first?
  as_tibble()

cpi_kp <- ts_explode(fred_kp$CPIAUCSL) %>%
  `colnames<-`(c("cpi", "cpi_log", "cpi_mom", "cpi_momlog", "cpi_yoy", "cpi_yoylag")) %>%
  `[`(-1,) %>%
  as_tibble()

real_stock_returns <- sp_kp$sp500_momlog-cpi_kp$cpi_mom

kpdata_2 <- cbind(kpdata, real_stock_returns = 100*real_stock_returns)



# Re-estimating the model -------------------------------------------------


var_model_2 <- VAR(kpdata_2, p = 24, type = "const")

print(coefficients)

summary(var_model_2)



# Replicating Figure 1 ----------------------------------------------------

irf7 <- irf(var_model_2, impulse = "oil_prod_change", response = "oil_price_real", n.ahead = 15)
irf7$irf$oil_prod_change <- irf7$irf$oil_prod_change * (-1) # Switching signs of shock
irf7$Lower$oil_prod_change <- irf7$Lower$oil_prod_change * (-1) # and of the CIs
irf7$Upper$oil_prod_change <- irf7$Upper$oil_prod_change * (-1)

plot(irf7, ylim = c(-6,12), main="Oil supply shock", ylab="Real price of oil")


irf8 <- irf(var_model_2, impulse = "econ_act_real", response = "oil_price_real", n.ahead = 15)

plot(irf8, ylim = c(-6,12),  main="Aggregate demand shock", ylab="Real price of oil")


irf9 <- irf(var_model_2, impulse = "oil_price_real", response = "oil_price_real", n.ahead = 15)

plot(irf9, ylim = c(-6,12), main="Oil-specific demand shock", ylab="Real price of oil")


# Replicating Figure 3 ----------------------------------------------------

irf10 <- irf(var_model_2, impulse = "oil_price_real", response = "real_stock_returns", 
            cumulative = TRUE, n.ahead = 15)

plot(irf10, ylim = c(-3,3), main="Oil-specific demand shock", ylab="Cumulative Real Dividends (Percent)")


irf11 <- irf(var_model_2, impulse = "econ_act_real", response = "real_stock_returns", 
            cumulative = TRUE, n.ahead = 15)

plot(irf11, ylim = c(-3,3),  main="Aggregate demand shock", ylab="Cumulative Real Dividends (Percent)")


irf12 <- irf(var_model_2, impulse = "oil_prod_change", response = "real_stock_returns", 
            cumulative = TRUE, n.ahead = 15)

irf12$irf$oil_prod_change <- (-1)*irf12$irf$oil_prod_change # Switching signs of shock
irf12$Lower$oil_prod_change <- (-1)*irf12$Lower$oil_prod_change # and of the CIs
irf12$Upper$oil_prod_change <- (-1)*irf12$Upper$oil_prod_change

plot(irf12, ylim = c(-3,3), main="Oil supply shock", ylab="Cumulative Real Dividends (Percent)")

# Replicating Table 1 -----------------------------------------------------

table_1 <- fevd(var_model_2, n.ahead = 1000)$real_stock_returns %>%
  `*`(100) %>%
  cbind(horizon = 1:1000) %>%
  as_tibble() %>%
  dplyr::relocate(horizon, .before = oil_prod_change) %>%
  dplyr::select(-div_growth_change_real) %>%
  dplyr::filter(horizon %in% c(1, 2, 3, 12, 1000)) %>%
  mutate(horizon = ifelse(horizon == 1000, Inf, horizon))

table_1

