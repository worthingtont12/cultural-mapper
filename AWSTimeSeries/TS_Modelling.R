library(tidyr)
library(dplyr)
library(forecast)

temp <- clean.topics %>%
  #filter(lang.topic %in% top_langs$lang.topic[1:20]) %>%
  group_by(lang.topic, time = as.Date(tzone)) %>% 
  count() %>% 
  spread(lang.topic, n) %>%
  arrange(time)

# replace NAs with 0
temp[is.na(temp)] <- 0

# Apply 7-day rolling average
temp_filtered <- apply(temp[,-1],2, stats::filter, rep(1/7,7))

# Rebind to dates
temp_filtered <- cbind(temp$time, as.data.frame(temp_filtered))

# Adapted from https://stat.ethz.ch/pipermail/r-sig-finance/2011q4/008681.html

# ic can be aicc, aic, or bic.
arimaTrace <- function(data, ic = "aicc"){
  require(forecast)
  out <- capture.output({
    fit <- auto.arima(data,ic=ic,trace=T,,stepwise = F, parallel = T)
  })
  fit$trace <- read.table(t <- textConnection(out), sep=":", col.names = c("model",ic)) %>% arrange(AIC)
  close(t)
  fit
}

# Apply to all the columns, save the date
models <- apply(temp[,-1], 2, arimaTrace)

# Apply to the smoothed version
smooth.models <- apply(temp_filtered[,-1], 2, arimaTrace)


extract_coefs <- function(models){
  coefs <- as.data.frame(matrix(NA, nrow = length(names(models)), ncol = 12))
  names(coefs) <- c("topic", "p","d","q","ar1","ar2","ar3","ar4","ma1","ma2","ma3","ma4")
  coefs$topic <- names(models)
  for (i in 1:length(models)){
    coefs$ar1[i] <- models[[i]][[1]]["ar1"]
    coefs$ar2[i] <- models[[i]][[1]]["ar2"]
    coefs$ar3[i] <- models[[i]][[1]]["ar3"]
    coefs$ar4[i] <- models[[i]][[1]]["ar4"]
    coefs$ma1[i] <- models[[i]][[1]]["ma1"]
    coefs$ma2[i] <- models[[i]][[1]]["ma2"]
    coefs$ma3[i] <- models[[i]][[1]]["ma3"]
    coefs$ma4[i] <- models[[i]][[1]]["ma4"]
    coefs$p[i] <- models[[i]][["arma"]][1]
    coefs$d[i] <- models[[i]][["arma"]][6]
    coefs$q[i] <- models[[i]][["arma"]][2]
  }
  coefs
}

coefs <- extract_coefs(models)
smooth.coefs <- extract_coefs(smooth.models)

write.csv(coefs,"model_coefficients.csv")
write.csv(smooth.coefs,"smooth_model_coefficients.csv")