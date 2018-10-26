
tsm_2_4_data_prep = function(params, obs) {
  
  output = with(append(params, obs), {
    
    # vectorize escapement observations
    # don't want to waste time looping over NAs
    S_ts_obs_m = S_ts_obs
    S_ts_obs_v = as.numeric(S_ts_obs_m)
    
    S_obs_s = rep(1:ns, each = nt)
    S_obs_t = rep(1:nt, ns)
    
    no_na_yrs = which(!is.na(S_ts_obs_v))
    
    S_obs = S_ts_obs_v[no_na_yrs]
    S_obs_s = S_obs_s[no_na_yrs]
    S_obs_t = S_obs_t[no_na_yrs]
    S_obs_n = length(S_obs)
    
    sig_S_obs_ts_v = as.numeric(sig_S_ts_obs)
    sig_S_obs = sig_S_obs_ts_v[no_na_yrs]
    
    # test it
    # S_ts_obs_m[S_obs_t[100],S_obs_s[100]]
    # S_obs[100]
    
    # prepare info to construct Sigma_R vcov matrix
    m = matrix(1:(ns^2), ns, ns, byrow = T)
    d = diag(m)
    vcov.row = rep(1:ns, each = ns)
    vcov.col = rep(1:ns, ns)
    vcov.ind = ifelse(1:ns^2 %in% d, 1, 2)
    
    # remove NAs from age comps: turn them to zeros
    x_tas_obs[is.na(x_tas_obs)] = 0
    
    list(
      # dimension variables
      ns = ns,
      nt = nt,
      ny = ny,
      na = na,
      a_max = a_max,
      
      # observed harvest states
      C_tot_t_obs = C_tot_t_obs,
      tau_C_obs = 1/sig_C_t_obs^2,
      v = v,
      
      # vectorized observe escapement counts
      S_obs = S_obs, # the count
      S_obs_t = S_obs_t, # the year of the ith count
      S_obs_s = S_obs_s, # the stock of the ith count
      S_obs_n = S_obs_n, # the number of escapement observations
      tau_S_obs = 1/sig_S_obs^2,
      
      # observed age comp states
      x_tas_obs = x_tas_obs,
      ESS_ts = apply(x_tas_obs, 3, rowSums),
      age_stocks = age_comp_stocks,
      n_age_stocks = length(age_comp_stocks),
      
      # stuff for covariance matrix construction
      R_wish = diag(rep(1,ns)),
      df_wish = ns + 1 
    )
  })
  
  return(output)
}


