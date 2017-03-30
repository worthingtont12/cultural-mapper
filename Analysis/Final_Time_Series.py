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
%matplotlib inline
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
df_cluster1 = df[df.Cluster == 1]
cluster1_series = pd.Series(df_cluster1["Median_Counts"].as_matrix(), index=df_cluster1["Date"])

# Cluster 2 time series
df_cluster2 = df[df.Cluster == 2]
cluster2_series = pd.Series(df_cluster2["Median_Counts"].as_matrix(), index=df_cluster2["Date"])

# Cluster 3 time series
df_cluster3 = df[df.Cluster == 3]
cluster3_series = pd.Series(df_cluster3["Median_Counts"].as_matrix(), index=df_cluster3["Date"])

# Cluster 4 time series
df_cluster4 = df[df.Cluster == 4]
cluster4_series = pd.Series(df_cluster4["Median_Counts"].as_matrix(), index=df_cluster4["Date"])

# Cluster 5 time series
df_cluster5 = df[df.Cluster == 5]
cluster5_series = pd.Series(df_cluster5["Median_Counts"].as_matrix(), index=df_cluster5["Date"])

######################Plotting Entire Time Series With Rolling Average Plots###########
fig = plt.figure(figsize=(20, 10))
ts = fig.add_subplot(1, 1, 1)
plt.xlabel('Date')
plt.ylabel('Average Tweets Per User in Community')
plt.title('Comparing Topic Activity in Istanbul')
fig = cluster1_series.plot(color="forestgreen", label='Cluster 1')
fig = cluster1_series.rolling(window=7, center=False).mean().plot(
    color='lightgreen', linestyle='dashed', label='Cluster 1 Rolling 7 Day Mean')

fig = cluster2_series.plot(color='royalblue', label='Cluster 2')
fig = cluster2_series.rolling(window=7, center=False).mean().plot(
    color='cornflowerblue', linestyle='dashed', label='Cluster 2 Rolling 7 Day Mean')

fig = cluster3_series.plot(color='indigo', label='Cluster 3')
fig = cluster3_series.rolling(window=7, center=False).mean().plot(
    color='darkorchid', linestyle='dashed', label='Cluster 3 Rolling 7 Day Mean')

fig = cluster4_series.plot(color='steelblue', label='Cluster 4')
fig = cluster4_series.rolling(window=7, center=False).mean().plot(
    color='lightskyblue', linestyle='dashed', label='Cluster 4 Rolling 7 Day Mean')

fig = cluster5_series.plot(color='indianred', label='Cluster 5')
fig = cluster5_series.rolling(window=7, center=False).mean().plot(
    color='lightcoral', linestyle='dashed', label='Cluster 5 Rolling 7 Day Mean')
fig = ts.legend(loc='best')
plt.savefig("Graphs/Istanbul/Rollingandpercentage.png")
plt.close()

# Day of the week plots
df['Day of Week'] = df['Date'].apply(lambda row: row.weekday())

# Mapping integer to name of day
map_days = {0: "Monday", 1: "Tuesday", 2: "Wednesday",
            3: "Thursday", 4: "Friday", 5: "Saturday", 6: "Sunday"}

df['Day of Week'] = df['Day of Week'].map(map_days)

# Day of Week Plot
plt.xlabel('Day of Week')
plt.ylabel('Average Tweets Per User in Community')
plt.title('Comparing Topic Activity in Istanbul')
dayoftheweek = sns.factorplot(x="Day of Week", y="Median_Counts",
                              hue="Cluster", data=df, size=5)
dayoftheweek.set_xticklabels(rotation=90)
dayoftheweek = ts.legend(loc='best')
plt.savefig("Graphs/Istanbul/Day_of_The_Week.png")
