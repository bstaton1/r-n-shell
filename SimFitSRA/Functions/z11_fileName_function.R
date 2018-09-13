
fileName = function(base, sub, ext) {
  sep = if(is.null(sub)) NULL else "_"
  paste(base, sep, sub, ext, sep = "")
}
