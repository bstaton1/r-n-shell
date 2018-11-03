
# post-processing/plotting script

# load files
load("Output/lme_summ")
load("Output/param_summ")
load("Output/tsm_1_summ")
load("Output/tsm_2_summ")
load("Output/tsm_3_summ")
load("Output/tsm_4_summ")

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

# extract tsm 2 estimates of reference points
tsm_2_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(tsm_2_summ, (param == x) | (is.na(param)))[,"X50."])
tsm_2_ests = cbind(seed = unique(tsm_2_summ$seed), tsm_2_ests)

# extract tsm 3 estimates of reference points
tsm_3_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(tsm_3_summ, (param == x) | (is.na(param)))[,"X50."])
tsm_3_ests = cbind(seed = unique(tsm_3_summ$seed), tsm_3_ests)

# extract tsm 4 estimates of reference points
tsm_4_ests = sapply(c("U_MSY", "S_MSY", "U_obj", "S_obj"),
                  function(x) subset(tsm_4_summ, (param == x) | (is.na(param)))[,"X50."])
tsm_4_ests = cbind(seed = unique(tsm_4_summ$seed), tsm_4_ests)

# calculate bias
lm_bias = (lm_ests - true)/true
lme_bias = (lme_ests - true)/true
tsm_1_bias = (tsm_1_ests - true)/true
tsm_2_bias = (tsm_2_ests - true)/true
tsm_3_bias = (tsm_3_ests - true)/true
tsm_4_bias = (tsm_4_ests - true)/true

n_lm = nrow(na.omit(lm_bias))
n_lme = nrow(na.omit(lm_bias))
n_tsm1 = nrow(na.omit(tsm_1_bias))
n_tsm2 = nrow(na.omit(tsm_2_bias))
n_tsm3 = nrow(na.omit(tsm_3_bias))
n_tsm4 = nrow(na.omit(tsm_4_bias))

# Make plots
pdf("Output/Plots.pdf", h = 5, w = 5)

par(mar = c(0.2, 0.2, 0.2, 0.2), ljoin = "mitre", lend = 2)
plot(1,1, type = "n", axes = F, ann = F, xlim = c(0,1), ylim = c(0,1))
text(x = 0.00, y = 0.90, "LM = Independent regression models for each substock", pos = 4, cex = 0.8)
text(x = 0.00, y = 0.85, "LME = Mixed-effect regression model", pos = 4, cex = 0.8)
text(x = 0.00, y = 0.65, "TSM-ms = simple maturity, simple covariance SSM", pos = 4, cex = 0.8)
text(x = 0.00, y = 0.60, "TSM-mS = simple maturity, complex covariance SSM", pos = 4, cex = 0.8)
text(x = 0.00, y = 0.55, "TSM-Ms = complex maturity, simple covariance SSM", pos = 4, cex = 0.8)
text(x = 0.00, y = 0.50, "TSM-MS = complex maturity, complex covariance SSM", pos = 4, cex = 0.8)
box(lwd = 3)

par(mar = c(5,4,4,1))
p = c("U_MSY", "S_MSY", "U_obj", "S_obj")
for (i in 1:length(p)) {
  boxplot(cbind("LM" = lm_bias[,p[i]],
                "LME" = lme_bias[,p[i]],
                "TSM-ms" = tsm_1_bias[,p[i]],
                "TSM-mS" = tsm_2_bias[,p[i]],
                "TSM-Ms" = tsm_3_bias[,p[i]],
                "TSM-MS" = tsm_4_bias[,p[i]]
  ),
  col = "skyblue", las = 3,
  main = p[i])
  abline(h = 0, lty = 2, lwd = 3, col = "red")
  usr = par("usr"); ydiff = diff(usr[3:4])
  text(x = 0:6, y = usr[4] + ydiff * 0.05, 
       c("n = ", n_lm, n_lme, n_tsm1, n_tsm2, n_tsm3, n_tsm4), font = 4,
       xpd = T)
  
}

multi_biplot = function(x_vars, y_vars, x_name, y_name) {
  sapply(p, function(z) {
    biplot(x = x_vars[,z], y = y_vars[,z],
           xlab = x_name, ylab = y_name, new_window = F, main = z)
  })
}

# multi_biplot(x_vars = lm_bias, y_vars = lme_bias, x_name = "LM", y_name = "LME")
multi_biplot(x_vars = lm_bias, y_vars = tsm_4_bias, x_name = "LM", y_name = "TSM-MS")
multi_biplot(x_vars = tsm_3_bias, y_vars = tsm_4_bias, x_name = "TSM-Ms", y_name = "TSM-MS")
# multi_biplot(x_vars = tsm_2_bias, y_vars = lme_bias, x_name = "TSM-m-S", y_name = "LME")
# multi_biplot(x_vars = tsm_3_bias, y_vars = tsm_4_bias, x_name = "TSM-M-s", y_name = "TSM-M-S")
junk = dev.off(); rm(junk)
