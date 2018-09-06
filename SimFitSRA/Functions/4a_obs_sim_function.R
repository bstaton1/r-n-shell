
##### MODEL TO GENERATE OBSERVED CALENDAR YEAR STATES #####
obs_sim = function(params, true) {
  
  output = with(append(params, true), {
    
    # generate lognormal observation error sd
    sig_S_obs = sqrt(log(S_obs_cv^2 + 1))
    sig_C_tot_obs = sqrt(log(C_tot_obs_cv^2 + 1))
  
    # observe spawners
    S_ts_obs = matrix(NA, nt, ns)
    for (s in 1:ns) {
      S_ts_obs[,s] = rlnorm(nt, log(S_ts[,s]), sig_S_obs[s])
    }
    
    # observe total harvest
    C_tot_t_obs = rlnorm(nt, log(C_tot_t), sig_C_tot_obs)
    
    # observe age composition
    x_tas_obs = array(NA, dim = c(nt, na, ns))
    for (s in 1:ns) {
      for (t in 1:nt) {
        x_tas_obs[t,,s] = t(rmultinom(n = 1, size = x_ESS, prob = q_tas[t,,s]))
      }
    }
    
    N_tot_t_obs = C_tot_t_obs + rowSums(S_ts_obs)
    U_t_obs = C_tot_t_obs/N_tot_t_obs
    
    # bundle output
    list(
      C_tot_t_obs = C_tot_t_obs,
      S_ts_obs = S_ts_obs,
      x_tas_obs = x_tas_obs,
      sig_S_s_obs = sig_S_obs,
      sig_C_tot_obs = sig_C_tot_obs,
      U_t_obs = U_t_obs
      )
  })

  # return output
  return(output)
}




