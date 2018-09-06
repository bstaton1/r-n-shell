#!/bin/bash

# make R findable in the path
# I can't figure out how to set this permanently, so I do it each time
export PATH=${PATH}":/c/Program Files/R/R-3.5.0/bin"     # for my laptop
# export PATH=${PATH}":/c/Program Files/R/R-3.4.4/bin"   # for my desktop
# export PATH=${PATH}":/c/Program Files/R/R-X.X.X/bin"   # for some other user

seeds=(100 200)
nsim=5

# loop through seeds and run the program using each one
for seed in ${seeds[@]}
do
  echo "Running Seed: $seed"
  Rscript Program.R $seed $nsim
  echo "Done"
done

echo "Analysis done."