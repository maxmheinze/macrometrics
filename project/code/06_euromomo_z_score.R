# Load necessary libraries
library(lubridate)
library(stringr)

setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Wirtschaftsuniversitaet/MASTER/Advanced Macroeconometrics/MacroMetrics/Project/raw/EUROMOMO")

# Read in the csv file
euromomo_z_score <- read_delim("charts-z-scores-by-country (2).csv", delim = ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE)
euromomo_z_score_75_84 <- read_delim("charts-z-scores-by-country (75-84).csv", delim = ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE)

# Extract year and week separately from week column
euromomo_score <- euromomo_z_score_75_84 %>%
  mutate(year = as.numeric(substr(week, 1, 4))) %>%
  mutate(week_sep = as.numeric(substr(week, 6, 7))) 

# Split the week column to get Year and Week separately
euromomo_score$Year <- as.integer(str_split_fixed(euromomo_score$week, "-", 2)[,1])
euromomo_score$Week <- as.integer(str_split_fixed(euromomo_score$week, "-", 2)[,2])

# Correct for the year of week 53
last_day_of_year <- ymd(paste(euromomo_score$Year, "12-31", sep="-"))
should_be_53 <- wday(last_day_of_year) %in% c(5, 6, 7)  # Thursday, Friday, Saturday
euromomo_score$Year[euromomo_score$Week == 53 & !should_be_53] <- euromomo_score$Year[euromomo_score$Week == 53 & !should_be_53] + 1
euromomo_score$Week[euromomo_score$Week == 53 & !should_be_53] <- 1

# Create date from year, week and a fixed weekday
euromomo_score$Date <- as.Date(paste(euromomo_score$Year, euromomo_score$Week, 1, sep="-"), "%Y-%U-%u")

# Replace NA values in the Date column with a specified date
replacement_date <- as.Date("2020-12-31")
euromomo_score$Date[is.na(euromomo_score$Date)] <- replacement_date

# Add month column
euromomo_score$month <- month(euromomo_score$Date)

# Convert month names to numeric values in hepi_ppi_3 data frame
month.name <- c("Jan", "Feb", "Mar", "Apr","May",  "June", "July", "Aug","Sep", "Oct", "Nov", "Dec")
hepi_ppi_3$month <- match(tolower(hepi_ppi_3$month), tolower(month.name))

# Clean country names
euromomo_score_clean <- euromomo_score %>%
  mutate(country_clean = case_when(
    country == "Germany (Hesse)" ~ "Germany",
    country == "Germany (Berlin)" ~ "Germany",
    TRUE ~ country  # keep original value for other cases
  ))

euromomo_score_clean_1 <- euromomo_score_clean %>%
  mutate(country_clean = case_when(
    country_clean == "UK (England)" ~ "United Kingdom",
    country_clean == "UK (Scotland)" ~ "United Kingdom",
    country_clean == "UK (Wales)" ~ "United Kingdom",
    TRUE ~ country_clean  # keep original value for other cases
  ))

# Join euromomo_score_clean_1 and hepi_ppi_3 data frames
df3 <- left_join(euromomo_score_clean_1 %>% select(country,country_clean, year, month, week_sep, zscore), 
                 hepi_ppi_3 %>% select(country_clean, year, month, elect_ppi, gas_ppi), 
                 by = c("country_clean", "year", "month"))

# Select required columns
eurmomo_z_gasppi_electppi_1 <- df3 %>% select(country, year, month, week_sep, zscore, elect_ppi, gas_ppi)

# Create a new column "period"
eurmomo_z_gasppi_electppi <- eurmomo_z_gasppi_electppi_1 %>%
  mutate(period = as.integer(paste(year, month, week_sep, sep ="")))


write.csv(eurmomo_z_gasppi_electppi, "/Users/gustavpirich/Library/Mobile Documents/com~apple~CloudDocs/Wirtschaftsuniversitaet/MASTER/Advanced Macroeconometrics/MacroMetrics/Project/raw/EUROMOMO/eurmomo_z_gasppi_electppi.csv")





