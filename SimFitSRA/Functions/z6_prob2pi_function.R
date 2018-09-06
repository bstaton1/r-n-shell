
# inverse logit
expit = function(x) {
  exp(x)/(1 + exp(x))
}

# function to turn a vector of prob's to a vector of pi's
prob2pi = function(prob) {
  A = length(prob) + 1
  pi = numeric(A)
  pi[1] = prob[1]
  for (a in 2:(A-1)) { pi[a] = prob[a] * (1 - sum(pi[1:(a-1)]))}
  pi[A] = 1 - sum(pi[1:(A - 1)])
  
  pi
}