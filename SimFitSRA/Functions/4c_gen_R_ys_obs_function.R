# attach(params); attach(obs_out)
# detach(params); detach(obs_out)

gen_Rys_obs = function(params, obs) {
  
  output = with(append(params, obs), {
    # containers
    H_ts_obs = matrix(NA, nt, ns)
    R_ys_obs = matrix(NA, ny, ns)
    S_tas_obs = array(NA, dim = c(nt, na, ns))
    H_tas_obs = array(NA, dim = c(nt, na, ns))
    N_tas_obs = array(NA, dim = c(nt, na, ns))
    
    # obtain age proportions for stocks that have age data
    q_tas_obs = array(NA, dim = c(nt, na, length(age_comp_stocks)))
    for (s in 1:length(age_comp_stocks)) {
      q_tas_obs[,,s] = t(apply(x_tas_obs[,,s], 1, function(x) x/sum(x)))
    }
    
    # obtain the average age proportion across all stocks that have data
    q_ta_ave = matrix(NA, nt, na)
    for (t in 1:nt) {
      for (a in 1:na) {
        q_ta_ave[t,a] = mean(q_tas_obs[t,a,], na.rm = T)
      }
    }
    
    for (s in 1:ns) {
      
      # determine appropriate age comps to use
      if (s %in% age_comp_stocks) {
        q_ta_use = q_tas_obs[,,which(age_comp_stocks == s)]
      } else {
        q_ta_use = q_ta_ave
      }
      
      # generate calendar year quantities for each stock
      H_ts_obs[,s] = (S_ts_obs[,s] * U_t_obs)/(1 - U_t_obs)
      S_tas_obs[,,s] = apply(q_ta_use, 2, function(x) x * S_ts_obs[,s])
      H_tas_obs[,,s] = apply(q_ta_use, 2, function(x) x * H_ts_obs[,s])
      N_tas_obs[,,s] = S_tas_obs[,,s] + H_tas_obs[,,s]
      
      # generate brood year recruits for each stock
      for (y in 1:ny) {
        if (y <= (nt - 4)) {
          brd.yr.runs = diag(N_tas_obs[y:(y+na),,s])
          R_ys_obs[y+na-1,s] = sum(brd.yr.runs, na.rm = all(!is.na(brd.yr.runs)))
        } else {
          next()
        }
      }
    }
    
    N_ts_obs = apply(N_tas_obs, 3, rowSums)
    
    # list(
    #   R_ys_obs = R_ys_obs,
    #   H_ts_obs = H_ts_obs,
    #   N_ts_obs = N_ts_obs
    #   # U_ts_obs = H_ts_obs/N_ts_obs
    # )
    
    R_ys_obs
  })
  
  # add it to the observed data set
  obs = append(obs, list(R_ys_obs = output))
  
  # return output
  return(obs)
}

