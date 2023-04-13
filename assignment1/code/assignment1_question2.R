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

summary(var_model) #checked

# Computing impulse response function

irf1 <- irf(var_model, impulse = "oil_prod_change", response = "oil_price_real", n.ahead = 15)
irf2 <- irf(var_model, impulse = "econ_act_real", response = "oil_price_real", n.ahead = 15)
irf3 <- irf(var_model, impulse = "oil_price_real", response = "oil_price_real", n.ahead = 15)

#Plotting the IRFs to recreate Figure 1
plot(irf1, main="Oil supply shock")
plot(irf2, main="Aggregate demand shock")
plot(irf3, main="Oil-specific demand shock") # NOT CORRECT



# Replicating Figure 3 ----------------------------------------------------

irf4 <- irf(var_model, impulse = "oil_price_real", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15)

plot(irf4, ylim = c(-3,3))


irf5 <- irf(var_model, impulse = "econ_act_real", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15)

plot(irf5, ylim = c(-3,3))


irf6 <- irf(var_model, impulse = "oil_prod_change", response = "div_growth_change_real", 
            cumulative = TRUE, n.ahead = 15)

plot(irf6) # NOT CORRECT



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

kpdata_2 <- cbind(kpdata, 100*real_stock_returns)


# Does this make sense?? 
