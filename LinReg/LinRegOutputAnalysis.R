# process output

ests = read.table("AllEstimates.txt", header = T)

draw.lines = function(x) {
  plot(1, 1, ylim = c(0, 300000), xlim = c(400, 800))
  sapply(x, function(y) abline(c(0,y), col = "grey"))
}

pdf("Slopes.pdf", h = 5, w = 5)
z = tapply(ests$slope, ests$n, draw.lines); rm(z)
junk = dev.off(); rm(junk)

png("slope_boxplot.png", h = 5 * 600, w = 7 * 600, res = 600)
par(mar = c(2,2,2,2))
boxplot(slope ~ n, data = ests, col = "skyblue", outline = F)
abline(h = 245, lwd = 2)
junk = dev.off(); rm(junk)