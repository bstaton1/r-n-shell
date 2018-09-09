
# the main folder that houses the output
out_main_folder = "Output"

# the full file path there
out_main_dir = paste(getwd(), out_main_folder, sep = "/")

# sub folders within the main output directory
out_sub_folders = dir(out_main_dir)[substr(dir(out_main_dir), 1, 3) == "Out"]

lme_summ = NULL
param_summ = NULL
tsm_summ = NULL
for (i in 1:length(out_sub_folders)) {
  # read in the files from the ith folder
  param_tmp = read.csv(paste(out_main_dir, out_sub_folders[i], "param_summary.csv", sep = "/"), stringsAsFactors = F)
  lme_tmp = read.csv(paste(out_main_dir, out_sub_folders[i], "lme_summary.csv", sep = "/"), stringsAsFactors = F)
  tsm_tmp = read.csv(paste(out_main_dir, out_sub_folders[i], "tsm_summary.csv", sep = "/"), stringsAsFactors = F)
  
  # determine the current maximum number iterations (from last folder)
  max_iter = ifelse(i == 1, 0, max(lme_summ$iter))
  
  # adjust the number of iterations based on max_iter
  param_tmp$iter = param_tmp$iter + max_iter
  lme_tmp$iter = lme_tmp$iter + max_iter
  tsm_tmp$iter = tsm_tmp$iter + max_iter
  
  # append the previous output file with the temporary ones
  param_summ = rbind(param_summ, param_tmp)
  lme_summ = rbind(lme_summ, lme_tmp)
  tsm_summ = rbind(tsm_summ, lme_tmp)
  
  # delete the intermediate files
  unlink(x = paste(out_main_dir, out_sub_folders[i], sep = "/"), recursive = T)
}

# max(params_summ$iter)
# max(lme_summ$iter)

# save the output as environment objects
save(param_summ, file = paste(out_main_dir, "param_summ", sep = "/"))
save(lme_summ, file = paste(out_main_dir, "lme_summ", sep = "/"))
save(tsm_summ, file = paste(out_main_dir, "tsm_summ", sep = "/"))
