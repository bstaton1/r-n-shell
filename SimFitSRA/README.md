#A More Complex Problem

In this example, we assess the estimation performance of two assessment models for a mixed stock salmon system.

Essentially, we create a system where there are `ns` substocks driven by synchronous Ricker spawner-recruit dynamics and fished with a constant exploitation rate with a good amount of implementation error. We then observe the states the substocks took on (for some substocks more than others) and fit two assessment models. In this case, the two models are (1) `ns` simple linear regression models fitted to each substock independently and (2) one linear mixed effects model with random intercepts for individual substocks. The final goal is to compare the performance of a much more complex estimation model for this problem to these simpler models.

The assessment models are fitted in JAGS, which is called via R. R is called via a shell script so that eventually this analysis can be ran on the Alabama Supercomputer. 

The subrepository structure and description is as follows:

### Run_Program.sh

---

This is a shell script that calls each of the R scripts described below. It runs Program.R through a loop and calls the other post processing scripts. It also prints progress messages to the console.

### Program.R

---

This script is the one that calls the functions in `/Functions` to actually carry out the analysis. This script is intended to be ran many times, each time with a different seed. Each time it is sourced, it will perform `nsim` different iterations and write the output to a created directory `/Output/OutSeed`. 

### CompileOutput.R

---

This script is sourced after Program.R is complete on all seeds. It pulls the estimates from the different `/Output/OutSeed` directories, combines them into fewer but larger data frames, then saves them as R objects the `/Output` directory. It deletes the individual `/Output/OutSeed` directories when it is complete.

### MakePlots.R

---

This script is sourced after CompileOutput.R is complete. It reads in the saved R objects and makes plots that compare the relative bias of the two assessment methods.

### Umsy_Smsy_Kusko_posteriors.csv

---

These are 1,000 samples from the joint posterior for 13 substocks in the Kuskokwim River in western Alaska. The program uses these samples to obtain the leading parameters for simulating the stock dynamics.

### Functions

---

The functions are organized by their purpose and are grouped as follows:

#### 1* & 2*

These functions generate the true parameters and reference points (that we are trying to estimate eventually). 1* is where you set up the dimensions and behavior of the system.

#### 3*

This function simulates the true states of the population through time for some number of years. It has an imposed management strategy: use the maximum exploitation rate that should result in no more than 10% of the substocks being overfished. The calculation of this rate is based on the true parameters. If you're interested in modeling age-structured salmon population dynamics, sort through this file.

#### 4*

These functions generate observations of the true states. Some stocks are monitored every year, whereas others are missing the first part of the full time series (and some more than others). If you wish to change the way data is collected, change these functions.

#### 5*

This function prepares the data for JAGS. Not much to see here.

#### 6*

This function is a wrapper that takes everything made so far and passes it to JAGS. There is an option to run JAGS in parallel, i.e., to put each of the MCMC chains on a separate core and run them simulataneously. 

#### 7*

These functions summarize the true parameters and estimates in consistent formats. Because the reference points are not calculated in the model, this summarization takes a bit of time. 

#### z*

These functions are general helper functions. They are generally small, but I found it helpful to have them as the same tasks are often done multiple times. 
