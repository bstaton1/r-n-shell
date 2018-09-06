# functions

# function to simulate data from a regression relationship
SimFunc = function(n, i, params = c(b0 = 0, b1 = 245, sig = 25000)) {

  # extract parameters
  b0 = params["b0"]
  b1 = params["b1"]
  sig = params["sig"]
  
  # generate observations
  x = runif(n, 400, 800)
  y = b0 + b1 * x + rnorm(n, 0, sig)
  
  # output dataframe
  out = data.frame(iter = i, n = n, x = round(x), y = round(y))
  
  # return the output
  return(out)
}

# function to fit the regression model (no intercept)
FitFunc = function(z, do.plot = F) {
  # fit model
  fit = lm(y ~ -1 + x, data = z)
  
  # extract coefficients
  cfns = round(coef(fit))
  
  # make plot if prompted
  if (do.plot) {
    newx = seq(400, 800, 10)
    par(mar = c(2,4,2,2))
    plot(1, 1, type = "n", las = 1,
         xlim = c(400, 800), xlab = "",
         ylim = c(0, 300000), ylab = "",
         main = paste("Iteration", i))
    
    pred = predict(fit, 
                   newdata = data.frame(x = newx), 
                   interval = "prediction")
    
    polygon(x = c(rev(newx), newx),
            y = c(rev(pred[,"upr"]), pred[,"lwr"]),
            border = NA, col = "grey90"
            )
    
    lines(pred[,"fit"] ~ newx, lwd = 2)
    lines(pred[,"lwr"] ~ newx, col = "grey")
    lines(pred[,"upr"] ~ newx, col = "grey")
    points(y ~ x, data = z, col = "blue", pch = 1)
    
  }
  
  # make output
  output = c(i = unique(z$i), n = nrow(z), slope = unname(cfns[1]))
  
  # return output
  return(output)
}
