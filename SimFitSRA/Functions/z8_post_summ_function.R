post_summ = function(x, na.rm = F) {
  c(mean = mean(x, na.rm = na.rm), sd = sd(x, na.rm = na.rm), quantile(x, c(0.5, 0.025, 0.975), na.rm = na.rm))
}