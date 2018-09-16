# take the many separate .csv files and combine them into saved R objects

# the main folder that houses the output
out_folder = "Output"

# the full file path there
out_dir = paste(getwd(), out_folder, sep = "/")

# the individual file names for each type
out_files = dir(out_dir)
first3 = substr(out_files, 1, 3) == "lme"
last3 = substr(out_files, nchar(out_files) - 2, nchar(out_files))
lme_files = out_files[first3 == "lme" & last3 == ".csv"]
tsm_files = out_files[first3 == "tsm" & last3 == ".csv"]
param_files = out_files[first3 == "par" & last3 == ".csv"]

# the seeds that were saved for each type
lme_seeds = unlist(as.numeric(regmatches(lme_files, gregexpr("[[:digit:]]+", lme_files))))
tsm_seeds = unlist(as.numeric(regmatches(tsm_files, gregexpr("[[:digit:]]+", tsm_files))))
param_seeds = unlist(as.numeric(regmatches(param_files, gregexpr("[[:digit:]]+", param_files))))

# the seeds saved across all types
seeds = unique(c(lme_seeds, tsm_seeds, param_seeds))
n = length(seeds)

# loop over these unique seeds:
lme_summ = NULL
param_summ = NULL
tsm_summ = NULL
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
  
  if (seeds[i] %in% tsm_seeds) {
    tsm_tmp = read.csv(paste(out_dir, tsm_files[tsm_seeds == seeds[i]], sep = "/"), stringsAsFactors = F)
    tsm_tmp$iter = i
  } else {
    tsm_tmp = data.frame(seed = seeds[i], 
                         param = NA, stock = NA, method = "tsm",
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
  tsm_summ = rbind(tsm_summ, tsm_tmp)
}

# delete the intermediate files
# unlink(x = paste(out_dir, param_files[i], sep = "/"), recursive = T)
# unlink(x = paste(out_dir, lme_files[i], sep = "/"), recursive = T)
# unlink(x = paste(out_dir, tsm_files[i], sep = "/"), recursive = T)

# save the output as environment objects
save(param_summ, file = paste(out_dir, "param_summ", sep = "/"))
save(lme_summ, file = paste(out_dir, "lme_summ", sep = "/"))
save(tsm_summ, file = paste(out_dir, "tsm_summ", sep = "/"))
