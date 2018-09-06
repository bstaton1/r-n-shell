# this program takes 2 input arguments and runs the simulation/estimation

# handle command line arguments
args = commandArgs(trailingOnly = T)
n = as.numeric(args[1])      # sample size
nsim = as.numeric(args[2])   # number of random data sets

# read in functions
source("../Functions.R")

# file names
datFileName = "SimData.txt"
fitFileName = "SimEsts.txt"
pltFileName = "Plots.pdf"

# simulate the data, fit regressions
pdf(pltFileName, h = 5, w = 5)
for (i in 1:nsim) {
  cat("\r", "Simulating Relationship #", i, sep = "")
  
  # generate data
  temp.dat = SimFunc(n = n, i = i)
  
  # generate fitted relationship
  temp.fit = FitFunc(temp.dat, do.plot = T)
  
  # store output
  if (i == 1) {
    dat = temp.dat
    fit = temp.fit
  } else {
    dat = rbind(dat, temp.dat)
    fit = rbind(fit, temp.fit)
  }
}
junk = dev.off(); rm(junk)
cat("\n-------------------------------\n")

# write the output
write.table(dat, datFileName, row.names = F)
write.table(fit, fitFileName, row.names = F)

# print a message saying files were written and where
datFileName = paste("'", datFileName, "'", sep = "")
fitFileName = paste("'", fitFileName, "'", sep = "")
pltFileName = paste("'", pltFileName, "'", sep = "")
cat("Files written to ", getwd(), ":\n  ",
    datFileName, "\n  ", fitFileName, "\n  ", pltFileName, sep = "")

cat("\n-------------------------------\n")
