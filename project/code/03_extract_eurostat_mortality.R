

# Header ------------------------------------------------------------------

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate
)

# Local file path since original file is too large to put on GitHub
# Download Link for File from Eurostat:
# https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/DEMO_R_MWK3_T/?format=SDMX-CSV&lang=en&label=both
in_path <- "/Users/gustavpirich/Library/Mobile Documents/com~apple~CloudDocs/Wirtschaftsuniversitaet/MASTER/Advanced Macroeconometrics/MacroMetrics/Project/raw/nuts/estat_demo_r_mwk3_t_en.csv"


# Read Data ---------------------------------------------------------------

eurostat_mortality <- read_csv(in_path)

nuts_levels <- read_csv("./project/data/nuts_levels.csv")


# Data Wrangling ----------------------------------------------------------

mortality <- eurostat_mortality %>%
  dplyr::select(geo, TIME_PERIOD, OBS_VALUE) %>%
  separate(geo, into = c("nuts_code", "nuts_name"), sep = ":") %>%
  separate(TIME_PERIOD, into = c("year", "week"), sep = "-W") %>%
  rename(deaths = OBS_VALUE)

mortality <- mortality %>%
  left_join(nuts_levels, by = "nuts_code") %>%
  relocate(nuts_level, .before = year) %>%
  mutate(year = as.numeric(year),
         week = as.numeric(week),
         nuts_level = as.factor(nuts_level))


# Write CSV ---------------------------------------------------------------

write_csv(mortality, "./project/data/mortality_weekly.csv")


