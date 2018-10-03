# attach(params)

attach(params)
params_summary = function(params, seed) {
  
  output = with(params, {
    # get mean rho
    rho_mat2 = rho_mat
    diag(rho_mat2) = NA
    mean_rho = mean(rho_mat2, na.rm = T)
    
    p = c(rep("alpha", ns), rep("beta", ns), rep("sigma_R", ns), rep("U_msy", ns),
          rep("S_msy", ns), "mean_rho", "mean_sigma_R", "S_obj", "U_obj", "U_MSY", "S_MSY")
    s = c(rep(1:ns, 5), rep(NA, 6))
    v = c(alpha, beta, sigma, U_msy, S_msy, mean_rho, mean(sigma))
    dw = unname(gen_mgmt(params = params)$mgmt[c("S_obj", "U_obj", "U_MSY", "S_MSY")])
    v = c(v, dw)
    
    
    data.frame(seed = seed, stock = s, param = p, value = v)
    
  })
  
  # return output
  return(output)
}

names(params)
