
# attach(params); attach(obs)
# detach(params); detach(obs)

obs_filter = function(params, obs) {
  
  output = with(append(params, obs), {
    
    ### ESCAPEMENT OBSERVATION FILTERING ###
    S_ts_obs_filtered = S_ts_obs
    # S_ts_obs_filtered = matrix(0, nt, ns)
    
    # proportion of substocks getting each sampling frequency
    p100 = 0.25
    p_hi = 0.25
    p_low = 0.5
    
    # shuffle them across stocks
    sample_types = sample(c(rep("all", p100 * ns),rep("low", p_low * ns),rep("hi", p_hi * ns)))
    
    # matrix of observed years for each stock
    NA_yrs = sapply(sample_types, function(x) !as.logical(sample_TS(type = x, minRobs = 5)))
    # S_ts_obs_filtered[NA_yrs] = NA
    
    for (s in 1:ns) {
      S_ts_obs_filtered[NA_yrs[,s],s] = NA
    }
    
    ### AGE COMP DATA FILTERING ###
    age_comp_stocks = which(sample_types %in% c("all","hi"))
    x_tas_obs_filtered = array(NA, dim = c(nt, na, length(age_comp_stocks)))
    for (s in 1:length(age_comp_stocks)) {
      x_tas_obs_filtered[!NA_yrs[,age_comp_stocks[s]],,s] = 
        x_tas_obs[!NA_yrs[,age_comp_stocks[s]],,age_comp_stocks[s]]
    }
    # x_tas_obs_filtered[is.na(x_tas_obs_filtered)] = 0
    
    # return output
    list(
      S_ts_obs_filtered = S_ts_obs_filtered,
      x_tas_obs_filtered = x_tas_obs_filtered,
      age_comp_stocks = age_comp_stocks
    )
    
  })
  
  # change out the full observed time series with the filtered time series
  obs$S_ts_obs = output$S_ts_obs_filtered
  obs$x_tas_obs = output$x_tas_obs_filtered
  obs$age_comp_stocks = output$age_comp_stocks
  
  return(obs)
}

count_obs_y = function(x) {
  N_ta = matrix(1, length(x), ncol = 4)
  N_ta[x == 0,] = NA
  
  nt = length(x)
  na = 4
  a_max = 7
  ny = nt + na - 1
  R_y = rep(NA, ny)
  for (y in 1:ny) {
    if (y <= (nt - 4)) {
      brd.yr.runs = diag(N_ta[y:(y+na),])
      R_y[y+na-1] = sum(brd.yr.runs, na.rm = all(!is.na(brd.yr.runs)))
    } else {
      next()
    }
  }
  
  S_ind = 1:(nt - a_max - 1)
  R_ind = (a_max + 1):(ny - na)
  
  sum(!is.na(x[S_ind]) & !is.na(R_y[R_ind]))
}

## other functions to help with sampling the time series
sample_TS = function(type = "low", minRobs = 3) {
  dat = read.csv("S_Ests_Kusko.csv")
  nt = length(unique(dat$year))
  
  if (type == "all") {
    x = rep(1, nt)
  } else {
    # dimensionals
    na = 4
    ny = nt + na - 1
    ns = length(unique(dat$stock))
    size = 7
    
    dat$stratum = rep(rep(1:ceiling(nt/size), each = size), ns)
    counts = with(dat, tapply(obs, list(stratum, stock), sum))
    
    # if have more than 50% of years obs, type == "hi"
    p_obs = colSums(counts)/nt
    stocks_low = names(p_obs[p_obs < 0.5])
    stocks_hi = names(p_obs[p_obs > 0.5])
    
    counts = reshape2::melt(counts)
    colnames(counts) = c("stratum", "stock", "count")
    counts = cbind(counts, nocount = 7 - counts$count)
    counts$type = ifelse(counts$stock %in% stocks_low, "low", "hi")
    
    fit = glm(cbind(count, nocount) ~ stratum * type,
              data = subset(counts, type == type), family = binomial)
    
    # funciton to generate the years sampled in a strata for a stock
    sample_strata = function(fit, stratum) {
      # obtain probability any year in this strata was sampled
      p = predict(fit, 
                  newdata = data.frame(stratum = stratum),
                  type = "response")
      
      # generate the vector
      rbinom(n = 7, size = 1, prob = p)
    }
    
    # create the time series sampled
    # if the number of SR pair years is less than a threshold, try again
    x = rep(0, nt)
    i = 1
    while(count_obs_y(x) < minRobs) {
      # cat("\r", i)
      x = as.numeric(sapply(1:6, function(s) sample_strata(fit, s)))
      i = i + 1
    }
  }
  x
}

