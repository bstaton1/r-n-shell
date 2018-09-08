#!/bin/bash

# make R findable in the path
# I can't figure out how to set this permanently, so I do it each time
export PATH=${PATH}":/c/Program Files/R/R-3.5.0/bin"     # for my laptop
# export PATH=${PATH}":/c/Program Files/R/R-3.4.4/bin"   # for my desktop
# export PATH=${PATH}":/c/Program Files/R/R-X.X.X/bin"   # for some other user

# simulation dimensions
# seeds=(100 200 300 400 500 600 700 800 900 1000)
seeds=(100)
nsim=1

# loop through seeds and run the program using each one
for seed in ${seeds[@]}
do
  echo "+++++++++++++++++++++++++++++++"
  echo "Running Seed: $seed"
  Rscript Program.R $seed $nsim
done

echo "+++++++++++++++++++++++++++++++"
echo "Compiling Output"
Rscript CompileOutput.R
echo "+++++++++++++++++++++++++++++++"
echo "Creating Plots"
Rscript MakePlots.R
echo "+++++++++++++++++++++++++++++++"
echo " "

echo "Analysis done."
