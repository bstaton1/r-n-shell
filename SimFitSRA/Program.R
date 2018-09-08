###################################################################################################
##### PROGRAM TO SIMULATION-TEST REGRESSION-BASED SRA ESTIMATION METHODS FOR MIXED-STOCK CASES ####
###################################################################################################

# this program is intended to be ran many times on separate computers, possibly a HPC
# each time it is ran, it should use a different seed, provided through command line or manually here
# it has the option to run more than one simulation

# its main purpose is to call the functions in the analysis to:
  # (1): generate true parameters of the salmon populations
  # (2): simulate the populations for some number of years using true dynamics
  # (3): simulate observing the populations under a given sampling regime
  # (4): fit assessment model(s)
  # (5): extract the results from the fitted model object
  # (6): write the output to a new folder

# CLEAR THE WORKSPACE
rm(list = ls(all = T))

# handle command line arguments
args = commandArgs(trailingOnly = T)
seed = as.numeric(args[1])      # seed for this batch
nsim = as.numeric(args[2])      # number of random data sets ran for this batch

# or do it manually
# seed = 1
# nsim = 2

# set the random seed
set.seed(seed)     

# options
write = T        # write output folders and files?
P = T            # run JAGS in parallel? 
verbose = T      # print progress messages (which step: fitting vs. processing)?
jags_verbose = F # print progress messages from JAGS?

# output directories
out_main_folder = "Output"
out_sub_folder = paste("Out", seed, sep = "")

# LOAD PACKAGES
.libPaths("C:/~/R/win-library/3.5")  # where are they?

library(coda)
library(mvtnorm)
library(R2OpenBUGS)
suppressWarnings(suppressMessages(library(jagsUI, warn.conflicts = F)))
library(scales)

# READ IN FUNCTIONS FOR THIS ANALYSIS
func_dir = paste(getwd(), "Functions", sep = "/")
funcs = dir(func_dir)
for (i in 1:length(funcs)) source(paste(func_dir, funcs[i], sep = "/"))

# READ IN SAMPLES OF LEADING PARAMETERS
samps = read.csv("Umsy_Smsy_Kusko_posteriors.csv")
Umsy_post = samps[,substr(colnames(samps), 1, 4) == "Umsy"]
Smsy_post = samps[,substr(colnames(samps), 1, 4) == "Smsy"]

# OUTPUT DIRECTORY
out_dir = paste(getwd(), out_main_folder, out_sub_folder, sep = "/")

# create the main folder if it does not exist
if(!dir.exists(paste(getwd(), out_main_folder, sep = "/")) & write) dir.create(paste(getwd(), out_main_folder, sep = "/"))

# create the sub folder if it does not exist
if(!dir.exists(out_dir) & write) dir.create(out_dir)

##### SIMULATE #####

# start a timer
starttime = Sys.time()

# containers
params_summ = NULL
lme_summ = NULL
for (i in 1:nsim) {
  if (verbose) {
    cat("Simulation #", i, "\n", sep = "")
  } else {
    cat("\r", "Simulation #", i, sep = "")
  }

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
  lme_post = fit_lme_model(params = params, true = pop_out, obs = obs_out, parallel = P, verbose = verbose, jags_verbose = jags_verbose)
  
  # step 4b: fit the tsm model
  # put here when complete

  # step 5: obtain summaries and save output
  params_summ = rbind(params_summ, params_summary(params = params, i = i))
  lme_summ = rbind(lme_summ, lme_summary(post = lme_post, i = i, max_p_overfished = params$max_p_overfished, verbose = verbose, p_samp = 0.5))
  
  if (verbose) cat("--------------------------------\n")
}
# end the timer
if (!verbose) cat("\n")
Sys.time() - starttime

# save output
if (write) write.csv(params_summ, paste(out_dir, "param_summary.csv", sep = "/"), row.names = F)
if (write) write.csv(lme_summ, paste(out_dir, "lme_summary.csv", sep = "/"), row.names = F)
