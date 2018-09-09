#!/bin/bash

# simulation dimensions
# seeds=(100 200 300 400 500 600 700 800 900 1000)
seeds=(100 200)
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
