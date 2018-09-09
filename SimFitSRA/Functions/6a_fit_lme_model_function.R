# attach(params); attach(obs); attach(true)
# detach(params); detach(obs); detach(true)

fit_lme_model = function(params, true, obs,
                         dims = c(ni = 5000, nb = 1000, nt = 2, nc = 2, na = 1000),
                         inits = NULL, parallel = T, verbose = T, jags_verbose = F) {
  
  output = with(append(append(params, true), obs), {
    
    ### COMPILE DATA ###
    jags_dat = lme_data_prep(params = params, obs = obs)
    
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
                     model.file = "Model Files/lme_model.txt",
                     n.chains = dims["nc"],
                     n.adapt = dims["na"],
                     n.iter = sum(dims[c("ni", "nb")]),
                     n.burnin = dims["nb"],
                     n.thin = dims["nt"],
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
