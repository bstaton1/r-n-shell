# attach(params)

params_summary = function(params, seed) {
  
  output = with(params, {
    
    p = c(rep("alpha", ns), rep("beta", ns), rep("U_msy", ns), rep("S_msy", ns), "S_obj", "U_obj", "U_MSY", "S_MSY")
    s = c(rep(1:ns, 4), rep(NA, 4))
    v = c(alpha, beta, U_msy, S_msy)
    dw = unname(gen_mgmt(params = params)$mgmt[c("S_obj", "U_obj", "U_MSY", "S_MSY")])
    v = c(v, dw)
    
    data.frame(seed = seed, stock = s, param = p, value = v)
    
  })
  
  # return output
  return(output)
}