
lme_summary = function(post, max_p_overfished, seed, verbose = T) {
  
  # print message
  if(verbose) cat("  Summarizing LME Model Output", "\n", sep = "")
  
  # check if post is NULL. if TRUE, that means JAGS crashed.
  if (!is.null(post)) {

    # extract parameter summaries
    alpha_summ_lm = t(get.post(post, "alpha_lm["))
    alpha_summ_lme = t(get.post(post, "alpha_lme["))
    beta_summ_lm = t(get.post(post, "beta_lm["))
    beta_summ_lme = t(get.post(post, "beta_lme["))
    
    alpha_post_lm = get.post(post, "alpha_lm[", do.post = T)$posterior
    alpha_post_lme = get.post(post, "alpha_lme[", do.post = T)$posterior
    beta_post_lm = get.post(post, "beta_lm[", do.post = T)$posterior
    beta_post_lme = get.post(post, "beta_lme[", do.post = T)$posterior
    
    # number of stocks
    ns = ncol(alpha_post_lm)
    
    # extract the chain each sample came from
    chains = as.matrix(post, chains = T)[,"CHAIN"]

    # calculate stock-specific reference points
    max_keep = 10000  # the maximum number of posterior samples to keep for dw brp calculations
    
    ntot = nrow(alpha_post_lm)
    # nkeep = min(ntot, max_keep)
    nkeep = ntot
    
    # indices of samples to keep
    # keep = sample(x = 1:ntot, size = nkeep, replace = F)
    keep = sort(sample(x = 1:ntot, size = nkeep, replace = F))
    
    U_msy_post_lm = matrix(NA, ntot, ns); colnames(U_msy_post_lm) = paste("U_msy_lm[", 1:ns, "]", sep = "")
    S_msy_post_lm = matrix(NA, ntot, ns); colnames(S_msy_post_lm) = paste("S_msy_lm[", 1:ns, "]", sep = "")
    U_msy_post_lme = matrix(NA, ntot, ns); colnames(U_msy_post_lme) = paste("U_msy_lme[", 1:ns, "]", sep = "")
    S_msy_post_lme = matrix(NA, ntot, ns); colnames(S_msy_post_lme) = paste("S_msy_lme[", 1:ns, "]", sep = "")
    
    for (s in 1:ns) {
      temp_lm_mgmt = get_lme_mgmt(alpha = alpha_post_lm[,s], beta = beta_post_lm[keep,s])
      U_msy_post_lm[,s] = temp_lm_mgmt$U_msy
      S_msy_post_lm[,s] = temp_lm_mgmt$S_msy
      
      temp_lme_mgmt = get_lme_mgmt(alpha = alpha_post_lme[keep,s], beta = beta_post_lme[keep,s])
      U_msy_post_lme[,s] = temp_lme_mgmt$U_msy
      S_msy_post_lme[,s] = temp_lme_mgmt$S_msy
    }
    
    U_msy_summ_lme = t(apply(U_msy_post_lme, 2, post_summ, na.rm = T))
    U_msy_summ_lm = t(apply(U_msy_post_lm, 2, post_summ, na.rm = T))
    S_msy_summ_lme = t(apply(S_msy_post_lme, 2, post_summ, na.rm = T))
    S_msy_summ_lm = t(apply(S_msy_post_lm, 2, post_summ, na.rm = T))
    
    # calculate drainage-wide reference points
    mgmt_post_lme = matrix(NA, nkeep, 4); colnames(mgmt_post_lme) = c("S_obj", "U_obj", "S_MSY", "U_MSY")
    mgmt_post_lm = matrix(NA, nkeep, 4); colnames(mgmt_post_lm) = c("S_obj", "U_obj", "S_MSY", "U_MSY")
    for (j in 1:nkeep) {
      mgmt_post_lme[j,] = gen_mgmt(
        params = list(alpha = alpha_post_lme[keep[j],], beta = beta_post_lme[keep[j],],
                      U_msy = U_msy_post_lme[keep[j],], S_msy = S_msy_post_lme[keep[j],],
                      U_range = seq(0,1,0.01), max_p_overfished = max_p_overfished, ns = ns)
      )$mgmt
      
      mgmt_post_lm[j,] = gen_mgmt(
        params = list(alpha = alpha_post_lm[keep[j],], beta = beta_post_lm[keep[j],],
                      U_msy = U_msy_post_lm[keep[j],], S_msy = S_msy_post_lm[keep[j],],
                      U_range = seq(0,1,0.01), max_p_overfished = max_p_overfished, ns = ns)
      )$mgmt
    }
    
    mgmt_summ_lme = t(apply(mgmt_post_lme, 2, post_summ))
    mgmt_summ_lm = t(apply(mgmt_post_lm, 2, post_summ))
    
    # bgr and ess convergence diagnostic
    lme_post = mat2mcmc.list(
      mat = cbind(alpha_post_lme, beta_post_lme,
                  U_msy_post_lme, S_msy_post_lme,
                  mgmt_post_lme),
      chains = chains
    )
    
    lm_post = mat2mcmc.list(
      mat = cbind(alpha_post_lm, beta_post_lm,
                  U_msy_post_lm, S_msy_post_lm,
                  mgmt_post_lm),
      chains = chains
    )
    
    lme_bgr = gelman.diag(lme_post, multivariate = F)[[1]][,"Point est."]
    lm_bgr = gelman.diag(lm_post, multivariate = F)[[1]][,"Point est."]
    lme_ess = effectiveSize(lme_post)
    lm_ess = effectiveSize(lm_post)
    
    # combine lme output
    lme_ests = rbind(alpha_summ_lme, beta_summ_lme, U_msy_summ_lme, S_msy_summ_lme); rownames(lme_ests) = NULL
    lme_ests = rbind(lme_ests, mgmt_summ_lme); rownames(lme_ests) = NULL
    lme_id = data.frame(seed = seed, 
                        param = c(rep(c("alpha", "beta", "U_msy", "S_msy"), each = ns), "S_obj", "U_obj", "S_MSY", "U_MSY"),
                        stock = c(rep(1:ns, 4), rep(NA, 4)),
                        method = "lme")
    lme_ests = cbind(lme_id, lme_ests)
    lme_ests = cbind(lme_ests, bgr = lme_bgr, ess = lme_ess)
    
    # combine lm output
    lm_ests = rbind(alpha_summ_lm, beta_summ_lm, U_msy_summ_lm, S_msy_summ_lm); rownames(lm_ests) = NULL
    lm_ests = rbind(lm_ests, mgmt_summ_lm); rownames(lm_ests) = NULL
    lm_id = data.frame(seed = seed, 
                       param = c(rep(c("alpha", "beta", "U_msy", "S_msy"), each = ns), "S_obj", "U_obj", "S_MSY", "U_MSY"),
                       stock = c(rep(1:ns, 4), rep(NA, 4)),
                       method = "lm")
    lm_ests = cbind(lm_id, lm_ests)
    lm_ests = cbind(lm_ests, bgr = lm_bgr, ess = lm_ess)
    
    # combine output
    output = rbind(lme_ests, lm_ests)
    
  } else {
    
    output = data.frame(seed = seed, param = NA, stock = NA,
                        method = c("lme", "lm"), mean = NA, sd = NA, 
                        x1 = NA, x2 = NA, x3 = NA)
    
    colnames(output)[(ncol(output) - 2):ncol(output)] = c("50%", "2.5%", "97.5%")
    output$bgr = NA
    output$ess = NA
  }
  
  rownames(output) = NULL
  
  return(output)
  
}
