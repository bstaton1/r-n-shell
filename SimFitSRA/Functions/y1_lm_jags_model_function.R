
mod = function() {
  
  ### FIT THE MIXED EFFECTS VERSION ###
  sig_fit_lme ~ dunif(0, 5)
  tau_fit_lme <- 1/sig_fit_lme^2
  
  log_alpha_bar_lme ~ dunif(0,10)
  sig_log_alpha_lme ~ dunif(0,10)
  tau_log_alpha_lme <- 1/sig_log_alpha_lme^2
  
  # stock level parameters
  for (s in 1:ns) {
    log_alpha_lme[s] ~ dnorm(log_alpha_bar_lme, tau_log_alpha_lme)
    beta_lme[s] ~ dunif(0, 1)
    alpha_lme[s] <- exp(log_alpha_lme[s])
  }
  
  # likelihood
  for (i in 1:nobs) {
    obs_log_RPS_lme[i] ~ dnorm(pred_log_RPS_lme[i], tau_fit_lme)
    pred_log_RPS_lme[i] <- log_alpha_lme[stock[i]] - beta_lme[stock[i]] * S_obs[i]
  }
  
  ### FIT THE INDEPENDENT REGRESSIONS VERSION ###
  # stock level parameters
  for (s in 1:ns) {
    log_alpha_lm[s] ~ dunif(0, 5)
    alpha_lm[s] <- exp(log_alpha_lm[s])
    beta_lm[s] ~ dunif(0, 1)
    sig_fit_lm[s] ~ dunif(0, 5)
    tau_fit_lm[s] <- 1/sig_fit_lm[s]^2
  }
  
  # likelihood
  for (i in 1:nobs) {
    obs_log_RPS_lm[i] ~ dnorm(pred_log_RPS_lm[i], tau_fit_lm[stock[i]])
    pred_log_RPS_lm[i] <- log_alpha_lm[stock[i]] - beta_lm[stock[i]] * S_obs[i]
  }
}

model_file = "Model Files/lme_model.txt"
write.model(mod, model_file); rm(mod); rm(model_file)
