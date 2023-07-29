

# Header ------------------------------------------------------------------

pacman::p_load(
  dplyr,
  tidyr,
  countrycode
)




# EC shares ---------------------------------------------------------------



EC_shares_HH <- read.csv("...") %>%
  filter(!siec=="TOTAL") %>%
  rename(ccode = geo, year = TIME_PERIOD, energy_carrier = siec, values_TJ = OBS_VALUE) %>%
  mutate(energy_carrier = recode(energy_carrier, E7000 = 'Electricity', G3000 = 'Natural gas', H8000 =  'Heat', O4000 =  'Oil and petroleum products',
                       RA000 =  'Renewables and biofuels', SFF_P1000_S2000 =  'Solid fossil fuels'),
         cname = countrycode(ccode, "eurostat", "country.name")) %>%
  group_by(ccode,year) %>%
  mutate(
    shares = round(values_TJ / sum(values_TJ, na.rm = FALSE), 4)
  ) %>%
  ungroup() %>%
  select(ccode,cname,year,energy_carrier,values_TJ,shares) %>%
  arrange(ccode)


#Summarizing to Shares 
EC_shares_HH <- EC_shares_HH %>%
  group_by(ccode, year, energy_carrier) %>%
  mutate(energy_carrier = case_when(
          energy_carrier == "Electricity" ~ "Electricity",
          energy_carrier == "Renewables and biofuels"  ~ "renewables",
          energy_carrier == "Heat"  ~ "renewables", 
          energy_carrier == "Oil and petroleum products" ~ "Natural gas", 
          energy_carrier == "Solid fossil fuels" ~ "Natural gas", 
  )) 

EC_shares_HH <- EC_shares_HH %>%
  mutate(energy_carrier = case_when(
    is.na(energy_carrier) ~ "Natural gas",
    energy_carrier == "Electricity" ~ "Electricity",
    energy_carrier == "renewables" ~ "renewables", 
    energy_carrier == "Natural gas" ~ "Natural gas"
  )) %>%
  group_by(ccode, year, energy_carrier) %>%
  summarize(shares = sum(shares))

write.csv(EC_shares_HH, file = "./project/data/ec_shares_hh.csv", row.names = FALSE)
