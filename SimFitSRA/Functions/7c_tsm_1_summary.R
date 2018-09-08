
# post = lme_post
# i = 1
# max_p_overfished = params$max_p_overfished
# parallel = T

tsm_1_summary = function(post, max_p_overfished, i, verbose = T, p_samp = 1) {
  
  # print message
  if(verbose) cat("  Summarizing TSM Model #1 Output", "\n", sep = "")
  
  # check if post is NULL. if TRUE, that means JAGS crashed.
  if (!is.null(post)) {

    # extract parameter summaries
    alpha_summ = t(get.post(post, "alpha["))
    beta_summ = t(get.post(post, "beta["))
    U_msy_summ = t(get.post(post, "U_msy["))
    S_msy_summ = t(get.post(post, "S_msy["))
    
    alpha_post = get.post(post, "alpha[", do.post = T)$posterior
    beta_post = get.post(post, "beta[", do.post = T)$posterior
    U_msy_post = get.post(post, "U_msy[", do.post = T)$posterior
    S_msy_post = get.post(post, "S_msy[", do.post = T)$posterior
    
    # calculate bgr convergence diagnostic
    ns = ncol(alpha_post)
    bgr = gelman.diag(post, multivariate = F)[[1]]
    bgr = bgr[c(rownames(alpha_summ), rownames(beta_summ), rownames(U_msy_summ), rownames(S_msy_summ)),"Point est."]
    bgr = c(bgr, rep(NA, 4))
    
    # calculate stock-specific reference points
    max_keep = 10000  # the maximum number of posterior samples to keep for dw brp calculations
    
    ntot = nrow(alpha_post)
    nkeep = min(ceiling(ntot * p_samp), max_keep)
    
    # indices of samples to keep
    keep = sample(x = 1:ntot, size = nkeep, replace = F)
    
    # calculate drainage-wide reference points
    mgmt_post = matrix(NA, nkeep, 4); colnames(mgmt_post) = c("S_obj", "U_obj", "S_MSY", "U_MSY")
    for (j in 1:nkeep) {
      mgmt_post[j,] = gen_mgmt(
        params = list(alpha = alpha_post[keep[j],], beta = beta_post[keep[j],],
                      U_msy = U_msy_post[keep[j],], S_msy = S_msy_post[keep[j],],
                      U_range = seq(0,1,0.01), max_p_overfished = max_p_overfished, ns = ns)
      )$mgmt
    }
    
    mgmt_summ = t(apply(mgmt_post, 2, post_summ))
    
    # combine lme output
    ests = rbind(alpha_summ, beta_summ, U_msy_summ, S_msy_summ); rownames(ests) = NULL
    ests = rbind(ests, mgmt_summ); rownames(ests) = NULL
    id = data.frame(iter = i, 
                    param = c(rep(c("alpha", "beta", "U_msy", "S_msy"), each = ns), "S_obj", "U_obj", "S_MSY", "U_MSY"),
                    stock = c(rep(1:ns, 4), rep(NA, 4)),
                    method = "tsm")
    ests = cbind(id, ests)
    ests = cbind(ests, bgr = bgr)
    
    output = ests
    
  } else {
    
    output = data.frame(iter = i, param = NA, stock = NA,
                        method = c("tsm"), mean = NA, sd = NA, 
                        x1 = NA, x2 = NA, x3 = NA)
    
    colnames(output)[(ncol(output) - 2):ncol(output)] = c("50%", "2.5%", "97.5%")
    output$bgr = NA
  }
  
  
  return(output)
  
}

