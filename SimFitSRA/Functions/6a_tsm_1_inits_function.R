
tsm_1_gen_inits = function(params, obs, n_chains) {
  
  output = with(append(params, obs), {
    # fit a basic regression approach to get Umsy and Smsy
    lm_data = lme_data_prep(params = params, obs = obs)
    lm_alpha = NULL
    lm_beta = NULL
    for (s in 1:ns) {
      tmp_S = lm_data$S_obs[lm_data$stock == s]
      tmp_log_RPS = lm_data$obs_log_RPS_lm[lm_data$stock == s]
      tmp_fit = lm(tmp_log_RPS ~ tmp_S)
      
      lm_alpha = c(lm_alpha, unname(exp(coef(tmp_fit)[1])))
      lm_beta = c(lm_beta, unname(abs(coef(tmp_fit)[2])))
    }
    lm_alpha[lm_alpha <= 1] = 1.5
    lm_mgmt = get_lme_mgmt(alpha = lm_alpha, beta = lm_beta)
    
    # randomly perturb these n_chains times and store
    inits = list()
    for (i in 1:n_chains) {
      inits[[i]] = list(
        U_msy = sapply(lm_mgmt$U_msy, function(x) {
          y = implement_error(U_target = x, SUM = 100)
          ifelse (y < 0.1, 0.15, y)
        }),
          
        log_S_msy = log(rlnorm(ns, log(lm_mgmt$S_msy), 0.1)),
        log_R = apply(R_ys_obs, 2, function(x) { # loop over stocks
          mu = mean(x, na.rm = T)   # calculate mean when available
          x[is.na(x)] = mu    # fill in NA with the mean
          log(rlnorm(length(x), log(x), 0.2))  # perturb it
        })
      )
    }
    inits
  })
  
  return(output)
}

