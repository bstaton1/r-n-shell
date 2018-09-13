# script to summarize the BGR stats

load("Output/tsm_summ")
load("Output/lme_summ")

source("Functions/z9_bgr_summ_function.R")

cat("TSM #1:\n")
bgr_summ(summ = tsm_summ, vars = c("alpha", "beta", "U_msy", "S_msy"))

cat("\nLM:\n")
bgr_summ(summ = subset(lme_summ, method == "lm"), vars = c("alpha", "beta"))

cat("LME:\n")
bgr_summ(summ = subset(lme_summ, method == "lme"), vars = c("alpha", "beta"))


