# Ecological Niche Modelling
# Final preparation of presence data to remove pixel duplicate and missing data
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this class we need 19 bioclimatic variables from CHELSA and 1 EVI
# already proceed in previous scripts

# The terra library provides necessary functionality to process spatial (raster
# and vectorial) data in R.
library(terra)

# Open relevant data
# Since with made the variable rasters uniform (extent, resolution, and no data)
# we need only one for this process.
evi <- rast("data/rasters/evi.tif")
pres <- read.table("data/species/speciesPresence_v1.csv", sep="\t", header=TRUE)

# extract raster data for each point with information of pixel/cell ID
dt <- extract(evi, pres[,c("x", "y")], cells=TRUE)
head(dt)

# Remove presences falling in raster missing data
mask <- is.na(dt$evi)
sum(mask)
dt <- dt[!mask,]
pres <- pres[!mask,]

# We have to check duplicated by species (multiple species can coexist in same 
# pixel)
sps <- unique(pres$species)

pres$duplicated <- NA

for (sp in sps) {
    rows <- which(pres$species == sp)
    sp.dup <- duplicated(dt$cell[rows])
    pres$duplicated[rows] <- sp.dup
    print(paste("Species", sp, "has", sum(sp.dup), "duplicates"))
}

head(pres)
final_pres <- pres[!pres$duplicated, 1:3]

# Check number of available presence in final dataset 
dim(final_pres)
table(final_pres$species)

# write to file
filename <- "data/species/speciesPresence_v2.csv"
write.table(final_pres, filename, sep="\t", row.names=FALSE, col.names=TRUE)


