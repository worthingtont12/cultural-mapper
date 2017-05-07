library(forecast)
library(ggplot2)

gglagplot(ts.test)

autoplot(stl(ts.test, "per"))
autoplot(Acf(ts.test))
Ccf(ts.test,ts.test3)
autoplot(ts.test)




fit <- auto.arima(ts.test2)
fit
autoplot(fit)

# Plot with the model
autoplot(ts.test2) + geom_line(data = fit$fitted, aes(color = "red"))

# Make sure residual Autocorrelation is not significant
autoplot(Acf(fit$residuals))

residuals.Arima(fit)

