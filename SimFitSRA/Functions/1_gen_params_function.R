##### FUNCTION TO GENERATE DRIVING PARAMETERS #####

gen_params = function(nt = 40, ns = 12, rho = 0.5, min_sigR = 0.4, max_sigR = 0.6, random = F) {
  
  # dimensions
  a_min = 4
  a_max = 7
  na = a_max - a_min + 1
  ages = a_min:a_max
  ny = nt + na - 1
  
  # sample primary parameters: these are taken from the posteriors fitted to the kusko data
  
  if (random) {
    n_iter_mcmc = nrow(Umsy_post)
    ns_mcmc = ncol(Umsy_post)
    rand_stock = sample(x = 1:ns_mcmc, size = ns, replace = T)
    rand_iter = sample(x = 1:n_iter_mcmc, size = ns, replace = F)
    U_msy = S_msy = NULL
    for (s in 1:ns) {
      U_msy = c(U_msy, Umsy_post[rand_iter[s],rand_stock[s]])
      S_msy = c(S_msy, Smsy_post[rand_iter[s],rand_stock[s]])
    }
  } else {
    U_msy = apply(Umsy_post, 2, median)[1:ns]
    S_msy = apply(Smsy_post, 2, median)[1:ns]
  }
  
  # obtain on other scale
  alpha = exp(U_msy)/(1 - U_msy)
  beta = U_msy/S_msy
  log_alpha = log(alpha)
  phi = 0.7
  
  # fishery parameters
  max_p_overfished = 0.1
  U_SUM = 50
  v = rep(1, ns)
  
  # create covariance matrix
  sigma = runif(ns, min_sigR, max_sigR)
  Sigma = matrix(1, ns, ns)
  rho_mat = matrix(NA, ns, ns)
  for (i in 1:ns) {
    for (j in 1:ns) {
      Sigma[i,j] = sigma[i] * sigma[j] * rho
    }
  }
  diag(Sigma) = sigma^2
  
  # obtain correlation matrix
  for (i in 1:ns) {
    for (j in 1:ns) {
      rho_mat[i,j] = Sigma[i,j]/(sigma[i] * sigma[j])
    }
  }
  
  # OBSERVATION VARIABILITY
  S_obs_cv = runif(ns, 0.1, 0.2)
  C_tot_obs_cv = runif(1, 0.1, 0.2)
  x_ESS = 100
  
  out = list(
    ns = ns,
    nt = nt,
    a_min = a_min,
    a_max = a_max,
    na = na,
    ages = ages,
    ny = ny,
    pi = pi,
    U_msy = U_msy,
    S_msy = S_msy,
    alpha = alpha,
    beta = beta,
    log_alpha = log_alpha,
    phi = phi,
    max_p_overfished = max_p_overfished,
    U_SUM = U_SUM,
    v = v,
    sigma = sigma,
    rho = rho,
    Sigma = Sigma,
    rho_mat = rho_mat,
    S_obs_cv = S_obs_cv,
    C_tot_obs_cv = C_tot_obs_cv,
    x_ESS = x_ESS
  )
  
  return(out)
}