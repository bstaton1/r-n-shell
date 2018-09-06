
# the main folder that houses the output
out_main_folder = "Output"

# the full file path there
out_main_dir = paste(getwd(), out_main_folder, sep = "/")

# sub folders within the main output directory
out_sub_folders = dir(out_main_dir)

i = 1


lme_summ = NULL
param_summ = NULL
for (i in 1:length(out_sub_folders)) {
  # read in the files from the ith folder
  param_tmp = read.csv(paste(out_main_dir, out_sub_folders[i], "param_summary.csv", sep = "/"), stringsAsFactors = F)
  lme_tmp = read.csv(paste(out_main_dir, out_sub_folders[i], "lme_summary.csv", sep = "/"), stringsAsFactors = F)
  
  # determine the current maximum number iterations (from last folder)
  max_iter = ifelse(i == 1, 0, max(lme_summ$iter))
  
  # adjust the number of iterations based on max_iter
  param_tmp$iter = params_tmp$iter + max_iter
  lme_tmp$iter = lme_tmp$iter + max_iter
  
  # append the previous output file with the temporary ones
  params_summ = rbind(param_summ, param_tmp)
  lme_summ = rbind(lme_summ, lme_tmp)
}

max(params_summ$iter)
max(lme_summ$iter)

# library(dplyr)
# lm_ests = lme_summ %>% filter(param == "U_obj" & method == "lm") %>% select(mean) %>% unlist %>% unname
# lme_ests = lme_summ %>% filter(param == "U_obj" & method == "lme") %>% select(mean) %>% unlist %>% unname
# param_ests = param_summ %>% filter(param == "U_obj")
