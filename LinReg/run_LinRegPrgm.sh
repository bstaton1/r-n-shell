#!/bin/bash

# make R findable in the path
export PATH=${PATH}":/c/Program Files/R/R-3.5.0/bin"
# export PATH=${PATH}":/c/Program Files/R/R-3.4.4/bin"

# ask for input

# echo "-------------------------------"

echo "-------------------------------"
echo "Please enter the number of simulations per sample size:"
read nsim
echo "-------------------------------"
echo "Please enter the sample size vector (separated by spaces):"
read n_vec

# or make an array rather than asking user
# n_vec=(5 10 15 20 25 30)

# create separate folders with output from each run
# for var in $n_vec # this way works if provided via read
for var in ${n_vec[@]}
do
  if [ ! -d "N_$var" ]; then
    mkdir N_$var
  fi

  cd N_$var

  Rscript ../LinRegPrgm.R $var $nsim

  cd ../
done

# create an empty file: I've forgotten what this means
grep "i" N_$var/SimEsts.txt > AllEstimates.txt

# loop through each folder and put estimates in a new file
# for var in $n_vec
for var in ${n_vec[@]}
do
  grep -v "i" N_$var/SimEsts.txt >> AllEstimates.txt
  rm -r N_$var
done

# run the output analysis script
Rscript LinRegOutputAnalysis.R

