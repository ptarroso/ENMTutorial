# Ecological Niche Modelling
# Build models with multiple algorithms
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this class we need the selected variables for modeling and the filtered
# presence locations. This was processed in the previous scripts.

# The terra library provides necessary functionality to process spatial (raster
# and vectorial) data in R and biomod2 library provides functions for model 
# building with pseudo-absence selections, ensembling and projecting methods.
library(terra)
library(biomod2)

# Open relevant data (remember that presence has data for the 3 species and
# that the selected variables are in a single raster file)
pres <- read.table("data/species/speciesPresence_v2.csv", sep="\t", header=TRUE)
vars <- rast("data/rasters/final_vars.tif")

## Vipera aspis - Format data for biomod 
n_va <- sum(pres$species == "Vaspis")
coords_va <- pres[pres$species == "Vaspis", 2:3]

# We provide the modelling inputs and, in this case without absences, we define
# a strategy for selecting pseudo-absences based on a buffer around presences.
# we use the same buffer as before (script 02).
vaData <- BIOMOD_FormatingData(resp.var = rep(1, n_va),
                               expl.var = vars,
                               resp.xy = coords_va,
                               resp.name = "Vaspis",
                               dir.name = "models",
                               PA.nb.rep = 3,
                               PA.nb.absences = 10000,
                               PA.strategy = "disk",
                               PA.dist.max = 110000)

# Here we define the model algorithms to run and the train/test strategy. This
# allows to control overfitting by providing example to train the model and a 
# set of examples independent of the model to test its predictive ability.
# We choose K-fold cross validation to select. In this case, we divide the 
# dataset in 5 equal size folds and test 4 against 1, for each fold.
# We also define evaluation metrics (TSS e ROC) to evaluate model performance.
vaModel <- BIOMOD_Modeling(bm.format = vaData,
                           modeling.id = "EcoMod",
                           models = c("GAM", "GLM", "MAXNET", "XGBOOST"),
                           CV.strategy = "kfold",
                           CV.k = 5,
                           CV.do.full.models = FALSE,
                           OPT.strategy = "bigboss",
                           var.import = 3,
                           metric.eval = c("TSS", "ROC"))

# Plotting examples (Note: we are assigning the results of the functions to a 
# 'plt' object that gets replaced at every plot. The plot provides the data that
# generates it we are not using it here. By assigning we just avoid printing 
# much information in the console)
plt <- bm_PlotEvalMean(vaModel, dataset="calibration")
plt <- bm_PlotEvalMean(vaModel, dataset="validation")
plt <- bm_PlotEvalBoxplot(vaModel, group.by = c('algo', 'run'))
plt <- bm_PlotVarImpBoxplot(vaModel, group.by = c('expl.var', 'run', 'algo'))

# There are a lot of response curves. We will simplify in the ensembling script.
plt <- bm_PlotResponseCurves(vaModel, fixed.var = 'median')


# The models are built in the environmental space. We have to project the models
# to our initial variables to have the predictions over geographical space.
vaProj <- BIOMOD_Projection(bm.mod = vaModel,
                            proj.name = 'Present',
                            new.env = vars,
                            models.chosen = 'all')

# plot(vaProj) # Takes too much time as there are many models (PA*Run) to show
# However all models are built and saved into a file to check in a GIS:
# models/Vaspis/proj_Present/proj_Present_Vaspis.tif


# Repeat for the other species

## Vipera latastei 
n_vl <- sum(pres$species == "Vlatastei")
coords_vl <- pres[pres$species == "Vlatastei", 2:3]

vlData <- BIOMOD_FormatingData(resp.var = rep(1, n_vl),
                               expl.var = vars,
                               resp.xy = coords_vl,
                               resp.name = "Vlatastei",
                               dir.name = "models",
                               PA.nb.rep = 3,
                               PA.nb.absences = 10000,
                               PA.strategy = "disk",
                               PA.dist.max = 110000)

vlModel <- BIOMOD_Modeling(bm.format = vlData,
                           modeling.id = "EcoMod",
                           models = c("GAM", "GLM", "MAXNET", "XGBOOST"),
                           CV.strategy = "kfold",
                           CV.k = 5,
                           CV.do.full.models = FALSE,
                           OPT.strategy = "bigboss",
                           var.import = 3,
                           metric.eval = c("TSS", "ROC"))
# Plotting examples
plt <- bm_PlotEvalMean(vlModel, dataset="calibration")
plt <- bm_PlotEvalMean(vlModel, dataset="validation")
plt <- bm_PlotEvalBoxplot(vlModel, group.by = c('algo', 'run'))
plt <- bm_PlotVarImpBoxplot(vlModel, group.by = c('expl.var', 'run', 'algo'))
plt <- bm_PlotResponseCurves(vlModel, fixed.var = 'median')

vlProj <- BIOMOD_Projection(bm.mod = vlModel,
                            proj.name = 'Present',
                            new.env = vars,
                            models.chosen = 'all')


## Vipera seoanei
n_vs <- sum(pres$species == "Vseoanei")
coords_vs <- pres[pres$species == "Vseoanei", 2:3]

vsData <- BIOMOD_FormatingData(resp.var = rep(1, n_vs),
                               expl.var = vars,
                               resp.xy = coords_vs,
                               resp.name = "Vseoanei",
                               dir.name = "models",
                               PA.nb.rep = 3,
                               PA.nb.absences = 10000,
                               PA.strategy = "disk",
                               PA.dist.max = 110000)

vsModel <- BIOMOD_Modeling(bm.format = vsData,
                           modeling.id = "EcoMod",
                           models = c("GAM", "GLM", "MAXNET", "XGBOOST"),
                           CV.strategy = "kfold",
                           CV.k = 5,
                           CV.do.full.models = FALSE,
                           OPT.strategy = "bigboss",
                           var.import = 3,
                           metric.eval = c("TSS", "ROC"))
# Plotting examples
plt <- bm_PlotEvalMean(vsModel, dataset="calibration")
plt <- bm_PlotEvalMean(vsModel, dataset="validation")
plt <- bm_PlotEvalBoxplot(vsModel, group.by = c('algo', 'run'))
plt <- bm_PlotVarImpBoxplot(vsModel, group.by = c('expl.var', 'run', 'algo'))
plt <- bm_PlotResponseCurves(vsModel, fixed.var = 'median')

vlProj <- BIOMOD_Projection(bm.mod = vsModel,
                            proj.name = 'Present',
                            new.env = vars,
                            models.chosen = 'all')

