# Ecological Niche Modelling
# Prepared variables for projection based on the selected variable list
# Author: Pedro Tarroso 2024

# In need the wider area to model each species on its own range, however we only
# need the models in the Iberian Peninsula for this example.
# NOTE: the different projections must follow the same convention of variable
#       names. In this example we set the names (script 02) as:
#       evi, BIO_8, BIO_3, BIO_12, BIO_1

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this class we need the list and rasters  of the selected variables 
# We also need other variables for projection to other time periods.
# These data should be available on "data/rasters/original"

# Since our projection area is the *Iberian Peninsula* we need a shapefile of 
# this area to cut the rasters. Should be available in "data/other/iberia.shp".

# The terra library provides necessary functionality to process spatial (raster
# and vectorial) data in R. 'geodata' will allow to obtain future cliamte data
library(terra)
library(geodata)

# Open Iberia shape file 
v <- vect("data/other/iberia.shp")

# Open current data rasters
vars <- rast("data/rasters/final_vars.tif")

# Cut Current data and save
vars <- crop(vars, v, mask=TRUE)
writeRaster(vars, "data/rasters/proj_current.tif")

# Prepare future projection variables.
# NOTE: In this example, EVI will remain stable because we don't have future
#       projections of EVI change. But keep in mind that this is a biotic
#       variable that tends to change with climate change and human land use.
#       A commom static variable would be elevation, for instance.
# We have 3 ages, 1 gcm, 2 ssp scenarios thus we have to produce 6 (3x1x2) projection files 
ages <- c("2021-2040", "2041-2060", "2061-2080")
scenarios <- c("126", "585")

# bioclimatic in the same order as in vars to simplify
bios <- c("BIO_8", "BIO_3", "BIO_12", "BIO_1")


for (age in ages) {
    for (ssp in scenarios) {
        # download and rename
        clim_fut <- cmip6_world(model='MPI-ESM1-2-HR', ssp=ssp, time=age, var='bioc', res=5, path='data/rasters/original')
        clim_fut <- crop(clim_fut, vars[[1]], mask=TRUE)
        names(clim_fut) <- paste0("BIO_", 1:19)
        #filter the selected vars
        clim_fut <- clim_fut[[bios]]
        # merge with evi
        fut <- c(vars[["evi"]], clim_fut)
        # Write raster to file        
        writeRaster(fut, paste0("data/rasters/proj_", age, "_", ssp, ".tif"))
    }
}




