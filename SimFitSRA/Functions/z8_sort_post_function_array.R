#' A function to sort shuffled parameters
#' 
#' Sorts a matrix of shuffled columns (i.e. 1, 10, 11, ... 19, 2, 20, 21, etc.) back into numerical order
#' @param post.samp an object of class "matrix" or "mcmc.list" that contains the results of a Bayesian model
#' @param var the variable that is shuffled that you wish to unshuffle
#' @param dim if var has two dimensions (i.e. is a matrix rather than a vector) specify the dimensions
#' @param summarize logical. Do you want to summarize the posterior using get.post()?
#' @param do.plot logical. Optional argument passed to get.post
#' @param do.post logical. Optional argument passed to get.post

sort.post=function(post.samp, var, do.plot=F, do.post=F, dim = NULL, n.chains){
  require(coda)
    
  #coerce to matrix if mcmc.list
  if (!is.mcmc.list(post.samp) & !is.matrix(post.samp)) stop("post.samp is not of class mcmc.list or matrix")
  if (is.mcmc.list(post.samp)) {
    nchains = length(post.samp)
    post.samp=as.matrix(post.samp)
  } else nchains = n.chains
    
  #pull out posteriors for requested variable
  if (substr(var,nchar(var), nchar(var))=="[") {
    post = post.samp[,substr(colnames(post.samp), 1, nchar(var))==var]
  } else stop(paste(var, "is not a parameter that has multiple indicies"))
  
  #### if there is only one dimension ####
  if (is.null(dim)) {
    root.var = substr(var, 1, nchar(var)-1)
    n.ind = length(colnames(post))
    var.names = paste(root.var, "[", 1:n.ind, "]", sep="")
    
    post = post[, var.names]
    
    sum.post = get.post(post, var, do.plot=do.plot, do.post=do.post, n.chains = nchains)
    return(sum.post)
  }

  #### if there are two dimensions ####
  if (is.numeric(dim) & length(dim) == 2) {
    root.var = substr(var, 1, nchar(var)-1)
    row.indices = rep(1:dim[1], dim[2])
    col.indices = rep(1:dim[2], each = dim[1])
    
    var.names = paste(root.var, "[", row.indices, ",", col.indices, "]", sep = "")
    
    # loop through columns of post and match it up to the names in var.names and tell it that the first place of 
    # the new post should be the column that matches up with the first name in var.names.  Then second place and so on.
    
    new.post = matrix(NA, nrow = nrow(post), ncol = length(var.names))
    for(i in 1:(dim[1] * dim[2])){
      new.post[,i] = post[,var.names[i]]
    }
    colnames(new.post) = var.names
    
    sum.post = get.post(new.post, var, do.plot = do.plot, do.post = do.post)
    return(sum.post)
  }
  
  #### if there are three dimensions ####
  if (is.numeric(dim) & length(dim) == 3) {
    root.var = substr(var, 1, nchar(var)-1)
    row.indices = rep(1:dim[1], dim[2])
    col.indices = rep(1:dim[2], each = dim[1])
    arr.indices = rep(1:dim[3], each = dim[1] * dim[2])
    
    var.names = paste(root.var, "[", row.indices, ",", col.indices, ",", arr.indices, "]", sep = "")
    
    # loop through columns of post and match it up to the names in var.names and tell it that the first place of 
    # the new post should be the column that matches up with the first name in var.names.  Then second place and so on.
    
    new.post = matrix(NA, nrow = nrow(post), ncol = length(var.names))
    for(i in 1:(dim[1] * dim[2] * dim[3])){
      new.post[,i] = post[,var.names[i]]
    }
    colnames(new.post) = var.names
    
    sum.post = get.post(new.post, var, do.plot = do.plot, do.post = do.post)
    return(sum.post)
  }
}

