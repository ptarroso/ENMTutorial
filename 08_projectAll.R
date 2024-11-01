# Ecological Niche Modelling
# Project all models to all temporal periods
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this class we need the previously built models (script 06 and 07) and the
# projection variables (script 05).

# Open necessary libraries.
library(terra)
library(biomod2)


# We will run projections over a loop, so we prepare some needed variables (same
# as script 05).
ages <- c("2021-2040", "2041-2060", "2061-2080")
ssps <- c("126", "585")

# Open current period projection variables
curp <- rast("data/rasters/proj_current.tif")

# load the ensembled models for Vipera aspis
vaName <- load("models/Vaspis/Vaspis.EcoMod.ensemble.models.out")
vaEnsbl <- eval(str2lang(vaName))

# Check the best threshold that is being used to transform continuous 
# probability to 0/1 predictions
get_evaluations(vaEnsbl)

# Project to current time
vaProj <- BIOMOD_EnsembleForecasting(bm.em = vaEnsbl,
                                     proj.name = 'Current',
                                     new.env = curp,
                                     models.chosen = 'all',
                                     metric.binary = 'TSS')
for (age in ages) {
    for (ssp in ssps) {
        projVars <- rast(paste0("data/rasters/proj_", age, "_", ssp, ".tif"))
        vaProj <- BIOMOD_EnsembleForecasting(bm.em = vaEnsbl,
                                             proj.name = paste0(age, "_", ssp),
                                             new.env = projVars,
                                             models.chosen = 'all',
                                             metric.binary = 'TSS')
    }
}

################################################################################
# load the ensembled models for Vipera latastei
vlName <- load("models/Vlatastei/Vlatastei.EcoMod.ensemble.models.out")
vlEnsbl <- eval(str2lang(vlName))

# Check the best threshold that is being used to transform continuous 
# probability to 0/1 predictions
get_evaluations(vlEnsbl)

# Project to current time
vlProj <- BIOMOD_EnsembleForecasting(bm.em = vlEnsbl,
                                     proj.name = 'Current',
                                     new.env = curp,
                                     models.chosen = 'all',
                                     metric.binary = 'TSS')
for (age in ages) {
    for (ssp in ssps) {
        projVars <- rast(paste0("data/rasters/proj_", age, "_", ssp, ".tif"))
        vlProj <- BIOMOD_EnsembleForecasting(bm.em = vlEnsbl,
                                             proj.name = paste0(age, "_", ssp),
                                             new.env = projVars,
                                             models.chosen = 'all',
                                             metric.binary = 'TSS')
    }
}

################################################################################
# load the ensembled models for Vipera seoanei
vsName <- load("models/Vseoanei/Vseoanei.EcoMod.ensemble.models.out")
vsEnsbl <- eval(str2lang(vsName))

# Check the best threshold that is being used to transform continuous 
# probability to 0/1 predictions
get_evaluations(vsEnsbl)

# Project to current time
vsProj <- BIOMOD_EnsembleForecasting(bm.em = vsEnsbl,
                                     proj.name = 'Current',
                                     new.env = curp,
                                     models.chosen = 'all',
                                     metric.binary = 'TSS')
for (age in ages) {
    for (ssp in ssps) {
        projVars <- rast(paste0("data/rasters/proj_", age, "_", ssp, ".tif"))
        vsProj <- BIOMOD_EnsembleForecasting(bm.em = vsEnsbl,
                                             proj.name = paste0(age, "_", ssp),
                                             new.env = projVars,
                                             models.chosen = 'all',
                                             metric.binary = 'TSS')
    }
}
   
