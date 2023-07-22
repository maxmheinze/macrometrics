
# Load Packages, Specify Local File Paths (Because Data is Big) -----------

rm(list = ls())

pacman::p_load(
  tidyverse,
  sf,
  terra,
  ncdf4,
  rgdal,
  exactextractr,
  raster
)

# Path for Temperature Raster
tmp_raster_path <- "..."

# Path for Humidity Raster
hum_raster_path <- "..."

# Path for Output CSV
out_path <- "..."


# Read in Raster Data -----------------------------------------------------

tmp_raster <- terra::rast(tmp_raster_path)

hum_raster <- terra::rast(hum_raster_path)


# Read in Shapefile of NUTS Regions ---------------------------------------

# Read in shapefile, which is in EPSG 4326, which is WGS-84
shpfile <- read_sf("/Users/heinzemax/Documents/GitHub/macrometrics_local/NUTS_RG_20M_2021_4326.shp/NUTS_RG_20M_2021_4326.shp")


# Extract Mean Temperature and Humidity for Polygons ----------------------

# Splitting this up like this somehow makes it considerably faster.
# This is a quick and dirty solution but I have spent too many hours
# on this to have any motivation left to make it more beautiful

terra::gdalCache(3001)

tmp_layer_1 <- subset(tmp_raster,1:1000)
tmp_extract_layer_1 <- exact_extract(tmp_layer_1, shpfile, fun = "mean")

tmp_layer_2 <- subset(tmp_raster,1001:2000)
tmp_extract_layer_2 <- exact_extract(tmp_layer_2, shpfile, fun = "mean")

tmp_layer_3 <- subset(tmp_raster,2001:3000)
tmp_extract_layer_3 <- exact_extract(tmp_layer_3, shpfile, fun = "mean")

tmp_layer_4 <- subset(tmp_raster,3001:4000)
tmp_extract_layer_4 <- exact_extract(tmp_layer_4, shpfile, fun = "mean")

tmp_layer_5 <- subset(tmp_raster,4001:nlyr(tmp_raster))
tmp_extract_layer_5 <- exact_extract(tmp_layer_5, shpfile, fun = "mean")

tmp_extract <- data.frame(tmp_extract_layer_1, 
                          tmp_extract_layer_2, 
                          tmp_extract_layer_3, 
                          tmp_extract_layer_4,
                          tmp_extract_layer_5)

colnames(tmp_extract) <- paste0("tmp_", time(tmp_raster))


hum_layer_1 <- subset(hum_raster,1:1000)
hum_extract_layer_1 <- exact_extract(hum_layer_1, shpfile, fun = "mean")

hum_layer_2 <- subset(hum_raster,1001:2000)
hum_extract_layer_2 <- exact_extract(hum_layer_2, shpfile, fun = "mean")

hum_layer_3 <- subset(hum_raster,2001:3000)
hum_extract_layer_3 <- exact_extract(hum_layer_3, shpfile, fun = "mean")

hum_layer_4 <- subset(hum_raster,3001:4000)
hum_extract_layer_4 <- exact_extract(hum_layer_4, shpfile, fun = "mean")

hum_layer_5 <- subset(hum_raster,4001:nlyr(hum_raster))
hum_extract_layer_5 <- exact_extract(hum_layer_5, shpfile, fun = "mean")

hum_extract <- data.frame(hum_extract_layer_1, 
                          hum_extract_layer_2, 
                          hum_extract_layer_3, 
                          hum_extract_layer_4,
                          hum_extract_layer_5)

colnames(hum_extract) <- paste0("hum_", time(hum_raster))


# Bind Everything Together ------------------------------------------------

climate_data <- st_drop_geometry(shpfile) %>%
  bind_cols(tmp_extract, hum_extract) %>%
  pivot_longer(`tmp_2011-01-01`:`hum_2022-12-31`, 
               names_to = c("climate_variable", "date"), 
               names_sep = "_", 
               values_to = "value")


# Export as CSV -----------------------------------------------------------

write_csv(climate_data, out_path)



