#!/bin/bash

# the job name common to all jobs
base=myjob

i_files=$(ls $base.i*)
o_files=$(ls $base.o*)
# echo $i_files
# echo $o_files

IDs=$(echo $i_files | grep -oE [0-9]+)
# echo $IDs

# loop through and create jobinfo_ files
for id in ${IDs[@]}
do
 jobinfo -j $id > jobinfo_$id.txt
done

# echo $IDs
# id=188473
# echo $id

##### CREATE SEPARATE SECTIONS #####

### STATUS ###
echo "-----------------" > status.txt
echo "Job Status" >> status.txt
echo "-----------------" >> status.txt

for id in ${IDs[@]}
do
  status_tmp=$(cat jobinfo_$id.txt | grep -w state | awk -F '[[:space:]][[:space:]]+' '{print $2}')
  echo "ID $id: $status_tmp" >> status.txt
done

### SUBMISSION TIMES ###
echo "-----------------" > sub_times.txt
echo "Submission Times" >> sub_times.txt
echo "-----------------" >> sub_times.txt

for id in ${IDs[@]}
do
  time_tmp=$(cat jobinfo_$id.txt | grep -w submitted | awk -F '[[:space:]][[:space:]]+' '{print $2}')
  echo "ID $id: $time_tmp" >> sub_times.txt
done

### START TIMES ###
echo "-----------------" > start_times.txt
echo "Start Times" >> start_times.txt
echo "-----------------" >> start_times.txt

for id in ${IDs[@]}
do
  start_tmp=$(cat jobinfo_$id.txt | grep -w started | awk -F '[[:space:]][[:space:]]+' '{print $2}')
  echo "ID $id: $start_tmp" >> start_times.txt
done

### END TIMES ###
echo "-----------------" > end_times.txt
echo "End Times" >> end_times.txt
echo "-----------------" >> end_times.txt

for id in ${IDs[@]}
do
  end_tmp=$(cat jobinfo_$id.txt | grep -w ended | awk -F '[[:space:]][[:space:]]+' '{print $2}')
  echo "ID $id: $end_tmp" >> end_times.txt
done

### ELAPSED TIMES ###
echo "-----------------" > elapse_times.txt
echo "Elapsed Times" >> elapse_times.txt
echo "-----------------" >> elapse_times.txt

for id in ${IDs[@]}
do
  elapse_tmp=$(cat jobinfo_$id.txt | grep -w elapsed | awk -F '[[:space:]][[:space:]]+' '{print $2}')
  echo "ID $id: $elapse_tmp" >> elapse_times.txt
done

### PARALLEL EFFICIENCY ###
echo "-----------------" > cpu.txt
echo "CPU EFFICIENCY" >> cpu.txt
echo "-----------------" >> cpu.txt

for id in ${IDs[@]}
do
  cpu_tmp=$(cat jobinfo_$id.txt | grep -w parallel | awk -F '[[:space:]][[:space:]]+' '{print $2}')
  echo "ID $id: $cpu_tmp" >> cpu.txt
done

### MEMORY EFFICIENCY ###
echo "-----------------" > mem.txt
echo "MEMORY EFFICIENCY" >> mem.txt
echo "-----------------" >> mem.txt

# id=188473
for id in ${IDs[@]}
do
  mem_tmp=$(cat jobinfo_$id.txt | grep -w memory | awk -F '[[:space:]][[:space:]]+' '{print $2}')
  mem_tmp=$(echo ${mem_tmp} | awk '{print $3}')
  echo "ID $id: $mem_tmp" >> mem.txt
done


##### COMBINE THEM INTO ONE FILE #####
cat status.txt > job-summary.txt
echo " " >> job-summary.txt
cat sub_times.txt >> job-summary.txt
echo " " >> job-summary.txt
cat start_times.txt >> job-summary.txt
echo " " >> job-summary.txt
cat end_times.txt >> job-summary.txt
echo " " >> job-summary.txt
cat elapse_times.txt >> job-summary.txt
echo " " >> job-summary.txt
cat cpu.txt >> job-summary.txt
echo " " >> job-summary.txt
cat mem.txt >> job-summary.txt
echo " " >> job-summary.txt

rm status.txt
rm sub_times.txt
rm start_times.txt
rm end_times.txt
rm elapse_times.txt
rm cpu.txt
rm mem.txt

cat job-summary.txt
rm job-summary.txt