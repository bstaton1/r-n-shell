###################################################################################################
##### PROGRAM TO SIMULATION-TEST REGRESSION-BASED SRA ESTIMATION METHODS FOR MIXED-STOCK CASES ####
###################################################################################################

# this program is intended to be ran many times on separate computers, possibly a HPC
# each time it is ran, it should use a different seed, provided through command line or manually here
# it runs one and only one iteration which is one run of:

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

# or do it manually
# seed = 1

# set the random seed

if (is.na(seed)) {
  seed = as.numeric(Sys.time())
  seed = as.numeric(substr(as.character(seed), nchar(seed) - 3, nchar(seed)))
  warning("object 'seed' not passed via command line. Using as.numeric(Sys.time()")
} 
set.seed(seed)     

# options
write = T        # write output folders and files?
P = T            # run JAGS in parallel? 
verbose = T      # print progress messages (which step: fitting vs. processing)?
jags_verbose = F # print progress messages from JAGS?
time_verbose = T # print progress messages from the time on each step?
mcmc_plots = F   # create mcmc diag plots?

# models to fit
do_lme = T
do_tsm1 = T
do_tsm2 = T
do_tsm3 = T
do_tsm4 = T

# random sleeping ranges: in seconds
minS = 15
maxS = 200
# maxS = 30

# mcmc dimensions
# lme_dims = c(ni = 500, nb = 100, nt = 1, nc = 2, na = 100)
# tsm_1_dims = c(ni = 50, nb = 10, nt = 1, nc = 3, na = 10)
# tsm_2_dims = c(ni = 50, nb = 10, nt = 1, nc = 3, na = 10)
# tsm_3_dims = c(ni = 50, nb = 10, nt = 1, nc = 3, na = 10)
# tsm_4_dims = c(ni = 50, nb = 10, nt = 1, nc = 3, na = 10)
lme_dims = c(ni = 50000, nb = 50000, nt = 35, nc = 8, na = 1000)
tsm_1_dims = c(ni = 300000, nb = 20000, nt = 140, nc = 8, na = 1000)
tsm_2_dims = c(ni = 300000, nb = 20000, nt = 140, nc = 8, na = 1000)
tsm_3_dims = c(ni = 300000, nb = 20000, nt = 140, nc = 8, na = 1000)
tsm_4_dims = c(ni = 300000, nb = 20000, nt = 140, nc = 8, na = 1000)

# output directories
out_folder = "Output"

# packages
library(coda)
library(mvtnorm)
library(R2OpenBUGS)
suppressWarnings(suppressMessages(library(jagsUI, warn.conflicts = F)))
library(scales)

# READ IN FUNCTIONS FOR THIS ANALYSIS
func_dir = "Functions"; funcs = dir(func_dir)
for (i in 1:length(funcs)) source(paste(func_dir, funcs[i], sep = "/"))

# READ IN SAMPLES OF LEADING PARAMETERS
samps = read.csv("Umsy_Smsy_Kusko_posteriors.csv")
Umsy_post = samps[,substr(colnames(samps), 1, 4) == "Umsy"]
Smsy_post = samps[,substr(colnames(samps), 1, 4) == "Smsy"]

# OUTPUT DIRECTORY
out_dir = paste(getwd(), out_folder, sep = "/")

# create the output folder if it does not exist already
if(!dir.exists(out_dir) & write) dir.create(out_dir)

##### SIMULATE #####
if (verbose) cat("---------------------------------------------------\n")

start = Sys.time()
if (verbose) cat("  Generating Parameters, States, and Data\n")

# step 1: generate random parameters
params = gen_params(random = F)

# step 2: generate true states
pop_out = pop_sim(params = params)

# step 3a: generate observed calendar year states if sampled every year
obs_out = obs_sim(params = params, true = pop_out)

# step 3b: impose a sampling frequency scheme
obs_out = obs_filter(params = params, obs = obs_out)

# step 3c: obtain observed brood year states
obs_out = gen_Rys_obs(params, obs_out)

# step 4: obtain summaries and save output
params_summ = params_summary(params = params, seed = seed)
if (write) write.csv(params_summ, paste(out_dir, fileName("param_summary", seed, ".csv"), sep = "/"), row.names = F)
ctime = end_timer(start, ctime = 0)

# if fitting the lme model
if (do_lme) {
  # step 5a: fit the lme/lm models
  random_sleep(seed + 1, minS = minS, maxS = maxS)
  start = Sys.time()
  lme_post = fit_lme_model(params = params, obs = obs_out,
                           dims = lme_dims, parallel = P,
                           verbose = verbose, jags_verbose = jags_verbose)
  
  # step 5b: summarize and export the estimates from the lme/lm models
  start = Sys.time()
  lme_summ = lme_summary(post = lme_post, seed = seed, max_p_overfished = params$max_p_overfished, verbose = verbose, diag_plots = mcmc_plots)
  if (write) write.csv(lme_summ, paste(out_dir, fileName("lme_summary", seed, ".csv"), sep = "/"), row.names = F)
  ctime = end_timer(start, ctime = ctime)
  if (verbose) cat("---------------------------------------------------\n")
}

# if fitting the tsm#1 model
if (do_tsm1) {
  # step 6a: fit the tsm1
  start = Sys.time()
  random_sleep(seed + 2, minS = minS, maxS = maxS)
  tsm_1_post = fit_tsm_1_model(
    params = params, obs = obs_out,
    inits = tsm_1_gen_inits(
      params = params, obs = obs_out,
      n_chains = tsm_1_dims["nc"]),
    dims = tsm_1_dims, parallel = P,
    verbose = verbose, jags_verbose = jags_verbose)
  ctime = end_timer(start, ctime = ctime)
  
  # step 6b: summarize and export the estimates from the tsm model
  start = Sys.time()
  tsm_1_summ = tsm_1_summary(post = tsm_1_post, seed = seed, params = params, verbose = verbose, diag_plots = mcmc_plots)
  if (write) write.csv(tsm_1_summ, paste(out_dir, fileName("tsm_1_summary", seed, ".csv"), sep = "/"), row.names = F)
  ctime = end_timer(start, ctime = ctime)
  if (verbose) cat("---------------------------------------------------\n")
}

# if fitting tsm2
if (do_tsm2) {
  # step 7a: fit the tsm #2 model
  random_sleep(seed + 3, minS = minS, maxS = maxS)
  start = Sys.time()
  tsm_2_post = fit_tsm_2_model(
    params = params, obs = obs_out,
    inits = tsm_1_gen_inits(
      params = params, obs = obs_out,
      n_chains = tsm_2_dims["nc"]),
    dims = tsm_2_dims, parallel = P,
    verbose = verbose, jags_verbose = jags_verbose)
  ctime = end_timer(start, ctime = ctime)
  
  # step7b: summarize and export the estimates from the tsm model
  start = Sys.time()
  tsm_2_summ = tsm_2_summary(post = tsm_2_post, seed = seed, params = params, verbose = verbose, diag_plots = mcmc_plots)
  if (write) write.csv(tsm_2_summ, paste(out_dir, fileName("tsm_2_summary", seed, ".csv"), sep = "/"), row.names = F)
  ctime = end_timer(start, ctime = ctime)
  if (verbose) cat("---------------------------------------------------\n")
}

# if fitting tsm3
if (do_tsm3) {
  # step 8a: fit the tsm #3 model
  random_sleep(seed + 4, minS = minS, maxS = maxS)
  start = Sys.time()
  tsm_3_post = fit_tsm_3_model(
    params = params, obs = obs_out,
    inits = tsm_1_gen_inits(
      params = params, obs = obs_out,
      n_chains = tsm_3_dims["nc"]),
    dims = tsm_3_dims, parallel = P,
    verbose = verbose, jags_verbose = jags_verbose)
  ctime = end_timer(start, ctime = ctime)
  
  # step8b: summarize and export the estimates from the tsm model
  start = Sys.time()
  tsm_3_summ = tsm_3_summary(post = tsm_3_post, seed = seed, params = params, verbose = verbose, diag_plots = mcmc_plots)
  if (write) write.csv(tsm_3_summ, paste(out_dir, fileName("tsm_3_summary", seed, ".csv"), sep = "/"), row.names = F)
  ctime = end_timer(start, ctime = ctime)
  if (verbose) cat("---------------------------------------------------\n")
}

# if fitting tsm4
if (do_tsm4) {
  # step 9a: fit the tsm #4 model
  random_sleep(seed + 5, minS = minS, maxS = maxS)
  start = Sys.time()
  tsm_4_post = fit_tsm_4_model(
    params = params, obs = obs_out,
    inits = tsm_1_gen_inits(
      params = params, obs = obs_out,
      n_chains = tsm_4_dims["nc"]),
    dims = tsm_4_dims, parallel = P,
    verbose = verbose, jags_verbose = jags_verbose)
  ctime = end_timer(start, ctime = ctime)
  
  # step9b: summarize and export the estimates from the tsm model
  start = Sys.time()
  tsm_4_summ = tsm_4_summary(post = tsm_4_post, seed = seed, params = params, verbose = verbose, diag_plots = mcmc_plots)
  if (write) write.csv(tsm_4_summ, paste(out_dir, fileName("tsm_4_summary", seed, ".csv"), sep = "/"), row.names = F)
  ctime = end_timer(start, ctime = ctime)
  if (verbose) cat("---------------------------------------------------\n")
}
