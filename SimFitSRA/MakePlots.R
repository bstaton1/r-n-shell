
# post-processing/plotting script

# load files
load("Output/lme_summ")
load("Output/param_summ")
load("Output/tsm_summ")

# load in the specialized plotting function
.libPaths("C:/~/R/win-library/3.5")
library(scales)

source("Functions/z5_biplot_function.R")

# extract true reference points for each iteration
true = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
              function(x) subset(param_summ, param == x)$value)

# extract simple regression estimates of reference points
lm_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                 function(x) subset(lme_summ, (param == x & method == "lm") | (is.na(param) & method == "lm"))[,"X50."])

# extract mixed effect regression estimates of reference points
lme_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(lme_summ, (param == x & method == "lme") | (is.na(param) & method == "lm"))[,"X50."])

# extract mixed effect regression estimates of reference points
tsm_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(tsm_summ, (param == x) | (is.na(param)))[,"X50."])

# calculate bias
lm_bias = (lm_ests - true)/true
lme_bias = (lme_ests - true)/true
tsm_bias = (tsm_ests - true)/true

# Make plots
pdf("Output/Plots.pdf", h = 4.5, w = 4.5)
biplot(x = lm_bias[,"U_MSY"], y = lme_bias[,"U_MSY"], xlab = "LM (U_MSY)", ylab = "LME (U_MSY)", new_window = F)
biplot(x = lm_bias[,"S_MSY"], y = lme_bias[,"S_MSY"], xlab = "LM (S_MSY)", ylab = "LME (S_MSY)", new_window = F)
biplot(x = lm_bias[,"U_obj"], y = lme_bias[,"U_obj"], xlab = "LM (U_obj)", ylab = "LME (U_obj)", new_window = F)
biplot(x = lm_bias[,"S_obj"], y = lme_bias[,"S_obj"], xlab = "LM (S_obj)", ylab = "LME (S_obj)", new_window = F)

biplot(x = tsm_bias[,"U_MSY"], y = lme_bias[,"U_MSY"], xlab = "TSM (U_MSY)", ylab = "LME (U_MSY)", new_window = F)
biplot(x = tsm_bias[,"S_MSY"], y = lme_bias[,"S_MSY"], xlab = "TSM (S_MSY)", ylab = "LME (S_MSY)", new_window = F)
biplot(x = tsm_bias[,"U_obj"], y = lme_bias[,"U_obj"], xlab = "TSM (U_obj)", ylab = "LME (U_obj)", new_window = F)
biplot(x = tsm_bias[,"S_obj"], y = lme_bias[,"S_obj"], xlab = "TSM (S_obj)", ylab = "LME (S_obj)", new_window = F)

biplot(x = tsm_bias[,"U_MSY"], y = lm_bias[,"U_MSY"], xlab = "TSM (U_MSY)", ylab = "LM (U_MSY)", new_window = F)
biplot(x = tsm_bias[,"S_MSY"], y = lm_bias[,"S_MSY"], xlab = "TSM (S_MSY)", ylab = "LM (S_MSY)", new_window = F)
biplot(x = tsm_bias[,"U_obj"], y = lm_bias[,"U_obj"], xlab = "TSM (U_obj)", ylab = "LM (U_obj)", new_window = F)
biplot(x = tsm_bias[,"S_obj"], y = lm_bias[,"S_obj"], xlab = "TSM (S_obj)", ylab = "LM (S_obj)", new_window = F)

junk = dev.off(); rm(junk)

