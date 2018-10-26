
# post = lme_post
# i = 1
# max_p_overfished = params$max_p_overfished
# seed = 1

tsm_4_summary = function(post, params, seed, verbose = T, diag_plots = T) {
  
  # print message
  if(verbose) cat("  Summarizing TSM Model #4 Output", "\n", sep = "")
  
  # check if post is NULL. if TRUE, that means JAGS crashed.
  if (!is.null(post)) {

    # extract parameter summaries
    alpha_summ = t(get.post(post, "alpha["))
    beta_summ = t(get.post(post, "beta["))
    U_msy_summ = t(get.post(post, "U_msy["))
    S_msy_summ = t(get.post(post, "S_msy["))
    sigma_R_summ = t(get.post(post, "sigma_R["))
    rho_mat_summ = get.post(post, "rho_mat[")
    pi_summ = t(get.post(post, "pi["))
    phi_summ = get.post(post, "phi")
    D_sum_summ = get.post(post, "D_sum")
    
    alpha_post = get.post(post, "alpha[", do.post = T)$posterior; ntot = nrow(alpha_post)
    diag_names = paste("rho_mat[", 1:params$ns, ",", 1:params$ns, "]", sep = "")
    beta_post = get.post(post, "beta[", do.post = T)$posterior
    U_msy_post = get.post(post, "U_msy[", do.post = T)$posterior
    S_msy_post = get.post(post, "S_msy[", do.post = T)$posterior
    rho_mat_post = get.post(post, "rho_mat[", do.post = T)$posterior
    sigma_R_post = get.post(post, "sigma_R[", do.post = T)$posterior
    mean_rho_post = apply(rho_mat_post[,-which(colnames(rho_mat_summ) %in% diag_names)], 1, mean)
    mean_sigma_R_post = apply(sigma_R_post, 1, mean)
    pi_post = get.post(post, "pi[", do.post = T)$posterior
    D_sum_post = get.post(post, "D_sum", do.post = T)$posterior
    phi_post = get.post(post, "phi", do.post = T)$posterior
    
    mean_rho_summ = post_summ(mean_rho_post)
    mean_sigma_R_summ = post_summ(mean_sigma_R_post) 
    
    # calculate stock-specific reference points
    # max_keep = 10000  # the maximum number of posterior samples to keep for dw brp calculations
    
    # nkeep = min(ntot, max_keep)
    nkeep = ntot
    
    # indices of samples to keep
    keep = sort(sample(x = 1:ntot, size = nkeep, replace = F))
    
    # calculate drainage-wide reference points
    mgmt_post = matrix(NA, nkeep, 4); colnames(mgmt_post) = c("S_obj", "U_obj", "S_MSY", "U_MSY")
    for (j in 1:nkeep) {
      mgmt_post[j,] = gen_mgmt(
        params = list(alpha = alpha_post[keep[j],], beta = beta_post[keep[j],],
                      U_msy = U_msy_post[keep[j],], S_msy = S_msy_post[keep[j],],
                      U_range = seq(0,1,0.01), max_p_overfished = params$max_p_overfished, ns = params$ns)
      )$mgmt
    }
    
    mgmt_summ = t(apply(mgmt_post, 2, post_summ))
    
    # get bgr and ess diagnostic
    new_post = mat2mcmc.list(
      mat = cbind(alpha_post, beta_post,sigma_R_post, 
                  U_msy_post, S_msy_post,
                  mean_sigma_R = mean_sigma_R_post,
                  mean_rho = mean_rho_post,
                  pi_post, D_sum = D_sum_post, phi = phi_post, 
                  mgmt_post),
      chains = as.matrix(post, chains = T)[,"CHAIN"]
    )
    
    bgr = gelman.diag(new_post, multivariate = F)[[1]][,"Point est."]
    ess = effectiveSize(new_post)
    
    if (diag_plots) {
      pdf(fileName("Output/tsm_4_diag_plots", seed,".pdf"), h = 5, w = 8)
      x = get.post(new_post, "U_MSY", do.plot = T, new.window = F)
      x = get.post(new_post, "S_MSY", do.plot = T, new.window = F)
      x = get.post(new_post, "mean_sigma_R", do.plot = T, new.window = F)
      x = get.post(new_post, "mean_rho", do.plot = T, new.window = F)
      x = get.post(new_post, "D_sum", do.plot = T, new.window = F)
      x = get.post(new_post, "phi", do.plot = T, new.window = F)

      dev.off()
    }
    
    # combine output
    ests = rbind(alpha_summ, beta_summ, sigma_R_summ,
                 U_msy_summ, S_msy_summ, mean_sigma_R_summ, mean_rho_summ,
                 pi_summ, D_sum_summ, phi_summ,
                 mgmt_summ)
    id = data.frame(seed = seed, 
                    param = c(rep(c("alpha", "beta", "sigma_R",
                                    "U_msy", "S_msy"), each = params$ns),
                              "mean_sigma_R", "mean_rho",
                              paste("pi", params$a_min:params$a_max, sep = "_"), "D_sum", "phi", 
                              "S_obj", "U_obj", "S_MSY", "U_MSY"),
                    stock = c(rep(1:params$ns, 5), rep(NA, 8 + params$na)),
                    method = "tsm4")
    ests = cbind(id, ests)
    ests = cbind(ests, bgr = bgr, ess = ess)
    
    output = ests
    
  } else {
    
    output = data.frame(seed = seed, param = NA, stock = NA,
                        method = c("tsm4"), mean = NA, sd = NA, 
                        x1 = NA, x2 = NA, x3 = NA)
    
    colnames(output)[(ncol(output) - 2):ncol(output)] = c("50%", "2.5%", "97.5%")
    output$bgr = NA
    output$ess = NA
  }
  
  rownames(output) = NULL
  
  return(output)
  
}
