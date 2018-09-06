
# handle command line arguments
args = commandArgs(trailingOnly = T)
n = as.numeric(args[1])
nsim = as.numeric(args[2])

# read in functions
source("Functions.R")

# file names
datFileName = "SimData.txt"
fitFileName = "SimEsts.txt"
pltFileName = "Plots.pdf"

# simulate the data, fit regressions
pdf(pltFileName, h = 5, w = 5)
for (i in 1:nsim) {
  cat("\r", "Simulating Relationship #", i, sep = "")
  
  # Sys.sleep(0.1)
  
  temp.dat = SimFunc(n = n, i = i)
  
  temp.fit = FitFunc(temp.dat, do.plot = T)
  
  if (i == 1) {
    dat = temp.dat
    fit = temp.fit
  } else {
    dat = rbind(dat, temp.dat)
    fit = rbind(fit, temp.fit)
  }
}
cat("\n")
junk = dev.off(); rm(junk)

# write the output
cat("\n-------------------------------\n")

write.table(dat, datFileName, row.names = F)
write.table(fit, fitFileName, row.names = F)

# print a message saying files were printed
datFileName = paste("'", datFileName, "'", sep = "")
fitFileName = paste("'", fitFileName, "'", sep = "")
pltFileName = paste("'", pltFileName, "'", sep = "")
cat("Files written to ", getwd(), ":\n  ",
    datFileName, "\n  ", fitFileName, "\n  ", pltFileName, sep = "")

# cat ("\n\n\n", mean(rnorm(3)))

cat("\n-------------------------------\n")
