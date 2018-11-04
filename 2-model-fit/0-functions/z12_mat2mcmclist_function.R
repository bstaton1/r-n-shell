mat2mcmc.list = function(mat, chains) {
  out = list()
  
  for (i in sort(unique(chains))) {
    out[[i]] = mat[chains == i,]
  }
  
  as.mcmc.list(lapply(out, mcmc))
}



