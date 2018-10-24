# script to summarize the BGR stats

# handle command line arguments: takes a single model
args = commandArgs(trailingOnly = T)
model = args[1]
if (is.na(model)) {
  stop("Must supply a model as a command line argument ('tsm1', 'tsm2', 'lm', or 'lme')")
}

# load in the function needed to do this
source("Functions/z9_bgr_summ_function.R")

if (model == "tsm1") {
  load("Output/tsm_1_summ")
  cat("\nTSM #1:")
  bgr_summ(summ = tsm_1_summ, vars = c("alpha", "beta", "U_msy", "S_msy", "U_MSY", "S_MSY", "U_obj", "S_obj"))
}

if (model == "tsm2") {
  load("Output/tsm_2_summ")
  cat("\nTSM #2:")
  bgr_summ(summ = tsm_2_summ, vars = c("alpha", "beta", "mean_rho", "mean_sigma_R", "U_msy", "S_msy", "U_MSY", "S_MSY", "U_obj", "S_obj"))
}

if (model == "lm") {
  load("Output/lme_summ")
  cat("\nLM:")
  bgr_summ(summ = subset(lme_summ, method == "lm"), vars = c("alpha", "beta", "U_msy", "S_msy", "U_MSY", "S_MSY", "U_obj", "S_obj"))
}


if (model == "lme") {
  load("Output/lme_summ")
  cat("\nLME:")
  bgr_summ(summ = subset(lme_summ, method == "lme"), vars = c("alpha", "beta", "U_msy", "S_msy", "U_MSY", "S_MSY", "U_obj", "S_obj"))
}

# 
# 
