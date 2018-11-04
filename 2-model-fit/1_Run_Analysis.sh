#!/bin/bash

# when ran on the HPC, include this to make R findable
echo "Loading R"
source /opt/asn/etc/asn-bash-profiles-special/modules.sh
module load R/3.3.3

# specify the seeds you wish to run
# the length of this array specifies how many instances are initiated
f=1
l=4
models=$(seq $f $l)

echo "############################################"
echo "########## Starting jobs ###################"
echo "############################################"

echo " "
echo "Models to run: ${models[@]}"
echo " "

# loop through seeds: create and execute seed-specific programs
for model in ${models[@]}
do

  # create a copy of 2_Run_Fit.sh with the third line changed to the $model variable
  awk 'NR==3 {$0="model="'$model'""} { print }' 2_Run_Fit.sh > 2_Run_Fit_$model.sh
  
  # make the new file executable
  chmod +x 2_Run_Fit_$model.sh
  
  # execute the temporary verison with specific seed
  sh 2_Run_Fit_$model.sh
  #run_script 2_Run_Fit_$model.sh
  
  # sleep again to avoid crashes
  sleep 300

done
