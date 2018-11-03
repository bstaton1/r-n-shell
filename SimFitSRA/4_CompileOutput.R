rm(list = ls(all = T))

# take the many separate .csv files and combine them into saved R objects
extract_numbers = function(string, follow = NULL, as.num = F) {
  x = unlist(regmatches(string, gregexpr(paste("[[:digit:]]+", follow, sep = ""), string)))
  if (as.num) {
    as.numeric(x)
  } else {
    x
  }
}

# the main folder that houses the output
out_folder = "Output"

# the full file path there
out_dir = paste(getwd(), out_folder, sep = "/")

# the individual file names for each type
out_files = dir(out_dir)
first3 = substr(out_files, 1, 3)
last3 = substr(out_files, nchar(out_files) - 2, nchar(out_files))
lme_files = out_files[first3 == "lme" & last3 == "csv"]
tsm_files = out_files[first3 == "tsm" & last3 == "csv"]
tsm_1_files = tsm_files[substr(tsm_files, 5, 5) == 1]
tsm_2_files = tsm_files[substr(tsm_files, 5, 5) == 2]
tsm_3_files = tsm_files[substr(tsm_files, 5, 5) == 3]
tsm_4_files = tsm_files[substr(tsm_files, 5, 5) == 4]
param_files = out_files[first3 == "par" & last3 == "csv"]

# the seeds that were saved for each type
lme_seeds = extract_numbers(lme_files, as.num = T)
tsm_1_seeds = extract_numbers(extract_numbers(tsm_1_files, follow = ".csv"), as.num = T)
tsm_2_seeds = extract_numbers(extract_numbers(tsm_2_files, follow = ".csv"), as.num = T)
tsm_3_seeds = extract_numbers(extract_numbers(tsm_3_files, follow = ".csv"), as.num = T)
tsm_4_seeds = extract_numbers(extract_numbers(tsm_4_files, follow = ".csv"), as.num = T)
param_seeds = extract_numbers(param_files, as.num = T)

# the seeds saved across all types
seeds = sort(unique(c(lme_seeds, tsm_1_seeds, tsm_2_seeds, tsm_3_seeds, tsm_4_seeds, param_seeds)))
n = length(seeds)

# loop over these unique seeds:
lme_summ = NULL
param_summ = NULL
tsm_1_summ = NULL
tsm_2_summ = NULL
tsm_3_summ = NULL
tsm_4_summ = NULL

i = 2

for (i in 1:n) {
  
  if (seeds[i] %in% lme_seeds) {
    lme_tmp = read.csv(paste(out_dir, lme_files[lme_seeds == seeds[i]], sep = "/"), stringsAsFactors = F)
    lme_tmp$iter = i
  } else {
    lme_tmp = data.frame(seed = seeds[i], 
                         param = NA, stock = NA, method = c("lme", "lm"),
                         mean = NA, sd = NA, "X50." = NA, "X2.5." = NA, "X97.5." = NA, 
                         bgr = NA, ess = NA, iter = i)
  }
  
  if (seeds[i] %in% tsm_1_seeds) {
    tsm_1_tmp = read.csv(paste(out_dir, tsm_1_files[tsm_1_seeds == seeds[i]], sep = "/"), stringsAsFactors = F)
    tsm_1_tmp$iter = i
  } else {
    tsm_1_tmp = data.frame(seed = seeds[i], 
                         param = NA, stock = NA, method = "tsm1",
                         mean = NA, sd = NA, "X50." = NA, "X2.5." = NA, "X97.5." = NA, 
                         bgr = NA, ess = NA, iter = i)
  }
  
  if (seeds[i] %in% tsm_2_seeds) {
    tsm_2_tmp = read.csv(paste(out_dir, tsm_2_files[tsm_2_seeds == seeds[i]], sep = "/"), stringsAsFactors = F)
    tsm_2_tmp$iter = i
  } else {
    tsm_2_tmp = data.frame(seed = seeds[i], 
                           param = NA, stock = NA, method = "tsm2",
                           mean = NA, sd = NA, "X50." = NA, "X2.5." = NA, "X97.5." = NA, 
                           bgr = NA, ess = NA, iter = i)
  }
  
  if (seeds[i] %in% tsm_3_seeds) {
    tsm_3_tmp = read.csv(paste(out_dir, tsm_3_files[tsm_3_seeds == seeds[i]], sep = "/"), stringsAsFactors = F)
    tsm_3_tmp$iter = i
  } else {
    tsm_3_tmp = data.frame(seed = seeds[i], 
                           param = NA, stock = NA, method = "tsm3",
                           mean = NA, sd = NA, "X50." = NA, "X2.5." = NA, "X97.5." = NA, 
                           bgr = NA, ess = NA, iter = i)
  }
  
  if (seeds[i] %in% tsm_4_seeds) {
    tsm_4_tmp = read.csv(paste(out_dir, tsm_4_files[tsm_4_seeds == seeds[i]], sep = "/"), stringsAsFactors = F)
    tsm_4_tmp$iter = i
  } else {
    tsm_4_tmp = data.frame(seed = seeds[i], 
                           param = NA, stock = NA, method = "tsm4",
                           mean = NA, sd = NA, "X50." = NA, "X2.5." = NA, "X97.5." = NA, 
                           bgr = NA, ess = NA, iter = i)
  }
  
  if (seeds[i] %in% param_seeds) {
    param_tmp = read.csv(paste(out_dir, param_files[param_seeds == seeds[i]], sep = "/"), stringsAsFactors = F)
    param_tmp$iter = i
  } else {
    param_tmp = data.frame(seed = seeds[i], stock = NA, param = NA, value = NA, iter = i)
  }
  
  lme_summ = rbind(lme_summ, lme_tmp)
  param_summ = rbind(param_summ, param_tmp)
  tsm_1_summ = rbind(tsm_1_summ, tsm_1_tmp)
  tsm_2_summ = rbind(tsm_2_summ, tsm_2_tmp)
  tsm_3_summ = rbind(tsm_3_summ, tsm_3_tmp)
  tsm_4_summ = rbind(tsm_4_summ, tsm_4_tmp)
}



# tsm_2_summ[is.na(tsm_2_summ$param),]

# delete the intermediate files
# unlink(x = paste(out_dir, param_files[i], sep = "/"), recursive = T)
# unlink(x = paste(out_dir, lme_files[i], sep = "/"), recursive = T)
# unlink(x = paste(out_dir, tsm_files[i], sep = "/"), recursive = T)

# save the output as environment objects
save(param_summ, file = paste(out_dir, "param_summ", sep = "/"))
# if (length(lme_1_seeds) > 0) save(lme_summ, file = paste(out_dir, "lme_summ", sep = "/"))
# if (length(tsm_1_seeds) > 0) save(tsm_1_summ, file = paste(out_dir, "tsm_1_summ", sep = "/"))
# if (length(tsm_2_seeds) > 0) save(tsm_2_summ, file = paste(out_dir, "tsm_2_summ", sep = "/"))
# if (length(tsm_3_seeds) > 0) save(tsm_3_summ, file = paste(out_dir, "tsm_3_summ", sep = "/"))
# if (length(tsm_4_seeds) > 0) save(tsm_4_summ, file = paste(out_dir, "tsm_4_summ", sep = "/"))
save(lme_summ, file = paste(out_dir, "lme_summ", sep = "/"))
save(tsm_1_summ, file = paste(out_dir, "tsm_1_summ", sep = "/"))
save(tsm_2_summ, file = paste(out_dir, "tsm_2_summ", sep = "/"))
save(tsm_3_summ, file = paste(out_dir, "tsm_3_summ", sep = "/"))
save(tsm_4_summ, file = paste(out_dir, "tsm_4_summ", sep = "/"))
