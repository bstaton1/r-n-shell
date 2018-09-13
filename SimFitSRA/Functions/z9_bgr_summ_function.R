# function to summarize bgr convergence stats

bgr_summ = function(summ, vars) {

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
  p_worse_1.1 = tapply(summ$bgr, summ$param, function(x) mean(x > 1.1))
  p_worse_1.2 = tapply(summ$bgr, summ$param, function(x) mean(x > 1.2))
  
  P_worse_1.1 = paste(round(p_worse_1.1, 3) * 100, "%", sep = "")
  P_worse_1.2 = paste(round(p_worse_1.2, 3) * 100, "%", sep = "")
  
  p_worse = data.frame("1.1" = P_worse_1.1, "1.2" = P_worse_1.2)
  rownames(p_worse) = names(p_worse_1.1)
  colnames(p_worse) = c("1.1", "1.2")
  
  # for each iteration, was any one element of the parameter not converged?
  iters_any_worse_1.1 = t(sapply(unique(summ$iter), function(x) {
    tmp = subset(summ, iter == x)
    tapply(tmp$bgr, tmp$param, function(y) any(y > 1.1))
  }))
  iters_any_worse_1.2 = t(sapply(unique(summ$iter), function(x) {
    tmp = subset(summ, iter == x)
    tapply(tmp$bgr, tmp$param, function(y) any(y > 1.2))
  }))
  
  p_iters_any_worse_1.1 = paste(round(colSums(iters_any_worse_1.1)/n, 3) * 100, "%", sep = "")
  p_iters_any_worse_1.2 = paste(round(colSums(iters_any_worse_1.2)/n, 3) * 100, "%", sep = "")
  
  p_iters_any_worse = data.frame("1.1" = p_iters_any_worse_1.1, "1.2" = p_iters_any_worse_1.2)
  rownames(p_iters_any_worse) = colnames(iters_any_worse_1.1)
  colnames(p_iters_any_worse) = c("1.1", "1.2")
  
  # print the output to the console
  cat("\n--------------------------------------\n")
  cat("% of All Estimates above criteria:\n")
  print(p_worse)
  
  cat("--------------------------------------\n")
  cat("% of Iterations with at Least one", "\n   Parameter Element above criteria:\n")
  print(p_iters_any_worse)
  cat("--------------------------------------\n")
  
}

# bgr_summ(summ = tsm_summ, vars = c("alpha", "beta", "U_msy", "S_msy"))
# bgr_summ(summ = subset(lme_summ, method == "lm"), vars = c("alpha", "beta"))
# bgr_summ(summ = subset(lme_summ, method == "lme"), vars = c("alpha", "beta"))
