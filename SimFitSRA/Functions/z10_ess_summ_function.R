# function to summarize bgr convergence stats

ess_summ = function(summ, vars) {

  # subset out only desired variables
  summ = subset(summ, param %in% vars)
  
  # calculate the number of failures
  failed = nrow(summ[is.na(summ$param) & !duplicated(summ$iter),])
  
  # remove the failure rows
  summ = subset(summ, !is.na(param))
  
  # total iterations
  n = length(unique(summ$iter))
  
  # determine fraction of all parameters across
  # all iterations that were worse than criteria
  p_worse_2000 = tapply(summ$ess, summ$param, function(x) mean(x < 2000))
  p_worse_4000 = tapply(summ$ess, summ$param, function(x) mean(x < 4000))
  
  P_worse_2000 = paste(round(p_worse_2000, 3) * 100, "%", sep = "")
  P_worse_4000 = paste(round(p_worse_4000, 3) * 100, "%", sep = "")
  
  p_worse = data.frame("2000" = P_worse_2000, "4000" = P_worse_4000)
  rownames(p_worse) = names(p_worse_2000)
  colnames(p_worse) = c("2000", "4000")
  
  # for each iteration, was any one element of the parameter not converged?
  iters_any_worse_2000 = t(sapply(unique(summ$iter), function(x) {
    tmp = subset(summ, iter == x)
    tapply(tmp$bgr, tmp$param, function(y) any(y < 2000))
  }))
  iters_any_worse_4000 = t(sapply(unique(summ$iter), function(x) {
    tmp = subset(summ, iter == x)
    tapply(tmp$bgr, tmp$param, function(y) any(y < 4000))
  }))
  
  p_iters_any_worse_2000 = paste(round(colSums(iters_any_worse_2000)/n, 3) * 100, "%", sep = "")
  p_iters_any_worse_4000 = paste(round(colSums(iters_any_worse_4000)/n, 3) * 100, "%", sep = "")
  
  p_iters_any_worse = data.frame("2000" = p_iters_any_worse_2000, "4000" = p_iters_any_worse_4000)
  rownames(p_iters_any_worse) = colnames(iters_any_worse_2000)
  colnames(p_iters_any_worse) = c("2000", "4000")
  
  # print the output to the console
  cat("\n--------------------------------------\n")
  cat("% of All Estimates below criteria:\n")
  print(p_worse)
  
  cat("--------------------------------------\n")
  cat("% of Iterations with at Least one", "\n   Parameter Element below criteria:\n")
  print(p_iters_any_worse)
  cat("--------------------------------------\n")
  
}

# bgr_summ(summ = tsm_summ, vars = c("alpha", "beta", "U_msy", "S_msy"))
# bgr_summ(summ = subset(lme_summ, method == "lm"), vars = c("alpha", "beta"))
# bgr_summ(summ = subset(lme_summ, method == "lme"), vars = c("alpha", "beta"))
