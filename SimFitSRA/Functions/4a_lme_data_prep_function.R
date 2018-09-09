
lme_data_prep = function(params, obs) {
  
  output = with(append(params, obs), {
    # brood year indices
    S_ind = 1:(nt - a_max - 1)
    R_ind = (a_max + 1):(ny - na)
    
    # indices for brood years to use
    S_ys_reg = S_ts_obs[S_ind,]
    R_ys_reg = R_ys_obs[R_ind,]
    
    # calculate log(RPS)
    log_RPS_ys = log(R_ys_reg/S_ys_reg)
    
    # bundle into a data.frame
    lme_dat = data.frame(log_RPS = as.numeric(log_RPS_ys), S_ys = as.numeric(S_ys_reg), stock = rep(1:ns, each = nrow(S_ys_reg)))
    lme_dat = lme_dat[!is.na(lme_dat$log_RPS),]
    
    list(
      ns = ns,
      nobs = nrow(lme_dat),
      obs_log_RPS_lme = lme_dat$log_RPS,
      obs_log_RPS_lm = lme_dat$log_RPS,
      S_obs = lme_dat$S_ys,
      stock = lme_dat$stock
    )
  })
  
  return(output)
}


