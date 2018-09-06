# r-n-shell

This is a repository where I've placed a handful of toy examples for interacting with R from shell. 

Currently, the examples are:

1.  **LinReg**: a simulation experiment focused on determining how sample size affects the precision with which the slope of a simple linear regression model can be estimated. The simulation is conducted using general R code which is called by a shell script.

2. **SimFitSRA**: a simulation experiment focused on determining how two estimators for a spawner-recruit relationship perform at providing advice in mixed stock situations. The R code does the statistical heavy lifting by generating fake data and passing the model to JAGS for estimation and the shell script takes care of the execution, house-cleaning, and eventually supercomputing on the Alabama HPC (hopefully).




