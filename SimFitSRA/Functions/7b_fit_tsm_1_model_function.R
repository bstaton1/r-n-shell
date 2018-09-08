# attach(params); attach(obs); attach(true)
# detach(params); detach(obs); detach(true)

fit_tsm_1_model = function(params, true, obs, parallel = T, verbose = T, jags_verbose = F) {
  
  output = with(append(append(params, true), obs), {
    
    ### COMPILE DATA ###
    jags_dat = tsm_1_data_prep(params = params, obs = obs)
    
    ### MCMC DIMENSIONS ###
    ni = 10
    nb = 10
    n_thin = 1
    n_chains = 3
    # ni/n_thin * n_chains
    n_iter = ni + nb
    
    ### NODES TO MONITOR ###
    jags_params = c("alpha", "beta", "U_msy", "S_msy", 
                    "sigma_R[1]", "rho_mat[2,1]", "phi", "pi")
    
    ### INITIAL VALUES ###
    jags_inits = tsm_1_gen_inits(params, obs, n_chains)
    
    ### RUN THE SAMPLER: ###
    if (verbose) cat("  Running JAGS: TSM Model #1 (", 
                     ifelse(parallel, "Parallel", "Not Parallel"), ")\n", sep = "")
    post = tryCatch({
      # capture.output(
        # invisible(
      jags.basic(data = jags_dat,
                 inits = jags_inits,
                 parameters.to.save = jags_params,
                 model.file = "tsm_model_1.txt",
                 n.chains = n_chains,
                 n.adapt = 1000,
                 n.iter = n_iter,
                 n.burnin = nb,
                 n.thin = n_thin,
                 parallel = parallel,
                 verbose = jags_verbose,
                 save.model = F)
        # ),
        # file = "JAGS_messages.txt", append = T
      # )
    }, error = function(e) NULL)
    
    post
  })
  
  # return the output
  return(output)
}
