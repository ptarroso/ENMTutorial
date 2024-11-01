# Ecological Niche Modelling
# Select variables based on the correlation score to minimize it
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this class we need 19 bioclimatic variables from WorldClim and 1 EVI
# already proceed in previous scripts and the final presence dataset

# The terra library provides necessary functionality to process spatial (raster
# and vectorial) data in R.
library(terra)

# Open relevant data
evi <- rast("data/rasters/evi.tif")
clim <- rast("data/rasters/climate.tif")
pres <- read.table("data/species/speciesPresence_v2.csv", sep="\t", header=TRUE)

# merge the two raster datasets
rst <- c(clim, evi)
names(rst)

# We need to define a buffer around presence to define our study area where we
# will analyse pairwise correlations. NOTE: this buffer will be important for
# later models as we will have to define same parameter.

# For this example we define a large buffer of 1 degree (~110000m)
bsize <- 1
# Need a conversion of presence points data type to spatial vector
v <- vect(pres, geom= c("x", "y"))
buf <- buffer(v, bsize)
buf <- aggregate(buf)

plot(evi)
plot(buf, add=T)
plot(v, add=T)


# Extract raster data from buffer to calculate correlations
dt <- extract(rst, buf, ID=FALSE)

head(dt)

# remove NAs (rasters are equal, we can use the NAs from a single column)
dt <- dt[!is.na(dt[,1]),]
head(dt)

# Calculate Peason Correlation score
corr <- cor(dt)
corr

# To make decision easier, plot a dendrogram of correlations
# Convert correlation to distance
dist <- 1 - abs(corr)
dist <- as.dist(dist)

# Hierarchical cluster of distance
hc <- hclust(dist, method="single")
plot(hc, hang=-1)

# Selected 5 variables  
# - evi
# - BIO_8 (Mean daily Temperature Wettest Quarter
# - BIO_3 (Isothermality)
# - BIO_12 (Annual Precipitation Amount)
# - BIO_1 (Annual Temperature)

sel_vars <- c("evi", "BIO_8", "BIO_3", "BIO_12", "BIO_1")

sel_rst <- rst[[sel_vars]]

# Check correlation of final dataset
sel_dt <- dt[,sel_vars]
cor(sel_dt)

# Write Final raster to model
writeRaster(sel_rst, "data/rasters/final_vars.tif")
