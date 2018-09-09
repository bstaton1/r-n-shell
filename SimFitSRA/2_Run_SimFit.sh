#!/bin/bash

# when ran on the HPC, include this to make R findable
source /opt/asn/etc/asn-bash-profiles-special/modules.sh
module load R/3.3.3

# get the date/time of the start of this script
d=$(date)

# $1 is the random seed provided by 1_Run_Analysis.sh
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Running Iteration with Seed: $1"
echo "  Started running at: $d"
Rscript 3_SimFit.R $1

# print the end date and time of this script
d=$(date)
echo "  Ended running at:   $d"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++"

