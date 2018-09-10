#!/bin/bash

# when ran on the HPC, include this to make R findable
source /opt/asn/etc/asn-bash-profiles-special/modules.sh
module load R/3.3.3

# specify the seeds you wish to run
# the length of this array specifies how many instances are initiated
seeds=(100 200 300 400 500)

echo "############################################"
echo "####### Starting several jobs ##############"
echo "############################################"

echo " "
echo "Seeds to use: ${seeds[@]}"
echo " "

# loop through seeds: create an executable unique seed script for each one
for seed in ${seeds[@]}
do
  # create a copy of 2_Run_SimFit.sh with the third line changed to the $seed variable
  awk 'NR==3 {$0="seed="'$seed'""} { print }' 2_Run_SimFit.sh > 2_Run_SimFit_$seed.sh
  
  # make the new file executable
  chmod +x 2_Run_SimFit_$seed.sh
done

# loop through seeds: execute seed-specific programs
for seed in ${seeds[@]}
do
  # execute the temporary verison with specific seed
  sh 2_Run_SimFit_$seed.sh
  # run_script 2_Run_SimFit_$seed.sh
  
  # delete the temporary file
  rm 2_Run_SimFit_$seed.sh
done

# echo "############################################"
# echo "Compiling Output"
# Rscript 4_CompileOutput.R
# echo "############################################"
# echo "Creating Plots"
# Rscript 5_MakePlots.R
# echo "############################################"
# echo "Zipping files"
# tar -cvzf Output.tar.gz Output
# echo "############################################"
# echo " "
# echo "Analysis done."
