mod = function() {
  
  # Priors on primary parameters
  # mean_sigma_R <- 0.71
  # mean_tau_R <- 1/mean_sigma_R^2
  # tau_R_red <- mean_tau_R * (1 - phi^2)
  # log_resid_0a ~ dnorm(0, tau_R_red)
  log_resid_0a <- 0
  
  phi ~ dunif(-0.99, 0.99)
  for (s in 1:ns) {
    U_msy[s] ~ dunif(0.01, 0.99)
    log_S_msy[s] ~ dnorm(0, 0.001) %_% I(1, 11.5)
    S_msy[s] <- exp(log_S_msy[s])
    
    alpha[s] <- exp(U_msy[s])/(1 - U_msy[s])
    log_alpha[s] <- log(alpha[s])
    beta[s] <- U_msy[s]/S_msy[s]
    log_resid_0[s] <- log_resid_0a
  }
  
  # build the Sigma_R[,] matrix
  sig.common ~ dunif(0,2)
  var.common <- sig.common^2
  rho.common ~ dunif(-0.05,1)
  rho.vec[1] <- 1
  rho.vec[2] <- rho.common
  
  for (i in 1:vcov.N) {
    rho_mat[vcov.row[i],vcov.col[i]] <- rho.vec[vcov.ind[i]]
    Sigma_R[vcov.row[i],vcov.col[i]] <- var.common * rho.vec[vcov.ind[i]]
  }
  
  Tau_R[1:ns,1:ns] <- inverse(Sigma_R[1:ns,1:ns])
  
  # white noise process sd for each substock
  for (s in 1:ns) {
    sigma_R[s] <- sqrt(Sigma_R[s,s])
  }
  
  # produce Ricker predictions
  for (s in 1:ns) {
    # for years without SR link: use unfished equilibrium recruitment
    R_eq[s] <- log_alpha[s]/beta[s]
    R0[s] <- R_eq[s]
    log_R0[s] <- log(R0[s])
    
    # log_R_mean1 = deterministic ricker; log_R_mean2 = time-corrected expectation
    log_R_mean1[1,s] <- log_R0[s]
    R_mean1[1,s] <- R0[s]
    log_R_mean2[1,s] <- log_R_mean1[1,s] + phi * log_resid_0[s]
    for (y in 2:a_max) {
      R_mean1[y,s] <- R0[s]
      log_R_mean1[y,s] <- log_R0[s]
      log_R_mean2[y,s] <- log_R_mean1[y,s] + phi * log_resid[y-1,s]
    }
    
    # for years with SR link
    for (y in (a_max+1):ny) {
      R_mean1[y,s] <- S[y-a_max,s] * exp(log_alpha[s] - beta[s] * S[y-a_max,s])
      log_R_mean1[y,s] <- log(R_mean1[y,s])
      log_R_mean2[y,s] <- log_R_mean1[y,s] + phi * log_resid[y-1,s]
    }
  }
  
  # draw true recruitment states
  for (y in 1:ny) {
    log_R[y,1:ns] ~ dmnorm(log_R_mean2[y,1:ns], Tau_R[1:ns,1:ns])
  }
  
  # calculate residuals
  for (y in 1:ny) {
    for (s in 1:ns) {
      R[y,s] <- exp(log_R[y,s])
      log_resid[y,s] <- log_R[y,s] - log_R_mean1[y,s]
    }
    R_tot[y] <- sum(R[y,1:ns])
  }
  
  # maturity schedule
  prob[1] ~ dbeta(1,1)
  prob[2] ~ dbeta(1,1)
  prob[3] ~ dbeta(1,1)
  pi[1] <- prob[1]
  pi[2] <- prob[2] * (1 - pi[1])
  pi[3] <- prob[3] * (1 - pi[1] - pi[2])
  pi[4] <- 1 - pi[1] - pi[2] - pi[3]
  
  for (y in 1:ny) {
    p[y,1:na] <- pi[1:na]
  }
  
  # allocate R[y,s] to N[t,a,s] and create predicted calendar year states for each stock
  for (s in 1:ns) {
    for (t in 1:nt) {
      for (a in 1:na) {
        N_tas[t,a,s] <- R[t+na-a,s] * p[t+na-a,a]
      }
      N[t,s] <- sum(N_tas[t,1:na,s])
      S[t,s] <- N[t,s] * (1 - U[t] * v[s])
      H[t,s] <- N[t,s] * (U[t] * v[s])
    }
  }
  
  # create calendar year totals across stocks
  for (t in 1:nt) {
    U[t] ~ dbeta(1,1)
    
    # N_tot[t] <- sum(N[t,1:ns])
    # S_tot[t] <- sum(S[t,1:ns])
    H_tot[t] <- sum(H[t,1:ns])
  }
  
  # obtain calendar year age composition for each stock
  for (s in 1:ns) {
    for (t in 1:nt) {
      for (a in 1:na) {
        q[t,a,s] <- N_tas[t,a,s]/N[t,s]
      }
    }
  }
  
  # observe calendar year total harvest 
  for (t in 1:nt) {
    log_H_tot[t] <- log(H_tot[t])
    H_tot_obs[t] ~ dlnorm(log_H_tot[t], tau_H[t])
  }
  
  # observe calendar year substock specific harvests
  for (i in 1:Sobs_n) {
    log_S[i] <- log(S[Sobs_t[i],Sobs_s[i]])
    S_obs[i] ~ dlnorm(log_S[i], tau_S[Sobs_s[i]])
  }
  
  # observe age composition
  for (s in 1:n_age_stocks) {
    for (t in 1:nt) {
      x_array[t,1:na,age_stocks[s]] ~ dmulti(q[t,1:na,age_stocks[s]], n_mat[t,age_stocks[s]])
    }
  }
}

model.file = "tsm_model_1.txt"
write.model(mod, model.file)