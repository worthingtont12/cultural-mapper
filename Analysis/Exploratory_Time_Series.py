"""Exploratory Time Series Analysis of Topic Activity"""
import pandas as pd
from pandas.tools.plotting import lag_plot
import statsmodels.api as sm
from matplotlib import pyplot as plt

# Time series
import scipy.fftpack
from statsmodels.tsa.stattools import adfuller
from statsmodels.tsa.arima_model import ARIMA

# data
from Cleaning import fulldf


def test_stationarity(timeseries):
    """
    Simplification of the adfuller function in the statsmodels module to only display necessary statistics.
    """
    # Perform Dickey-Fuller test:
    print('Dickey-Fuller Test:')
    dftest = adfuller(timeseries, autolag='AIC')
    dfoutput = pd.Series(dftest[0:4], index=['Test Statistic', 'p-value',
                                             '#Lags Used', 'Number of Observations Used'])
    for key, value in dftest[4].items():
        dfoutput['Critical Value (%s)' % key] = value
    print(dfoutput)

# dropping first day of series
fulldf = fulldf[fulldf.Date1 != '2016-10-28']

# cast to string
fulldf["top_topic"] = fulldf["top_topic"].apply(str)

# list of 20 topics
topics = (fulldf["top_topic"].unique())
topics = list(topics)

# loop through all topics to create graphs for each
for i in topics:
    print("################Topic" + str(i) + "Results#################")

    # subset where topic equals i
    tempdf = fulldf[fulldf.top_topic == str(i)]

    # summing tweets for all days
    Users = tempdf.groupby(['Date1'])['count'].aggregate(sum)

    # descriptive statistics
    print(Users.describe())

    # density plots
    Users.plot(kind='kde')
    plt.savefig("Graphs/Chicago/Time_Series/density_Topic" + str(i) + ".png")
    plt.close()

    # bar graphs
    Users.hist()
    plt.savefig("Graphs/Chicago/Time_Series/histogram_Topic" + str(i) + ".png")
    plt.close()

    # rolling average plots
    fig = plt.figure(figsize=(10, 10))
    ts = fig.add_subplot(1, 1, 1)
    fig = Users.plot(label='Users')
    fig = Users.rolling(window=3, center=False).mean().plot(label='Rolling 3 Day Mean')
    fig = Users.rolling(window=6, center=False).mean().plot(label='Rolling 7 Day Mean')
    fig = Users.rolling(window=12, center=False).mean().plot(label='Rolling 14 Day Mean')
    fig = ts.legend(loc='best')
    plt.savefig("Graphs/Chicago/Time_Series/Rolling_Average_Plots_Topic" + str(i) + ".png")
    plt.close()

    # ACF and PACF plots
    fig = plt.figure(figsize=(10, 10))
    ax1 = fig.add_subplot(211)
    fig = sm.graphics.tsa.plot_acf(Users, lags=40, ax=ax1)
    ax2 = fig.add_subplot(212)
    fig = sm.graphics.tsa.plot_pacf(Users, lags=40, ax=ax2)
    plt.savefig("Graphs/Chicago/Time_Series/acf_pacf_plot_Topic" + str(i) + ".png")
    plt.close()

    # testing stationarity
    print(test_stationarity(Users))

    # Differenced ACF and PACF plots
    Usersdiff = Users.diff(periods=7)
    test_stationarity(Usersdiff.dropna(inplace=False))
    fig = plt.figure(figsize=(12, 8))
    ax1 = fig.add_subplot(211)
    fig = sm.graphics.tsa.plot_acf(Usersdiff.dropna(inplace=False), lags=40, ax=ax1)
    ax2 = fig.add_subplot(212)
    fig = sm.graphics.tsa.plot_pacf(Usersdiff.dropna(inplace=False), lags=40, ax=ax2)
    plt.savefig("Graphs/Chicago/Time_Series/Differenced_acf_pacf_plot_Topic" + str(i) + ".png")
    plt.close()

    # lag plot
    lag_plot(Usersdiff)
    plt.savefig("Graphs/Chicago/Time_Series/lag_plot_Topic" + str(i) + ".png")
    plt.close()

    # ARIMA model testing 1st lag
    mod1 = ARIMA(Usersdiff.dropna(inplace=False), order=(1, 1, 0))
    results = mod1.fit()
    print(results.summary())

    # plot of residual
    fit_AR = mod1.fit(disp=-1)
    plt.plot(Usersdiff.dropna(inplace=False))
    plt.plot(fit_AR.fittedvalues + Usersdiff.dropna(inplace=False).mean(), color='red')
    plt.title('Model Fit')
    plt.savefig("Graphs/Chicago/Time_Series/fitted_plot_Topic" + str(i) + ".png")
    plt.close()
