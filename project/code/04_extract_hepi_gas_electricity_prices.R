


# Header ------------------------------------------------------------------

pacman::p_load(
  tidyverse,
  readxl,
)



# Read Data ---------------------------------------------------------------

elect_pps <- read_excel("./project/data/HEPI_June_2023_Prices.cleaned.xlsx", sheet = 3, range = "B2:AL176", col_names = TRUE)

gas_pps <- read_excel("./project/data/HEPI_June_2023_Prices.cleaned.xlsx", sheet = 7, range = "B2:AG176", col_names = TRUE)



# Data Wrangling ----------------------------------------------------------

elect_pps_1 <- elect_pps %>%
  fill("...1") %>%
  rename("year" = "...1") %>%
  rename("month" = "Purchasing power parities (PPPs) - EU27=1")

gas_pps_1 <- gas_pps %>%
  fill("...1") %>%
  rename("year" = "...1") %>%
  rename("month" = "Purchasing power parities (PPPs) - EU27=1")


# Convert wide format to long format
elect_pps_2 <- pivot_longer(elect_pps_1, 3:37, names_to = "country", values_to = "elect_ppi")
gas_pps_2 <- pivot_longer(gas_pps_1, 3:32, names_to = "country", values_to = "gas_ppi")

# Join two dataframes
hepi_ppi_1 <- left_join(gas_pps_2, elect_pps_2)

# Split country column into capital and country_code
hepi_ppi_2 <- hepi_ppi_1 %>%
  separate_wider_delim(country, delim = " ", names = c("capital", "country_code"), too_many = c("drop"))

# Load country list from csv file
country_list <- read_csv("./project/data/country-list.csv")

# Replace "United Kingdom; England" with "United Kingdom" in country list
country_list$country[country_list$country == "United Kingdom; England"] <- "United Kingdom"


# Modify month abbreviations in the dataframe
hepi_ppi_2 <- hepi_ppi_2 %>%
  mutate(month = case_when(
    month == "Jun" ~ "June",
    month == "Jul" ~ "July",
    TRUE ~ month  # keep original value for other cases
    ))


# Join the main dataframe with country list
hepi_ppi_3 <- left_join(hepi_ppi_2, country_list %>% 
                          select(country, capital), relationship = "many-to-many") 

# Rename the country column to country_clean
hepi_ppi_3 <- hepi_ppi_3 %>% 
  rename("country_clean" = "country") 




# Write CSV ---------------------------------------------------------------


write_csv(hepi_ppi_3, "./project/data/prices.csv")
