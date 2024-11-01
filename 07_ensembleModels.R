# Ecological Niche Modelling
# Ensemble built models 
# Author: Pedro Tarroso 2024

# Set working directory to easily find files
#setwd("Your/Directory/Path/")

# For this class we need the previously built models (scrip 06)

# The terra library provides necessary functionality to process spatial (raster
# and vectorial) data in R and biomod2 library provides functions for model 
# building with pseudo-absence selections, ensembling and projecting methods.
library(terra)
library(biomod2)

# load the models for Vipera aspis
vaName <- load("models/Vaspis/Vaspis.EcoMod.models.out")
vaModel <- eval(str2lang(vaName))


# Ensemble
vaEnsbl <- BIOMOD_EnsembleModeling(bm.mod = vaModel,
                                   models.chosen = 'all',
                                   em.by = 'all',
                                   em.algo = 'EMmedian',
                                   metric.eval =  c('TSS', 'ROC'),
                                   var.import = 3)


# Plotting examples
plt <- bm_PlotEvalBoxplot(vaEnsbl, group.by = c('algo', 'algo'))
plt <- bm_PlotVarImpBoxplot(vaEnsbl, group.by = c('expl.var', 'algo', 'algo'))
plt <- bm_PlotResponseCurves(vaEnsbl, fixed.var = 'median')

################################################################################
# load the models for Vipera latastei
vlName <- load("models/Vlatastei/Vlatastei.EcoMod.models.out")
vlModel <- eval(str2lang(vlName))


# Ensemble
vlEnsbl <- BIOMOD_EnsembleModeling(bm.mod = vlModel,
                                   models.chosen = 'all',
                                   em.by = 'all',
                                   em.algo = 'EMmedian',
                                   metric.eval = c('TSS', 'ROC'),
                                   var.import = 3)


# Plotting examples
plt <- bm_PlotEvalBoxplot(vlEnsbl, group.by = c('algo', 'algo'))
plt <- bm_PlotVarImpBoxplot(vlEnsbl, group.by = c('expl.var', 'algo', 'algo'))
plt <- bm_PlotResponseCurves(vlEnsbl, fixed.var = 'median')

################################################################################
# load the models for Vipera seoanei
vsName <- load("models/Vseoanei/Vseoanei.EcoMod.models.out")
vsModel <- eval(str2lang(vsName))


# Ensemble
vsEnsbl <- BIOMOD_EnsembleModeling(bm.mod = vsModel,
                                   models.chosen = 'all',
                                   em.by = 'all',
                                   em.algo = 'EMmedian',
                                   metric.eval =  c('TSS', 'ROC'),
                                   var.import = 3)


# Plotting examples
plt <- bm_PlotEvalBoxplot(vsEnsbl, group.by = c('algo', 'algo'))
plt <- bm_PlotVarImpBoxplot(vsEnsbl, group.by = c('expl.var', 'algo', 'algo'))
plt <- bm_PlotResponseCurves(vsEnsbl, fixed.var = 'median')

