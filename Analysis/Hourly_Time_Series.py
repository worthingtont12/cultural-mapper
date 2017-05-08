"""Analyzing The Hourly Trends of each Cluster."""
import statistics as stat
import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

# import data
from Cleaning import fulldf

# create new variable for Hour of day
fulldf['Hour'] = fulldf['Time'].apply(lambda row: (row[0:2]))

# group together topics by cluster assignment and hour of day
Users = fulldf.groupby(['Hour', 'Cluster', 'top_topic'])[
    'topic_percentage'].aggregate(sum).unstack()

# Create a df that gives the median of all the topic sums for each cluster on each hour
Hours = []
Clusters = []
Medians = []
for i in range(len(Users)):
    Hour = Users.index[i][0]
    Cluster = Users.index[i][1]
    Median_Count = np.nanmedian(Users.values[i],)
    print(Hour, Cluster, Median_Count)
    Hours.append(Hour)
    Clusters.append(Cluster)
    Medians.append(Median_Count)
df = pd.DataFrame()
df["Hour of Day"] = Hours
df["Cluster"] = Clusters
df["Median_Counts"] = Medians


# Cluster 1 time series
df_cluster1 = df[df.Cluster == 1]  # subset by cluster assignment
cluster1_series = pd.Series(
    df_cluster1["Median_Counts"].as_matrix(), index=df_cluster1["Hour of Day"])
cluster1_series.describe()
# Cluster 2 time series
df_cluster2 = df[df.Cluster == 2]
cluster2_series = pd.Series(
    df_cluster2["Median_Counts"].as_matrix(), index=df_cluster2["Hour of Day"])
cluster2_series.describe()
# Cluster 3 time series
df_cluster3 = df[df.Cluster == 3]
cluster3_series = pd.Series(
    df_cluster3["Median_Counts"].as_matrix(), index=df_cluster3["Hour of Day"])
cluster3_series.describe()
# Cluster 4 time series
df_cluster4 = df[df.Cluster == 4]
cluster4_series = pd.Series(
    df_cluster4["Median_Counts"].as_matrix(), index=df_cluster4["Hour of Day"])
cluster4_series.describe()
# Cluster 5 time series
df_cluster5 = df[df.Cluster == 5]
cluster5_series = pd.Series(
    df_cluster5["Median_Counts"].as_matrix(), index=df_cluster5["Hour of Day"])
cluster5_series.describe()

#########Hourly Plots##########
# specifing figure size and pixel ratio
fig = plt.figure(dpi=300)
ts = fig.add_subplot(1, 1, 1)

# format of xlabel
plt.xlabel('Hour of Day', fontsize='small')

# format of ylabel
plt.ylabel('Median Tweets Per User in Community', fontsize=8)
plt.ylim(ymax=3, ymin=0)

# Time series plots of raw values with roling averages
fig = cluster1_series.plot(color="forestgreen", label='Cluster 1')

fig = cluster2_series.plot(color='royalblue', label='Cluster 2')

fig = cluster3_series.plot(color='indigo', label='Cluster 3')

fig = cluster4_series.plot(color='#ff7f00', label='Cluster 4')

fig = cluster5_series.plot(color='indianred', label='Cluster 5')
# legend
fig = ts.legend(loc='best')

# save plot
plt.savefig("Graphs/Chicago/Final_Rollingandpercentage_byhour.png", dpi=300)
plt.close()
