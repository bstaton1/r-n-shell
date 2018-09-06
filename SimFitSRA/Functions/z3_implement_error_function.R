

implement_error = function(U_target, SUM) {
  Ua = U_target * SUM
  Ub = SUM - Ua
  
  rbeta(1, Ua, Ub)
}


# U_target = runif(1000, 0.01, 0.99)
# U_real = sapply(U_target, function(x) implement_error(U_target = x, SUM = 10))
# 
# windows()
# plot(U_target ~ U_real)
