

# Header ------------------------------------------------------------------

rm(list = ls())

pacman::p_load(
  tidyverse,
  countrycode,
  readr,
  lubridate
)

# Local file path since original file is too large to put on GitHub
# Download Link for File from Eurostat:
# https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/DEMO_R_MWK3_20/?format=SDMX-CSV&compressed=true
# https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/DEMO_R_GIND3/?format=SDMX-CSV
# https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/DEMO_R_PJANIND3/?format=SDMX-CSV


in_path_eurostat_mortality <- "..."
in_path_population <- "..."
in_path_population_structure <- "..."

# in_path_eurostat_mortality <- "/Users/gustavpirich/Library/Mobile Documents/com~apple~CloudDocs/Wirtschaftsuniversitaet/MASTER/Advanced Macroeconometrics/MacroMetrics/Project/raw/nuts/demo_r_mwk3_20_linear.csv"
# in_path_population <- "/Users/gustavpirich/Library/Mobile Documents/com~apple~CloudDocs/Wirtschaftsuniversitaet/MASTER/Advanced Macroeconometrics/MacroMetrics/Project/raw/nuts/demo_r_gind3__custom_6985794_linear.csv"
# in_path_population_structure <- "/Users/gustavpirich/Library/Mobile Documents/com~apple~CloudDocs/Wirtschaftsuniversitaet/MASTER/Advanced Macroeconometrics/MacroMetrics/Project/raw/nuts/demo_r_pjanind3__custom_6985756_linear.csv"

# in_path_eurostat_mortality <- "/Users/heinzemax/Documents/GitHub/macrometrics_local/estat_demo_r_mwk3_20_en.csv"
# in_path_population <- "/Users/heinzemax/Documents/GitHub/macrometrics_local/estat_demo_r_gind3_en.csv"
# in_path_population_structure <- "/Users/heinzemax/Documents/GitHub/macrometrics_local/estat_demo_r_pjanind3_en.csv"


# Read Data ---------------------------------------------------------------

eurostat_mortality <- read_csv(in_path_eurostat_mortality)

population <- read_csv(in_path_population)

population_structure <- read_csv(in_path_population_structure)

nuts_levels <- read_csv("./project/data/nuts_levels.csv")


# Data Wrangling ----------------------------------------------------------

mortality <- eurostat_mortality %>%
  dplyr::select(geo, sex, age, TIME_PERIOD, OBS_VALUE) %>%
  dplyr::filter(sex == "T")  %>%
  separate(TIME_PERIOD, into = c("year", "week"), sep = "-W") %>%
  rename(deaths = OBS_VALUE) %>%
  rename(nuts_code = geo)

mortality <- mortality %>%
  left_join(nuts_levels, by = "nuts_code") %>%
  relocate(nuts_level, .before = year) %>%
  mutate(year = as.numeric(year),
         week = as.numeric(week),
         nuts_level = as.factor(nuts_level))



# Population  -------------------------------------------------------------

population <- population %>%
  select(geo, TIME_PERIOD, OBS_VALUE) %>%
  rename(population = OBS_VALUE) %>%
  rename(nuts_code = geo) %>%
  left_join(nuts_levels, by = "nuts_code") 

population_structure <- population_structure %>% 
  select(indic_de, geo, TIME_PERIOD, OBS_VALUE) %>%
  rename(nuts_code = geo) %>%
  rename(pop_share = OBS_VALUE) %>%
  left_join(nuts_levels, by = "nuts_code") %>%
  mutate(pop_share = pop_share/100) %>%
  left_join(population, by = c("nuts_code", "TIME_PERIOD", "nuts_level")) %>%
  mutate(population_group = population*pop_share) %>%
  rename(year = TIME_PERIOD) %>%
  mutate(nuts_level = as.factor(nuts_level))
  
population_structure <- population_structure %>%
  dplyr::mutate(indic_de = case_when(
    indic_de == "PC_Y0_19" ~ "Y_LT20",
    indic_de == "PC_Y20_39" ~ "Y20-39",
    indic_de == "PC_Y40_59" ~ "Y40-59",
    indic_de == "PC_Y60_79" ~ "Y60-79",
    indic_de == "PC_Y80_MAX" ~ "Y_GE80")) %>% 
  rename(age = indic_de)
      

mortality_1 <- mortality %>%
  left_join(population_structure, by = c("year", "nuts_code", "age", "nuts_level")) %>%
  mutate(mortality = (deaths/population_group)*100) %>%
  select(nuts_code, year, age, week, nuts_level, deaths, mortality, pop_share) %>%
  filter(year >= 2014) %>%
  filter(age %in% c("Y20-39", "Y40-59", "Y60-79", "Y_GE80", "Y_LT20")) %>%
  group_by(nuts_code, year, week, nuts_level) %>% 
  summarise(age_adjusted_mortality = weighted.mean(mortality, pop_share))

# Write CSV ---------------------------------------------------------------

write_csv(mortality_1, "./project/data/age_adjusted_weekly_mortality.csv")

