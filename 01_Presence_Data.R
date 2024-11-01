# Ecological Niche Modelling
# Presence Data Acquisition and cleaning for ENM
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# 1) Go to GBIF site and download species observation data as a zip file.
# In this example we will use the three Iberian vipers:
#    - Vipera seoanei
#    - Vipera latastei
#    - Vipera aspis
# Note: the students should find some species of their interest to download and
# process the data for the final report.

# Read the text csv file wit GBIF data and clean erroneous presences
# Other resources: https://ptarroso.github.io/zero-2-3d/
library(CoordinateCleaner)

# Read data from gbif data file
vasp <- read.table("data/species/original/Vaspis.csv", sep="\t", header=TRUE, quote="", comment.char="")
vlat <- read.table("data/species/original/Vlatastei.csv", sep="\t", header=TRUE, quote="", comment.char="")
vseo <- read.table("data/species/original/Vseoanei.csv", sep="\t", header=TRUE, quote="", comment.char="")

dim(vasp)
dim(vlat)
dim(vseo)

# Remove rows where longitude and latitude are absent
mask_vasp <- is.na(vasp$decimalLatitude + vasp$decimalLongitude)
vasp <- vasp[!mask_vasp,]

mask_vlat <- is.na(vlat$decimalLatitude + vlat$decimalLongitude)
vlat <- vlat[!mask_vlat,]

mask_vseo <- is.na(vseo$decimalLatitude + vseo$decimalLongitude)
vseo <- vseo[!mask_vseo,]


# Flag and clean erroneous coordinates

tests <- c("capitals", "centroids", "equal", "gbif", "institutions", "zeros")

flags_vasp <- clean_coordinates(x = vasp, lon = "decimalLongitude", lat = "decimalLatitude",
                                species = "species", countries = "countryCode",
                                country_refcol = "iso_a2", tests = tests)

vasp <- vasp[flags_vasp$.summary,]


flags_vlat <- clean_coordinates(x = vlat, lon = "decimalLongitude", lat = "decimalLatitude",
                                species = "species", countries = "countryCode",
                                country_refcol = "iso_a2", tests = tests)

vlat <- vlat[flags_vlat$.summary,]

flags_vseo <- clean_coordinates(x = vseo, lon = "decimalLongitude", lat = "decimalLatitude",
                                species = "species", countries = "countryCode",
                                country_refcol = "iso_a2", tests = tests)

vseo <- vseo[flags_vseo$.summary,]


# Remove high coordinate uncertainty
u_vasp <- vasp$coordinateUncertaintyInMeters
vasp <- vasp[u_vasp <= 10000 | is.na(u_vasp),]

u_vlat <- vlat$coordinateUncertaintyInMeters
vlat <- vlat[u_vlat <= 10000 | is.na(u_vlat),]

u_vseo <- vseo$coordinateUncertaintyInMeters
vseo <- vseo[u_vseo <= 10000 | is.na(u_vseo),]


# Remove fossil records
vasp <- vasp[vasp$basisOfRecord != "FOSSIL_SPECIMEN",]
vlat <- vlat[vlat$basisOfRecord != "FOSSIL_SPECIMEN",]
vseo <- vseo[vseo$basisOfRecord != "FOSSIL_SPECIMEN",]


# Sometimes there are records of absences. Remove them.
i_vasp <- vasp$individualCount 
vasp <- vasp[i_vasp > 0 | is.na(i_vasp) , ]

i_vlat <- vlat$individualCount 
vlat <- vlat[i_vlat > 0 | is.na(i_vlat) , ]

i_vseo <- vseo$individualCount 
vseo <- vseo[i_vseo > 0 | is.na(i_vseo) , ]

# Remove very old records
vasp <- vasp[vasp$year > 1970 | is.na(vasp$year), ]
vlat <- vlat[vlat$year > 1970 | is.na(vlat$year), ]
vseo <- vseo[vseo$year > 1970 | is.na(vseo$year), ]

# Select only coordinates and remove duplicated coordinates
vasp <- data.frame(species="Vaspis", x=vasp$decimalLongitude, y=vasp$decimalLatitude)
vasp <- unique(vasp)

vlat <- data.frame(species="Vlatastei", x=vlat$decimalLongitude, y=vlat$decimalLatitude)
vlat <- unique(vlat)

vseo <- data.frame(species="Vseoanei", x=vseo$decimalLongitude, y=vseo$decimalLatitude)
vseo <- unique(vseo)


# merge all data into a single dataframe
species <- rbind(vasp, vlat, vseo)

# A final check is a visual inspection of the plotted points (could be done more
# interactively in a GIS such as QGIS).

plot(species$x, species$y, asp=1, cex=0.3)

sp_factor <- as.factor(species$species)
levels(sp_factor)
levels(sp_factor) <- c("orange", "red", "blue")
# Hint: check function colors()
color <- as.character(sp_factor)
plot(species$x, species$y, asp=1, cex=0.3, col=color)

abline(v=-0.5, col='blue')
abline(h=41, col='blue')

abline(v=5, col='orange', lty=2)
abline(h=41, col='orange', lty=2)


# Remove wrong seoanei coordinates
mask <- species$species == "Vseoanei" & ( species$x > -0.5 | species$y < 41)
species <- species[!mask,]

mask <- species$species == "Vaspis" & ( species$x < 5 & species$y < 41)
species <- species[!mask,]



# Write coordinates to text file
# Note: this is not the final dataset because it is still needed to remove pixel
#       duplicates. For that with need rasters (map variables) with defined 
#       resolution (script 03).
filename <- "data/species/speciesPresence_v1.csv"
write.table(species, filename, sep="\t", row.names=FALSE, col.names=TRUE)


