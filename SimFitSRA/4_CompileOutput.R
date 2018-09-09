
# the main folder that houses the output
out_folder = "Output"

# the full file path there
out_dir = paste(getwd(), out_folder, sep = "/")

# the individual file names
out_files = dir(out_dir)
lme_files = out_files[substr(out_files, 1, 3) == "lme"]
tsm_files = out_files[substr(out_files, 1, 3) == "tsm"]
param_files = out_files[substr(out_files, 1, 3) == "par"]

# number of iterations
n = length(lme_files)

lme_summ = NULL
param_summ = NULL
tsm_summ = NULL
for (i in 1:n) {
  # read in the files from the ith folder
  param_tmp = read.csv(paste(out_dir, param_files[i], sep = "/"), stringsAsFactors = F)
  lme_tmp = read.csv(paste(out_dir, lme_files[i], sep = "/"), stringsAsFactors = F)
  tsm_tmp = read.csv(paste(out_dir, tsm_files[i], sep = "/"), stringsAsFactors = F)
  
  # add the iter count
  param_tmp$iter = i
  lme_tmp$iter = i
  tsm_tmp$iter = i
  
  # append the previous output file with the temporary ones
  param_summ = rbind(param_summ, param_tmp)
  lme_summ = rbind(lme_summ, lme_tmp)
  tsm_summ = rbind(tsm_summ, tsm_tmp)
  
  # delete the intermediate files
  unlink(x = paste(out_dir, param_files[i], sep = "/"), recursive = T)
  unlink(x = paste(out_dir, lme_files[i], sep = "/"), recursive = T)
  unlink(x = paste(out_dir, tsm_files[i], sep = "/"), recursive = T)
}

# save the output as environment objects
save(param_summ, file = paste(out_dir, "param_summ", sep = "/"))
save(lme_summ, file = paste(out_dir, "lme_summ", sep = "/"))
save(tsm_summ, file = paste(out_dir, "tsm_summ", sep = "/"))
