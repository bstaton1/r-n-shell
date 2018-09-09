#!/bin/bash

# when ran on the HPC, include this to make R findable
# source /opt/asn/etc/asn-bash-profiles-special/modules.sh
# module load R/3.3.3

seeds=(1 2 3 4 5)

echo "############################################"
echo "####### Starting several jobs ##############"
echo "############################################"

# echo "Seeds to use: $seeds"

for seed in ${seeds[@]}
do
  sh 2_Run_SimFit.sh $seed
  # run_script 2_Run_SimFit.sh $seed
done
# wait

echo "############################################"
echo "Compiling Output"
Rscript 4_CompileOutput.R
echo "############################################"
echo "Creating Plots"
Rscript 5_MakePlots.R
echo "############################################"
echo "Zipping files"
tar -cvzf Output.tar.gz Output
echo "############################################"
echo " "
echo "Analysis done."
