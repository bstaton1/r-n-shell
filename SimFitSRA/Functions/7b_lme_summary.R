
# post = lme_post
# i = 1
# max_p_overfished = params$max_p_overfished
# parallel = T

lme_summary = function(post, max_p_overfished, seed, verbose = T, p_samp = 1) {
  
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
    
    # calculate bgr convergence diagnostic
    ns = ncol(alpha_post_lm)
    bgr = gelman.diag(post, multivariate = F)[[1]]
    lme_bgr = bgr[c(rownames(alpha_summ_lme), rownames(beta_summ_lme)),"Point est."]
    lm_bgr = bgr[c(rownames(alpha_summ_lm), rownames(beta_summ_lm)),"Point est."]
    lme_bgr = c(lme_bgr, rep(NA, ns * 2 + 4))
    lm_bgr = c(lm_bgr, rep(NA, ns * 2 + 4))
    
    # calculate stock-specific reference points
    max_keep = 10000  # the maximum number of posterior samples to keep for dw brp calculations
    
    ntot = nrow(alpha_post_lm)
    nkeep = min(ceiling(ntot * p_samp), max_keep)
    
    # indices of samples to keep
    keep = sample(x = 1:ntot, size = nkeep, replace = F)
    
    U_msy_post_lm = matrix(NA, ntot, ns)
    S_msy_post_lm = matrix(NA, ntot, ns)
    U_msy_post_lme = matrix(NA, ntot, ns)
    S_msy_post_lme = matrix(NA, ntot, ns)
    
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
    
    # combine lme output
    lme_ests = rbind(alpha_summ_lme, beta_summ_lme, U_msy_summ_lme, S_msy_summ_lme); rownames(lme_ests) = NULL
    lme_ests = rbind(lme_ests, mgmt_summ_lme); rownames(lme_ests) = NULL
    lme_id = data.frame(seed = seed, 
                        param = c(rep(c("alpha", "beta", "U_msy", "S_msy"), each = ns), "S_obj", "U_obj", "S_MSY", "U_MSY"),
                        stock = c(rep(1:ns, 4), rep(NA, 4)),
                        method = "lme")
    lme_ests = cbind(lme_id, lme_ests)
    lme_ests = cbind(lme_ests, bgr = lme_bgr)
    
    # combine lm output
    lm_ests = rbind(alpha_summ_lm, beta_summ_lm, U_msy_summ_lm, S_msy_summ_lm); rownames(lm_ests) = NULL
    lm_ests = rbind(lm_ests, mgmt_summ_lm); rownames(lm_ests) = NULL
    lm_id = data.frame(seed = seed, 
                       param = c(rep(c("alpha", "beta", "U_msy", "S_msy"), each = ns), "S_obj", "U_obj", "S_MSY", "U_MSY"),
                       stock = c(rep(1:ns, 4), rep(NA, 4)),
                       method = "lm")
    lm_ests = cbind(lm_id, lm_ests)
    lm_ests = cbind(lm_ests, bgr = lm_bgr)
    
    # combine output
    output = rbind(lme_ests, lm_ests)
    
  } else {
    
    output = data.frame(seed = seed, param = NA, stock = NA,
                        method = c("lme", "lm"), mean = NA, sd = NA, 
                        x1 = NA, x2 = NA, x3 = NA)
    
    colnames(output)[(ncol(output) - 2):ncol(output)] = c("50%", "2.5%", "97.5%")
    output$bgr = NA
  }
  
  
  return(output)
  
}

