# attach(params); attach(obs); attach(true)
# detach(params); detach(obs); detach(true)

fit_tsm_2_model = function(params, obs,
                           dims = c(ni = 100, nb = 10, nt = 1, nc = 2, na = 1000),
                           inits = NULL, parallel = T, verbose = T, jags_verbose = F) {
  
  output = with(append(params, obs), {
    
    ### COMPILE DATA ###
    jags_dat = tsm_2_4_data_prep(params = params, obs = obs)
    
    ### NODES TO MONITOR ###
    jags_params = c("alpha", "beta", "U_msy", "S_msy", "U",
                    "sigma_R", "rho_mat", "phi", "pi")
    
    ### RUN THE SAMPLER: ###
    if (verbose) cat("  Running JAGS: TSM Model #2 (", 
                     ifelse(parallel, "Parallel", "Not Parallel"), ")\n", sep = "")
    post = tryCatch({
      # capture.output(
      # invisible(
      jags.basic(data = jags_dat,
                 inits = inits,
                 parameters.to.save = jags_params,
                 model.file = "Model Files/tsm_model_2.txt",
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
