
# Header ------------------------------------------------------------------

rm(list = ls())
gc()

pacman::p_load(
  tidyverse,
  urca
)


# Read in Data ------------------------------------------------------------

kpdata <- read.fwf("./assignment1/data/data_kilian_park_2009.txt", widths = c(10,10,10,10), header = FALSE)

