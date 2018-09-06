#!/bin/bash

# make R findable in the path
# I can't figure out how to set this permanently, so I do it each time
export PATH=${PATH}":/c/Program Files/R/R-3.5.0/bin"     # for my laptop
# export PATH=${PATH}":/c/Program Files/R/R-3.4.4/bin"   # for my desktop
# export PATH=${PATH}":/c/Program Files/R/R-X.X.X/bin"   # for some other user

# ask for input
echo "-------------------------------"
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

# delete the AllEstimates.txt
rm AllEstimates.txt

# print a completion message
echo "Analysis complete and the directory has been cleaned of all intermediate files and subdirectories"
echo "The results are in the files 'Slopes.pdf' and 'slope_boxplot.png'"
echo "-------------------------------"
