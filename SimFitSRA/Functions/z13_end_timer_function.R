end_timer = function(start, ctime) {
  end = Sys.time(); elapsed = round(as.numeric(end - start, units = "hours"), 2)
  ctime = sum(c(ctime, elapsed))
  if (time_verbose) cat("    Hours Elapsed: ", elapsed, "; Total Hours Elapsed: ", ctime, "\n", sep = "")

  ctime
}
