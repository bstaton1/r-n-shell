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
set.seed(seed)     

# options
write = T        # write output folders and files?
P = T            # run JAGS in parallel? 
verbose = T      # print progress messages (which step: fitting vs. processing)?
jags_verbose = F # print progress messages from JAGS?
time_verbose = T # print progress messages from the time on each step?
lme_p_samp = 0.5 # proportion of MCMC samples used in dw brp calcs for lme model
tsm_p_samp = 1   # proportion of MCMC samples used in dw brp calcs for tsm model

# mcmc dimensions
lme_dims = c(ni = 10000, nb = 2000, nt = 2, nc = 2, na = 1000)
tsm_dims = c(ni = 100000, nb = 1000, nt = 30, nc = 3, na = 1000)

# output directories
out_folder = "Output"

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
out_dir = paste(getwd(), out_folder, sep = "/")

# create the output folder if it does not exist already
if(!dir.exists(out_dir) & write) dir.create(out_dir)

##### SIMULATE #####
if (verbose) cat("---------------------------------------------------\n")

start = Sys.time()
if (verbose) cat("  Generating Parameters, States, and Data\n")

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
end = Sys.time(); time_initial = round(as.numeric(end - start, units = "hours"), 2)
if (time_verbose) cat("    Hours Elapsed: ", time_initial, "; Total Hours Elapsed: ", time_initial, "\n", sep = "")

# step 4a: fit the lme/lm models
start = Sys.time()
lme_post = fit_lme_model(params = params, true = pop_out, obs = obs_out,
                         dims = lme_dims, parallel = P,
                         verbose = verbose, jags_verbose = jags_verbose)
# step 4b: summarize the lme/lm models
lme_summ = lme_summary(p_samp = lme_p_samp, post = lme_post, seed = seed, max_p_overfished = params$max_p_overfished, verbose = verbose)
end = Sys.time(); time_lme = round(as.numeric(end - start, units = "hours"), 2)
if (time_verbose) cat("    Hours Elapsed: ", time_lme, "; Total Hours Elapsed: ", time_initial + time_lme, "\n", sep = "")


# step 5a: fit the tsm model
start = Sys.time()
tsm_inits = tsm_1_gen_inits(params = params, obs = obs_out, n_chains = tsm_dims["nc"])
tsm_post = fit_tsm_1_model(params = params, true = pop_out, obs = obs_out, inits = tsm_inits,
                           dims = tsm_dims, parallel = P,
                           verbose = verbose, jags_verbose = jags_verbose)

# step 5b: summarize the tsm model
tsm_summ = tsm_1_summary(p_samp = tsm_p_samp, post = tsm_post, seed = seed, max_p_overfished = params$max_p_overfished, verbose = verbose)
end = Sys.time(); time_tsm = round(as.numeric(end - start, units = "hours"), 2)
if (time_verbose) cat("    Hours Elapsed: ", time_tsm, "; Total Hours Elapsed: ", time_initial + time_lme + time_tsm, "\n", sep = "")

# step 6: obtain summaries and save output
params_summ = params_summary(params = params, seed = seed)

if (verbose) cat("---------------------------------------------------\n")

# save output
if (write) write.csv(params_summ, paste(out_dir, paste("param_summary_", seed, ".csv", sep = ""), sep = "/"), row.names = F)
if (write) write.csv(lme_summ, paste(out_dir, paste("lme_summary_", seed, ".csv", sep = ""), sep = "/"), row.names = F)
if (write) write.csv(tsm_summ, paste(out_dir, paste("tsm_summary_", seed, ".csv", sep = ""), sep = "/"), row.names = F)
