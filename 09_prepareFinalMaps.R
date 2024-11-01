# Ecological Niche Modelling
# Access all models and calculate sympatric areas for all time frames 
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this class we need the projections of the built models (script 08)

# We are going to access rasters with ensembled model predictions as produced
# by BIOMOD2. It is done with raster processing alone (could be done in any GIS) 

# Open necessary libraries.
library(terra)

# Prepare some needed variables to loop over different temporal periods
ages <- c("2021-2040", "2041-2060", "2061-2080")
ssps <- c("126", "585")

# open current projections for the three species
va <- rast("models/Vaspis/proj_Current/proj_Current_Vaspis_ensemble.tif")[[1]]
va <- va / 1000
vl <- rast("models/Vlatastei/proj_Current/proj_Current_Vlatastei_ensemble.tif")[[1]]
vl <- vl / 1000
vs <- rast("models/Vseoanei/proj_Current/proj_Current_Vseoanei_ensemble.tif")[[1]]
vs <- vs / 1000

# We are using the continuous probability maps, thus we can find the maximum
# probability of finding the 3 species together by the product of the three
# maps. (Other option would be to open the binary presence/absence map produced
# by biomod2 in the same folder to sum all maps, then the pixels with 3 would
# indicate the predicted presence of the 3 species).

CZ <- va*vl*vs
names(CZ) <- "Present"

# We loop over ages and ssps to produce additional layers of predictions to our
# contact zone (CZ) raster
for (age in ages) {
    for (ssp in ssps) {
        nm <- paste0("proj_", age, "_", ssp)
        vaFile <- paste0("models/Vaspis/", nm, "/", nm, "_Vaspis_ensemble.tif")
        va <- rast(vaFile)[[1]]/1000
        vlFile <- paste0("models/Vlatastei/", nm, "/", nm, "_Vlatastei_ensemble.tif")
        vl <- rast(vlFile)[[1]]/1000
        vsFile <- paste0("models/Vseoanei/", nm, "/", nm, "_Vseoanei_ensemble.tif")
        vs <- rast(vsFile)[[1]]/1000
        
        # Produce Future contact zone and rename accordingly to age and ssp
        futCZ <- va*vl*vs
        names(futCZ) <- paste0(age, "_", ssp)
        
        # Grow CZ raster with each futCZ to store all in same file
        CZ <- c(CZ, futCZ)
    }
}

# Plot all layers
layout(matrix(c(1,1,1,1:7), 5, byrow=TRUE))
plot(CZ[[1]], main=names(CZ)[1], col=hcl.colors(25), range=c(0, 0.3))
plot(CZ[[2]], main=names(CZ)[2], col=hcl.colors(25), range=c(0, 0.3))
plot(CZ[[3]], main=names(CZ)[3], col=hcl.colors(25), range=c(0, 0.3))
plot(CZ[[4]], main=names(CZ)[4], col=hcl.colors(25), range=c(0, 0.3))
plot(CZ[[5]], main=names(CZ)[5], col=hcl.colors(25), range=c(0, 0.3))
plot(CZ[[6]], main=names(CZ)[6], col=hcl.colors(25), range=c(0, 0.3))
plot(CZ[[7]], main=names(CZ)[7], col=hcl.colors(25), range=c(0, 0.3))

# To visualise the change with other strategy, we can use histograms

# Create a data.frame of the data
CZdata <- data.frame(CZ)
head(CZdata)

# As the area is mostly dominated by near zero values, we will remove them based
# in a small threshold to avoid dominating the histogram.
CZdata[CZdata < 0.001] <- NA

# get the names for ploting titles
titles <- names(CZ)

# define the breaks of each histogram bar
brk <- seq(0, 0.35, 0.01)

# Use a for loop to loop over columns (same order as layers in raster)
layout(matrix(c(1,1,1,1:7), 5, byrow=TRUE))
for (i in 1:ncol(CZdata)) {
    hist(CZdata[,i], breaks=brk, main=titles[i], col="steelblue1", border="white")

}


# write Raster
writeRaster(CZ, "models/sympatry.tif")
