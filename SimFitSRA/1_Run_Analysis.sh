#!/bin/bash

echo "+++++++++++++++++++++++++++++++"
echo "Compiling Output"
Rscript CompileOutput.R
echo "+++++++++++++++++++++++++++++++"
echo "Creating Plots"
Rscript MakePlots.R
echo "+++++++++++++++++++++++++++++++"
echo "Zipping files"
tar -cvzf Output.tar.gz Output
echo "+++++++++++++++++++++++++++++++"
echo " "

echo "Analysis done."
