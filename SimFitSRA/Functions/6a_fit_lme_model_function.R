# attach(params); attach(obs); attach(true)
# detach(params); detach(obs); detach(true)

fit_lme_model = function(params, true, obs, parallel = T, verbose = T, jags_verbose = F) {
  
  output = with(append(append(params, true), obs), {
    
    ### COMPILE DATA ###
    jags_dat = lme_data_prep(params = params, obs = obs)
    
    ### MCMC DIMENSIONS ###
    ni = 5000
    nb = 1000
    n_thin = 2
    n_chains = 3
    # ni/n_thin * n_chains
    n_iter = ni + nb
    
    ### NODES TO MONITOR ###
    jags_params = c("alpha_lme", "alpha_lm", "beta_lme", "beta_lm")
    
    ### RUN THE SAMPLER: ###
    if (verbose) cat("  Running JAGS: LME Model (", 
                     ifelse(parallel, "Parallel", "Not Parallel"), ")\n", sep = "")
    post = tryCatch({
      # capture.output(
        # invisible(
         jags.basic(data = jags_dat,
                     inits = NULL,
                     parameters.to.save = jags_params,
                     model.file = "lme_model.txt",
                     n.chains = n_chains,
                     n.adapt = 1000,
                     n.iter = n_iter,
                     n.burnin = nb,
                     n.thin = n_thin,
                     parallel = parallel,
                     verbose = jags_verbose, save.model = F)
        # ),
        # file = "JAGS_messages.txt", append = T
      # )
    }, error = function(e) NULL)
    
    post
  })
  
  # return the output
  return(output)
}
