

# Header ------------------------------------------------------------------

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate
)

# Local file path since original file is too large to put on GitHub
# Download Link for File from Eurostat:
# https://ec.europa.eu/eurostat/databrowser/view/DEMO_R_MWK3_10/default/table?lang=en
in_path <- "/Users/gustavpirich/Library/Mobile Documents/com~apple~CloudDocs/Wirtschaftsuniversitaet/MASTER/Advanced Macroeconometrics/MacroMetrics/Project/raw/nuts/demo_r_mwk3_10_linear.csv"


# Read Data ---------------------------------------------------------------

eurostat_mortality <- read_csv(in_path)

nuts_levels <- read_csv("./project/data/nuts_levels.csv")


# Data Wrangling ----------------------------------------------------------

mortality <- eurostat_mortality %>%
  dplyr::select(geo, sex, age, TIME_PERIOD, OBS_VALUE) %>%
  dplyr::filter(sex == "T")  %>%
  #separate(geo, into = c("nuts_code", "nuts_name"), sep = ":") %>%
  separate(TIME_PERIOD, into = c("year", "week"), sep = "-W") %>%
  rename(deaths = OBS_VALUE) %>%
  rename(nuts_code = geo)

mortality <- mortality %>%
  separate(geo, into = c("nuts_code", "nuts_name"), sep = ":") 
  left_join(nuts_levels, by = "nuts_code") %>%
  relocate(nuts_level, .before = year) %>%
  mutate(year = as.numeric(year),
         week = as.numeric(week),
         nuts_level = as.factor(nuts_level))


# Write CSV ---------------------------------------------------------------

write_csv(mortality, "./project/data/mortality_weekly_age.csv")

