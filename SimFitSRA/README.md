# A More Complex Problem

In this example, we assess the estimation performance of several assessment models for a mixed stock salmon system.

Essentially, we create a system where there are `ns` substocks driven by synchronous Ricker spawner-recruit dynamics and fished with a constant exploitation rate with a good amount of implementation error. We then observe the states the substocks took on (for some substocks more than others) and fit three assessment models. In this case, the three models are (1) `ns` simple linear regression models fitted to each substock independently, (2) one linear mixed effects model with random intercepts for individual substocks, and (3) a fairly complex time series model that more realistically captures the population dynamics. The final goal is to compare the performance of even more complex versions of model (3) to determine an appropriate level of model complexity for this problem.

The assessment models are fitted in `JAGS`, which is called via `R`. `R` is called via a shell script (`Run_Program.sh`) so that eventually this analysis can be ran on the Alabama Supercomputer. 

**To run this program, you will need to have JAGS installed. Go [here](http://mcmc-jags.sourceforge.net/) for details. You will also need several R packages installed (found at the top of Program.R).**

## File Descriptions

---

### Run_Program.sh

This is a shell script that calls each of the R scripts described below. It runs Program.R through a loop and calls the other post processing scripts. It also prints progress messages to the console.

**Note:** You may need to change the location where your computer looks for R. This is found at the top of this script.

### Program.R

This script is the one that calls the functions in `/Functions` to actually carry out the analysis. This script is intended to be ran many times, each time with a different seed. Each time it is sourced, it will perform `nsim` different iterations and write the output to a created directory `/Output/OutSeed`. 

### CompileOutput.R

This script is sourced after Program.R is complete on all seeds. It pulls the estimates from the different `/Output/OutSeed` directories, combines them into fewer but larger data frames, then saves them as R objects the `/Output` directory. It deletes the individual `/Output/OutSeed` directories when it is complete.

### MakePlots.R

This script is sourced after CompileOutput.R is complete. It reads in the saved R objects and makes plots that compare the relative bias of the two assessment methods.

### Umsy_Smsy_Kusko_posteriors.csv

These are 1,000 samples from the joint posterior for 13 substocks in the Kuskokwim River in western Alaska. The program uses these samples to obtain the leading parameters for simulating the stock dynamics.

## Functions

---

The functions are organized by their purpose and are grouped as follows:

#### 1_gen_params

This function generates the true parameters which we are eventually trying to estimate. 1* is where you set up the dimensions and behavior of the system.

#### 2_pop_sim

This function simulates the true states of the population through time for some number of years. It has an imposed management strategy: use the maximum exploitation rate that should result in no more than 10% of the substocks being overfished. The calculation of this rate is based on the true parameters. If you're interested in modeling age-structured salmon population dynamics, sort through this file.

#### 3*

These functions generate observations of the true states. Some stocks are monitored every year, whereas others are missing the first part of the full time series (and some more than others). If you wish to change the way data is collected, change these functions.

#### 4*

These functions prepares the data for JAGS. Not much to see here.

#### 5*

These functions generate reasonable starting values for the models.

#### 6*

This function is a wrapper that takes everything made so far and passes it to JAGS. There is an option to run JAGS in parallel, i.e., to put each of the MCMC chains on a separate core and run them simulataneously. This is the component that takes the most time to run - especially the tsm model.

#### 7*

These functions summarize the true parameters and estimates in consistent formats. Because the reference points are not calculated in the model, these functions take a bit of time to execute. 

#### z*

These functions are general helper functions. They are generally small, but I found it helpful to have them as the same tasks are often done multiple times. 
