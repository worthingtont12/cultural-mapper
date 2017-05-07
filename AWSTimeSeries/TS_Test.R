library(forecast)

ts.test <- ts(counts$`Topic 0 - English`, freq = 7)
ts.test2 <- ts(counts$`Topic 0 - Turkish`, freq  = 7)
ts.test3 <- ts(counts$`Topic 1 - Turkish`, freq  = 7)

# Plot with a 4 day ksmooth curve
plot(ts.test)
lines(ksmooth(1:length(ts.test), ts.test, 'normal', bandwidth = 4), col = 'red', lty = 2)

#Decompose time series
plot(stl(ts.test, "per"))

Acf(ts.test2)
Pacf(ts.test2)
lag.plot(ts.test3, lags = 7)

fit <- auto.arima(ts.test2)
fit

Ccf(ts.test3, ts.test2) 



trend = ma(ts.test,order = 7, centre = T)
plot(ts.test)
lines(trend)


autoplot.Arima(fit)
autoplot.decomposed.ts(ts.test3)



library(TSA)
scatter.smooth(fit$residuals)
scatter.smooth(rstandard(fit))

# Number of differences required to make a series stationary
ndiffs(ts.test)
# Number of SEASONAL differences required to make a series stationary
nsdiffs(ts.test)
auto.arima(ts.test3)

Ccf(ts.test, ts.test3)
Pacf(ts.test3)

fit <- auto.arima(ts.test3)
fit
plot(fit$fitted)
Acf(fit$residuals)
