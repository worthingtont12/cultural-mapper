"""Time Series Analysis of Topic Analysis for Final Paper."""
import statistics as stat
import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

# import data
from Cleaning import fulldf

# group together topics by cluster assignment and date
Users = fulldf.groupby(['Date1', 'Cluster', 'top_topic'])[
    'topic_percentage'].aggregate(sum).unstack()

# Create a df that gives the median of all the topic sums for each cluster on each day
Dates = []
Clusters = []
Medians = []
for i in range(len(Users)):
    Date = Users.index[i][0]
    Cluster = Users.index[i][1]
    Median_Count = np.nanmedian(Users.values[i],)
    print(Date, Cluster, Median_Count)
    Dates.append(Date)
    Clusters.append(Cluster)
    Medians.append(Median_Count)
df = pd.DataFrame()
df["Date"] = Dates
df["Cluster"] = Clusters
df["Median_Counts"] = Medians

# Cluster 1 time series
df_cluster1 = df[df.Cluster == 1]  # subset by cluster assignment
cluster1_series = pd.Series(df_cluster1["Median_Counts"].as_matrix(), index=df_cluster1["Date"])
cluster1_series.describe()
# Cluster 2 time series
df_cluster2 = df[df.Cluster == 2]
cluster2_series = pd.Series(df_cluster2["Median_Counts"].as_matrix(), index=df_cluster2["Date"])
cluster2_series.describe()
# Cluster 3 time series
df_cluster3 = df[df.Cluster == 3]
cluster3_series = pd.Series(df_cluster3["Median_Counts"].as_matrix(), index=df_cluster3["Date"])
cluster3_series.describe()
# Cluster 4 time series
df_cluster4 = df[df.Cluster == 4]
cluster4_series = pd.Series(df_cluster4["Median_Counts"].as_matrix(), index=df_cluster4["Date"])
cluster4_series.describe()
# Cluster 5 time series
df_cluster5 = df[df.Cluster == 5]
cluster5_series = pd.Series(df_cluster5["Median_Counts"].as_matrix(), index=df_cluster5["Date"])
cluster5_series.describe()

######################Plotting Entire Time Series With Rolling Average Plots###########
# specifing figure size and pixel ratio
fig = plt.figure(figsize=(8, 3.75), dpi=300)
ts = fig.add_subplot(1, 1, 1)

# format of xlabel
plt.xlabel('Date', fontsize='small')

# format of ylabel
plt.ylabel('Median Tweets Per User in Community', fontsize=8)
plt.ylim(ymax=.8, ymin=0)

# Time series plots of raw values with roling averages
fig = cluster1_series.plot(color="forestgreen", label='Cluster 1')
fig = cluster1_series.rolling(window=7, center=False).mean().plot(
    color='lightgreen', linestyle='dashed', label='Cluster 1 Rolling 7 Day Mean')

fig = cluster2_series.plot(color='royalblue', label='Cluster 2')
fig = cluster2_series.rolling(window=7, center=False).mean().plot(
    color='cornflowerblue', linestyle='dashed', label='Cluster 2 Rolling 7 Day Mean')

fig = cluster3_series.plot(color='indigo', label='Cluster 3')
fig = cluster3_series.rolling(window=7, center=False).mean().plot(
    color='darkorchid', linestyle='dashed', label='Cluster 3 Rolling 7 Day Mean')

fig = cluster4_series.plot(color='#ff7f00', label='Cluster 4')
fig = cluster4_series.rolling(window=7, center=False).mean().plot(
    color='#fc8d62', linestyle='dashed', label='Cluster 4 Rolling 7 Day Mean')

fig = cluster5_series.plot(color='indianred', label='Cluster 5')
fig = cluster5_series.rolling(window=7, center=False).mean().plot(
    color='lightcoral', linestyle='dashed', label='Cluster 5 Rolling 7 Day Mean')
# legend
fig = ts.legend(loc='best', prop={'size': 4})

# save plot
plt.savefig("Graphs/LA/Final_Rollingandpercentage.png", dpi=300)
plt.close()

#########Day of the week plots##########
# map date to day of the week
df['Day of Week'] = df['Date'].apply(lambda row: row.weekday())

# Mapping integer result from before to name of day
map_days = {0: "Monday", 1: "Tuesday", 2: "Wednesday",
            3: "Thursday", 4: "Friday", 5: "Saturday", 6: "Sunday"}
df['Day of Week'] = df['Day of Week'].map(map_days)

# sort by day of the week
df = df.sort_values(by='Day of Week')

# filter out outlier days ie Election Day , World Series
df1 = df[df.Date != '2016-11-09']
df1 = df[df.Date != '2016-11-02']

# ##### Day of the Week Series#####
# cluster 1
# before outliers filtered out
cluster1 = df[df.Cluster == 1]
series1 = cluster1.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
series1 = series1[['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']]

# after outliers filtered out
df1_cluster1 = df1[df1.Cluster == 1]
dow_series1 = df1_cluster1.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
dow_series1 = dow_series1[['Monday', 'Tuesday', 'Wednesday',
                           'Thursday', 'Friday', 'Saturday', 'Sunday']]

# cluster 2
# before outliers filtered out
cluster2 = df[df.Cluster == 2]
series2 = cluster2.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
series2 = series2[['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']]

# after outliers filtered out
df1_cluster2 = df1[df1.Cluster == 2]
dow_series2 = df1_cluster2.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
dow_series2 = dow_series2[['Monday', 'Tuesday', 'Wednesday',
                           'Thursday', 'Friday', 'Saturday', 'Sunday']]

# cluster 3
# before outliers filtered out
cluster3 = df[df.Cluster == 3]
series3 = cluster3.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
series3 = series3[['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']]

# after outliers filtered out
df1_cluster3 = df1[df1.Cluster == 3]
dow_series3 = df1_cluster3.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
dow_series3 = dow_series3[['Monday', 'Tuesday', 'Wednesday',
                           'Thursday', 'Friday', 'Saturday', 'Sunday']]

# cluster 4
# before outliers filtered out
cluster4 = df[df.Cluster == 4]
series4 = cluster4.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
series4 = series4[['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']]

# after outliers filtered out
df1_cluster4 = df1[df1.Cluster == 4]
dow_series4 = df1_cluster4.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
dow_series4 = dow_series4[['Monday', 'Tuesday', 'Wednesday',
                           'Thursday', 'Friday', 'Saturday', 'Sunday']]

# cluster 5
# before outliers filtered out
cluster5 = df[df.Cluster == 5]
series5 = cluster5.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
series5 = series5[['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']]

# after outliers filtered out
df1_cluster5 = df1[df1.Cluster == 5]
dow_series5 = df1_cluster5.groupby(['Day of Week'])[
    'Median_Counts'].aggregate(stat.mean)
dow_series5 = dow_series5[['Monday', 'Tuesday', 'Wednesday',
                           'Thursday', 'Friday', 'Saturday', 'Sunday']]


# Day of Week Plot
# specify plot size
fig = plt.figure(figsize=(20, 10))
ts = fig.add_subplot(1, 1, 1)

# xlabel
plt.xlabel('Day of Week')

# ylabel
plt.ylabel('Median Tweets Per User in Community')

# Cluster 1 Before and After Filtering
series1.plot(color='steelblue', label='Cluster 1')
dow_series1.plot(color='steelblue', linestyle='dashed', label='Cluster 1: After Outliers Removed')

# Cluster 2 Before and After Filtering
series2.plot(color='indigo', label='Cluster 2')
dow_series2.plot(color='indigo', linestyle='dashed', label='Cluster 2: After Outliers Removed')

# Cluster 3 Before and After Filtering
series3.plot(color='forestgreen', label='Cluster 3')
dow_series3.plot(color='forestgreen', linestyle='dashed', label='Cluster 3: After Outliers Removed')

# Cluster 4 Before and After Filtering
series4.plot(color='indianred', label='Cluster 4')
dow_series4.plot(color='indianred', linestyle='dashed', label='Cluster 4: After Outliers Removed')

# Cluster 5 Before and After Filtering
series5.plot(color='royalblue', label='Cluster 5')
dow_series5.plot(color='royalblue', linestyle='dashed', label='Cluster 5: After Outliers Removed')

# legend
fig = ts.legend(loc='best')

# save plot
plt.savefig("Graphs/LA/Final_Day_of_The_Week.png")
