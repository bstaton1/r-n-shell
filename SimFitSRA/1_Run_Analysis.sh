#!/bin/bash

seeds=(1 2 3 4 5)

echo "############################################"
echo "####### Starting several jobs ##############"
echo "############################################"

echo "Seeds to use: $seeds"

for seed in ${seeds[@]}
do
  sh 2_Run_SimFit.sh $seed
done

echo "############################################"
echo "Compiling Output"
# Rscript CompileOutput.R
echo "############################################"
echo "Creating Plots"
# Rscript MakePlots.R
echo "############################################"
echo "Zipping files"
# tar -cvzf Output.tar.gz Output
echo "############################################"
echo " "
echo "Analysis done."
