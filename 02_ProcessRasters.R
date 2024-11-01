# Ecological Niche Modelling
# Obtaining predictors and raster data processing for ENM
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this script you need the raw variables available in the data folder.
# For this class we need 19 bioclimatic variables from WorldClim and 1 EVI.

# The *terra* library provides necessary functionality to process spatial (raster
# and vectorial) data in R, *geodata* provides access to climate data and some
# other spatial data, and gather EVI data. 
library(terra)
library(geodata)


# Get a vector of countries polygons to use Iberian Peninsula as Study Area
countries <- world(path = "data/other")
iberia <- countries[countries$GID_0 %in% c("PRT", "ESP")]
iberia <- disagg(iberia)
areas <- expanse(iberia)
iberia <- iberia[order(areas, decreasing=TRUE)[1:2]]
writeVector(iberia, "data/other/iberia.shp")

# First, we obtain and process climate layers from WorldClim (https://www.worldclim.org/)
# The study resolution will be 10km (around 0.083333(3) decimal degrees).
clim <- worldclim_global(var = 'bio', res = 5, download = F, path = 'data/rasters/original')
plot(clim)


# Update names of bioclimate layers
names(clim)
names(clim) <- paste0("BIO_", 1:19)
plot(clim)

# We define our study area in the extent -11 to 27 for longitude and 25 to 55º for latitude
e <- ext(-11, 27, 25, 55)

# Crop climate data to the study area extent
clim <- crop(clim, e)

# Download EVI data from opengeo.org / openlandmap

# https://s3.openlandmap.org/arco/evi_mod13q1.tmwm.inpaint_p.90_250m_s_20200101_20200228_go_epsg.4326_v20230608.tif
# https://s3.openlandmap.org/arco/evi_mod13q1.tmwm.inpaint_p.90_250m_s_20200301_20200430_go_epsg.4326_v20230608.tif
# https://s3.openlandmap.org/arco/evi_mod13q1.tmwm.inpaint_p.90_250m_s_20200501_20200630_go_epsg.4326_v20230608.tif
# https://s3.openlandmap.org/arco/evi_mod13q1.tmwm.inpaint_p.90_250m_s_20200701_20200831_go_epsg.4326_v20230608.tif
# https://s3.openlandmap.org/arco/evi_mod13q1.tmwm.inpaint_p.90_250m_s_20200901_20201031_go_epsg.4326_v20230608.tif
# https://s3.openlandmap.org/arco/evi_mod13q1.tmwm.inpaint_p.90_250m_s_20201101_20201231_go_epsg.4326_v20230608.tif


# Process annual EVI raster
evifiles <- list.files("data/rasters/original/evi/", "*tif", full.names=TRUE)
evi <- rast(evifiles)

# Crop to the extent of study area
evi <- crop(evi, e)

# Process to get the annual maximum EVI
evi <- app(evi, max, na.rm=T)

# aggregate to same resolution as climate.
# Note that the aggregation cannot be by an integer value... using resample
evi <- resample(evi, clim, "average")

names(evi)
names(evi) <- "evi"

# Although not mandatory, it is better to check the NA area and make sure that
# is the same for all rasters

na.clim <- app(is.na(clim), sum)
plot(na.clim)
na.evi <- is.na(evi)
plot(na.evi)

plot(na.clim + na.evi)

na.mask <- (na.clim + na.evi) > 0
plot(na.mask)

clim[na.mask] <- NA
evi[na.mask] <- NA


# Write Rasters to file
# Climate is a single file with 19 bands/layers
writeRaster(clim, "data/rasters/climate.tif")

#EVI is a single file with single band/layer
writeRaster(evi, "data/rasters/evi.tif")



# If you have reached this point, it means that you finished! Go to script 03!
