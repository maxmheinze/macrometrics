pacman::p_load(
  dplyr,
  tidyr,
  countrycode
)

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

write.csv(EC_shares_HH, file = "...", row.names = FALSE)
