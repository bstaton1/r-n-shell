# load packages. Should really be using pkg::fun
suppressWarnings(suppressMessages(library(coda, warn.conflicts = F)))
suppressWarnings(suppressMessages(library(R2OpenBUGS, warn.conflicts = F)))
suppressWarnings(suppressMessages(library(jagsUI, warn.conflicts = F)))
suppressWarnings(suppressMessages(library(reshape2, warn.conflicts = F)))

# clear the workspace
rm(list = ls(all = T))

args = commandArgs(trailingOnly = T)
model = as.numeric(args[1])      # model
# model = 3 # or set it manually

# create the output directory if it doesn't already exist
if(!dir.exists("2-outputs")) dir.create("2-outputs")

# load in functions from this repository
  # pretty much all copy and pasted from r-n-shell/SimFitSRA
  # this is a really bad way to handle this, because they can get out of sync
  # try to think of a way around this: some package that could work for both?
  # one package for simulating and one for fitting/post processing?

funcs = dir("0-functions")
x = sapply(funcs, function(x) source(file.path("0-functions", x))); rm(funcs)

# location of raw data files
# these are in this same git repo
# S_H_dir = "../1-data-prep/1-state-reconstructions/outputs/"
# age_dir = "../1-data-prep/2-age-comps/outputs/"
S_H_dir = "1-inputs"
age_dir = "1-inputs"

# prepare the kuskokwim data files
kusko_inputs = format_kusko_inputs(
  S_dat = read.csv(
    stringsAsFactors = F, 
    file = file.path(S_H_dir, "S_Ests_Oct_18.csv")
  ),
  
  H_dat = read.csv(
    stringsAsFactors = F, 
    file = file.path(S_H_dir, "H_Ests_Oct_18.csv")
  ),
  
  age_dat = read.csv(
    stringsAsFactors = F,
    file = file.path(age_dir, "Age_Comp_Data.csv")
  )
)

# separate them into observed and params (params are pretty much all dimensions)
kusko_obs = kusko_inputs$obs
kusko_params = kusko_inputs$params
kusko_params = append(kusko_params, list(max_p_overfished = 0.3))

# create broodtables and get brood year recruitment by stock
kusko_obs = gen_Rys_obs(params = kusko_params, obs = kusko_obs)

# tsm features by model
maturity = c("simple", "simple", "complex", "complex")
covariance = c("simple", "complex", "simple", "complex")


# prepare data depending on the model: only difference is the variance structure info needed
if (covariance[model] == "simple") {
  jags_dat = tsm_1_3_data_prep(kusko_params, kusko_obs)
} else {
  jags_dat = tsm_2_4_data_prep(kusko_params, kusko_obs)
}

# create filenames for the the output
summ_file = paste(paste("tsm", model, "summ", sep = "_"), ".rds", sep = "")
post_file = paste(paste("tsm", model, "post", sep = "_"), ".rds", sep = "")

# parameters to monitor
base_jags_params = c("alpha", "beta", "U_msy", "S_msy", "U",
                     "sigma_R", "rho_mat", "phi", "pi", "S",
                     "R", "log_resid", "Sigma_R")
mod_3_4_params = c("p", "D_sum") # extra params to monitor for complex maturity model

if (maturity[model] == "simple") {
  jags_params = base_jags_params
} else {
  jags_params = c(base_jags_params, mod_3_4_params)
}

# create the mcmc dimensions
# dims = c(
#   ni = 500000,
#   nb = 50000,
#   nt = 200,
#   nc = 8,
#   na = 1000
# )

# with(as.list(dims), nc * ni/nt)

dims = c(
  ni = 30,
  nb = 20,
  nt = 1,
  nc = 3,
  na = 10
)

# generate initial values: general for all models not just 1
jags_inits = tsm_1_gen_inits(kusko_params, kusko_obs, n_chains = dims["nc"])

cat("|**----------**| Running Model #", model, " |**----------**|", "\n", sep = "")

start = Sys.time()
# run the sampler
post = jags.basic(
  data = jags_dat,
  inits = jags_inits,
  parameters.to.save = jags_params,
  model.file = paste("1-inputs/Model Files/tsm_model_", model, ".txt", sep = ""),
  n.chains = dims["nc"],
  n.adapt = dims["na"],
  n.iter = sum(dims[c("ni", "nb")]),
  n.burnin = dims["nb"],
  n.thin = dims["nt"],
  parallel = F,
  verbose = F,
  save.model = F
)

# summarize the key output parameters
summ = tsm_summary(post = post, model = model, params = kusko_params, diag_plots = T)

stop = Sys.time()

# save the output
saveRDS(post, file = file.path("2-outputs", post_file))
saveRDS(summ, file = file.path("2-outputs", summ_file))

stop - start