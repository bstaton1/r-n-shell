###################################################################################################
##### PROGRAM TO SIMULATION TEST REGRESSION-BASED SRA ESTIMATION METHODS FOR MIXED-STOCK CASES ####
###################################################################################################

# CLEAR THE WORKSPACE
rm(list = ls(all = T))

set.seed(4000)     # random seed

out_main_folder = "Output"
out_sub_folder = "Out1"
nsim = 1

# LOAD PACKAGES
library(mvtnorm)
library(R2OpenBUGS)
library(R2jags)
library(rjags)
library(scales)

# READ MY FUNCTIONS
# source("C:/Users/bas0041/Desktop/run_functions_source.R")

# READ IN FUNCTIONS FOR THIS ANALYSIS
func_dir = paste(getwd(), "Functions", sep = "/")
funcs = dir(func_dir)
for (i in 1:length(funcs)) source(paste(func_dir, funcs[i], sep = "/"))

samps = read.csv("Umsy_Smsy_Kusko_posteriors.csv")
Umsy_post = samps[,substr(colnames(samps), 1, 4) == "Umsy"]
Smsy_post = samps[,substr(colnames(samps), 1, 4) == "Smsy"]

# OUTPUT DIRECTORY
out_dir = paste(getwd(), out_main_folder, out_sub_folder, sep = "/")

# create the main folder if it does not exist
if(!dir.exists(paste(getwd(), out_main_folder, sep = "/"))) dir.create(paste(working_dir, out_main_folder, sep = "/"))

# create the sub folder if it does not exist
if(!dir.exists(out_dir)) dir.create(out_dir)

##### SIMULATE #####

# start a timer
starttime = Sys.time()

# containers
params_summ = NULL
lme_summ = NULL
for (i in 1:nsim) {
  cat("Simulation #", i, "\n", sep = "")

  # step 1: generate random parameters
  params = gen_params()

  # step 2: generate true states
  pop_out = pop_sim(params = params)

  # step 3a: generate observed calendar year states if sampled every year
  obs_out = obs_sim(params = params, true = pop_out)
  
  # step 3b: impose a sampling frequency scheme
  obs_out = obs_filter(params = params, obs = obs_out)
  
  # step 3c: obtain observed brood year states
  obs_out = gen_Rys_obs(params, obs_out)

  # step 4a: fit the lme/lm models
  lme_post = fit_lme_model(params = params, true = pop_out, obs = obs_out)
  
  # step 4b: fit the tsm model
  # put here when complete

  # step 5: obtain summaries and save output
  params_summ = rbind(params_summ, params_summary(params = params, i = i))
  lme_summ = rbind(lme_summ, lme_summary(post = lme_post, i = i, max_p_overfished = params$max_p_overfished))
  
  cat("--------------------------------\n")
}
# end the timer
Sys.time() - starttime

# save output
write.csv(params_summ, paste(out_dir, "param_summary.csv", sep = "/"), row.names = F)
write.csv(lme_summ, paste(out_dir, "lme_summary.csv", sep = "/"), row.names = F)
 

