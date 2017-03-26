library(forecast)

ts.test <- ts(counts$`Topic 0 - English`, freq = 7)
ts.test2 <- ts(counts$`Topic 0 - Turkish`, freq  = 7)
ts.test3 <- ts(counts$`Topic 1 - Turkish`, freq  = 7)

# Plot with a 4 day ksmooth curve
plot(ts.test)
lines(ksmooth(1:length(ts.test), ts.test, 'normal', bandwidth = 4), col = 'red', lty = 2)

plot(stl(ts.test, "per"))

Acf(ts.test2)
Pacf(ts.test2)
lag.plot(ts.test, lags = 7)

fit <- auto.arima(ts.test2)
fit

Ccf(ts.test3, ts.test2)


trend = ma(ts.test,order = 7, centre = T)
plot(ts.test)
lines(trend)

library(TSA)
scatter.smooth(fit$residuals)
scatter.smooth(rstandard(fit))

# Number of differences required to make a series stationary
ndiffs(ts.test)
# Number of SEASONAL differences required to make a series stationary
nsdiffs(ts.test)
auto.arima(ts.test2)

Ccf(diff(ts.test), ts.test3)
