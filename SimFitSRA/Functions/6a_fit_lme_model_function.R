# attach(params); attach(obs); attach(true)
# detach(params); detach(obs); detach(true)

parallel = F
fit_lme_model = function(params, true, obs, parallel = T) {
  
  output = with(append(append(params, true), obs), {
    
    ### COMPILE DATA ###
    jags_dat = lme_data_prep(params = params, obs = obs)
    
    ### MCMC DIMENSIONS ###
    ni = 1000
    nb = 100
    n_thin = 1
    n_chains = 2
    # ni/n_thin * n_chains
    n_iter = ni + nb
    
    ### NODES TO MONITOR ###
    jags_params = c("alpha_lme", "alpha_lm", "beta_lme", "beta_lm")
    
    ### RUN THE SAMPLER: Parallel ###
    starttime = Sys.time()
    if (parallel) {
      ### GET DATA OBJECTS INTO LOCAL WORKSPACE ###
      
      for (i in 1:length(jags_dat)) {
        assign(x = names(jags_dat)[i], value = jags_dat[[i]])
      }
      
      ### COMBINE INITS AND DATA NAMES ###
      jags_data = append(
        as.list(names(jags_dat)), 
        list("ni", "nb", "n_thin", "n_chains", "n_iter")
      )
      
      cat("  Running JAGS: LME Model (Parallel)", "\n", sep = "")
      post = tryCatch({
        jags.parallel(data = jags_data,
                      inits = NULL,
                      parameters.to.save = jags_params,
                      n.thin = n_thin,
                      n.iter = n_iter,
                      model.file = "lme_model.txt",
                      n.burnin = nb,
                      n.chains = n_chains
        )
      }, error = function(e) NULL)
      if(!is.null(post)) post = as.mcmc(post)
    } else {
      ### RUN THE SAMPLER: NOT PARALLEL ###
      cat("  Running JAGS: LME Model (Not Parallel)", "\n", sep = "")
      post = tryCatch({
        invisible(capture.output(jmod <- jags.model(file = "lme_model.txt", data = jags_dat,
                                                   n.chains = n_chains, inits = NULL, n.adapt = 1000)))
        update(jmod, n.iter = nb, by = 1, progress.bar = 'none')
        post = coda.samples(jmod, jags_params, n.iter = ni, thin = nt, progress.bar = 'none')
      }, error = function(e) NULL)
    }
    
    Sys.time() - starttime
    
    post
  })
  
  # return the output
  return(output)
}
