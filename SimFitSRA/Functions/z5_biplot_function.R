# x = tsm_UMSY; y = true_UMSY

biplot = function(x, y, xlab = "X-AXIS", ylab = "Y-AXIS", new_window = T) {
  
  if (new_window) windows(h = 5, w = 5.3)
  
  # set up layout
  mat = rbind(c(1,2), c(3,4))
  layout(mat, widths = c(1, 0.1), heights = c(0.1, 1))
  layout.show(4)
  # obtain x and y lims
  abs.max = max(abs(c(x, y)), na.rm = T) * 1.05
  lim = abs.max * c(-1,1)
  
  # set up graphical params
  par(xaxs = "i", yaxs = "i", mar = c(0,0,0,0), oma = c(4,4,0,0))
  
  # boxplot for x-axis
  boxplot(x, ylim = lim, horizontal = T, axes = F, outline = F)
  
  # empty plot
  plot.new()
  
  # scatterplot
  plot(y ~ x, xlim = lim, las = 1, ylim = lim,
       ylab = "", xlab = "", type = "n")
  abline(h = 0, col = "grey", lwd = 2); abline(v = 0, col = "grey", lwd = 2); abline(c(0,1), col = "grey", lty = 2)
  box()
  points(y ~ x, col = alpha("grey30", 0.5), pch = 16, cex = 1.5)
  
  # boxplot for y axis
  boxplot(y, ylim = lim, axes = F, outline = F)
  
  # axis text
  mtext(side = 1, outer = T, xlab, line = 2.5)
  mtext(side = 2, outer = T, ylab, line = 2.5)
}