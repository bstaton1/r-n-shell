

get_lme_mgmt = function(alpha, beta) {
  log_alpha = log(alpha)
  
  U_msy = log_alpha * (0.5 - (0.65 * log_alpha ^1.27)/(8.7 + log_alpha^1.27))
  U_msy[U_msy == "NaN"] = 0
  S_msy = U_msy/beta
  
  
  
  return(list(U_msy = U_msy, S_msy = S_msy))
}
