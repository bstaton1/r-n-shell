
# attach(params); attach(obs)

obs_filter = function(params, obs) {
  
  output = with(append(params, obs), {
    
    ### ESCAPEMENT OBSERVATION FILTERING ###
    S_ts_obs_filtered = S_ts_obs
    NA_yrs = matrix(NA, nt, ns)
    # S_ts_obs_filtered = matrix(0, nt, ns)
    
    # proportion of substocks getting each sampling frequency
    p100 = 0.25
    p75 = 0.25
    p50 = 0.5
    
    # shuffle them across stocks
    sample_types = sample(c(rep(1, p100 * ns),rep(2, p75 * ns),rep(3, p50 * ns)))
    
    # number of sample years by type
    n_samp_yrs = ceiling(c(1, 0.75, 0.5) * nt)
    
    for (s in 1:ns) {
      # which years are NA
      NA_yrs[,s] = c(rep(T, nt - n_samp_yrs[sample_types[s]]),
                 rep(F, n_samp_yrs[sample_types[s]]))

      S_ts_obs_filtered[NA_yrs[,s],s] = NA
    }
    
    ### AGE COMP DATA FILTERING ###
    age_comp_stocks = which(sample_types %in% c(1,2))
    x_tas_obs_filtered = array(NA, dim = c(nt, na, length(age_comp_stocks)))
    for (s in 1:length(age_comp_stocks)) {
      x_tas_obs_filtered[!NA_yrs[,age_comp_stocks[s]],,s] = x_tas_obs[!NA_yrs[,age_comp_stocks[s]],,age_comp_stocks[s]]
    }
    
    # return output
    list(
      S_ts_obs_filtered = S_ts_obs_filtered,
      x_tas_obs_filtered = x_tas_obs_filtered,
      age_comp_stocks = age_comp_stocks
    )
    
  })
  
  # change the full observed time series with the filtered time series
  obs$S_ts_obs = output$S_ts_obs_filtered
  obs$x_tas_obs = output$x_tas_obs_filtered
  obs$age_comp_stocks = output$age_comp_stocks
  
  return(obs)
}
