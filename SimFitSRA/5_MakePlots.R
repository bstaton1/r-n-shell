
# post-processing/plotting script

.pardefault = par()

# load files
load("Output/lme_summ")
load("Output/param_summ")
load("Output/tsm_1_summ")
load("Output/tsm_2_summ")

# load in the specialized plotting function
#.libPaths("C:/~/R/win-library/3.5")
suppressWarnings(library(scales))

source("Functions/z5_biplot_function.R")

# extract true reference points for each iteration
true = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
              function(x) subset(param_summ, param == x | is.na(param))$value)
true = cbind(seed = unique(param_summ$seed), true)

# extract simple regression estimates of reference points
lm_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                 function(x) subset(lme_summ, (param == x & method == "lm") | (is.na(param) & method == "lm"))[,"X50."])
lm_ests = cbind(seed = unique(lme_summ$seed), lm_ests)

# extract mixed effect regression estimates of reference points
lme_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(lme_summ, (param == x & method == "lme") | (is.na(param) & method == "lm"))[,"X50."])
lme_ests = cbind(seed = unique(lme_summ$seed), lme_ests)

# extract tsm 1 estimates of reference points
tsm_1_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(tsm_1_summ, (param == x) | (is.na(param)))[,"X50."])
tsm_1_ests = cbind(seed = unique(tsm_1_summ$seed), tsm_1_ests)

# extract tsm 1 estimates of reference points
tsm_2_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(tsm_2_summ, (param == x) | (is.na(param)))[,"X50."])
tsm_2_ests = cbind(seed = unique(tsm_2_summ$seed), tsm_2_ests)

# calculate bias
lm_bias = (lm_ests - true)/true
lme_bias = (lme_ests - true)/true
tsm_1_bias = (tsm_1_ests - true)/true
tsm_2_bias = (tsm_2_ests - true)/true

# Make plots
pdf("Output/Plots.pdf", h = 5, w = 5)

p = c("U_MSY", "S_MSY", "U_obj", "S_obj")
for (i in 1:length(p)) {
  boxplot(cbind("LM" = lm_bias[,p[i]],
                "LME" = lme_bias[,p[i]],
                "TSM-sig" = tsm_1_bias[,p[i]],
                "TSM-SIG" = tsm_2_bias[,p[i]]
  ),
  col = "skyblue", 
  main = p[i])
  abline(h = 0, lty = 2, lwd = 3, col = "red")
}

mod1 = lm_bias; mod_1_name = "LM"
mod2 = tsm_2_bias; mod_2_name = "TSM-SIG"


multi_biplot = function(x_vars, y_vars, x_name, y_name) {
  sapply(p, function(z) {
    biplot(x = x_vars[,z], y = y_vars[,z],
           xlab = x_name, ylab = y_name, new_window = F, main = z)
  })
}

multi_biplot(x_vars = lm_bias, y_vars = lme_bias, x_name = "LM", y_name = "LME")
multi_biplot(x_vars = tsm_2_bias, y_vars = tsm_1_bias, x_name = "TSM-SIG", y_name = "TSM-sig")
multi_biplot(x_vars = tsm_2_bias, y_vars = lme_bias, x_name = "TSM-SIG", y_name = "LME")

junk = dev.off(); rm(junk)
