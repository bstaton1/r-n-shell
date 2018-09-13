# script to summarize the BGR stats

load("Output/tsm_summ")
load("Output/lme_summ")

source("Functions/z10_ess_summ_function.R")

cat("\nTSM #1:")
ess_summ(summ = tsm_summ, vars = c("alpha", "beta", "U_msy", "S_msy", "U_MSY", "S_MSY", "U_obj", "S_obj"))

cat("\nLM:")
ess_summ(summ = subset(lme_summ, method == "lm"), vars = c("alpha", "beta", "U_msy", "S_msy", "U_MSY", "S_MSY", "U_obj", "S_obj"))

cat("\nLME:")
ess_summ(summ = subset(lme_summ, method == "lme"), vars = c("alpha", "beta", "U_msy", "S_msy", "U_MSY", "S_MSY", "U_obj", "S_obj"))


