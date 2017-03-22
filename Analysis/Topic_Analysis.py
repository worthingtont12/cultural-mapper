"""Analyzing Topic Activity Through Time."""
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from datetime import datetime, date
import numpy as np
import seaborn as sns
import pandas.io.sql as psql
import psycopg2
from login_info import user, host, password
%matplotlib inline
# Connection to database
conn = psycopg2.connect(
    "dbname='culturalmapper_LA' user=%s host=%s password=%s" % (user, host, password))


# Reading in Data
# Topic Assignments
df = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/LA/English_LA/035Data/035Data/English_LA.csv")

# Raw Tweets
primary = psql.read_sql(
    "SELECT * FROM la_city_primary WHERE created_at > '2016-10-28' AND created_at < '2017-01-28'", conn)

# df = pd.read_csv(
#     "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/Chicago/035Data/English_Chicago.csv")
#
# # Raw Tweets
# primary = psql.read_sql(
#     "SELECT * FROM chicago_city_primary WHERE created_at > '2016-10-28' AND created_at < '2017-01-28'", conn)

# df = pd.read_csv(
#     "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/Istanbul/Combined_Istanbul_035.csv")
#
# # Raw Tweets
# primary = psql.read_sql(
#     "SELECT * FROM istanbul_city_primary WHERE created_at > '2016-10-28' AND created_at < '2017-01-28'", conn)

# Dropping uneeded variables
df.drop(['Unnamed: 0'], inplace=True, axis=1)
primary.drop(['id', 'source', 'text',
              'text_lang', 'user_location', 'user_handle', 'user_lang'], inplace=True,
             axis=1)

# Merge datasets
fulldf = pd.merge(primary, df, on=['user_id'], how='left')
fulldf.dropna(inplace=True)  # dropping where I don't have topic assignments

# Bar Graph Distribution of Topics
fulldf['top_topic'].value_counts().plot(kind='bar')

# stripping date and time from created_at
fulldf['Date'] = fulldf['created_at'].apply(lambda row: row.split()[0])
fulldf['Time'] = fulldf['created_at'].apply(lambda row: row.split()[1])
# converting to categorical variable
fulldf["top_topic"] = fulldf["top_topic"].astype('category')

# creating count variable to get around difficulties with categorical variables
fulldf["count"] = 1

#################### Daily plots ######################
"""
Plot Distribution of Activity Throughout Entire Series.
"""
dailyplot = sns.factorplot(x="Date", y="count", hue="top_topic",
                           estimator=np.sum, data=fulldf, size=15, aspect=10)

dailyplot.savefig("Graphs/LA/Daily_Plot.png")
# Daily Plot as Percentage
# Mapping topic number to frequency of it
map_topics = {0: 175586, 1: 77648, 2: 25969, 3: 10993, 19: 6112, 12: 6087, 16: 5426, 17: 5101, 8: 4719,
              15: 4405, 9: 4048, 4: 4015, 18: 3649, 5: 3412, 10: 3144, 13: 3138, 7: 2905, 14: 2841, 6: 2578, 11: 2111}

# Creating variable that when summed will give the relative activity of a topic
fulldf["topic_percentage"] = (1 / (fulldf["top_topic"].map(map_topics)))

dailyplot_percentage = sns.factorplot(x="Date", y="topic_percentage", hue="top_topic",
                                      estimator=np.sum, data=fulldf, size=10, aspect=6)

dailyplot_percentage.savefig("Graphs/LA/Daily_Plot_Percentage.png")

# removing Election aftermath
fulldf_without_election = fulldf[fulldf.Date != '2016-11-09']

dailyplot_wo_election = sns.factorplot(x="Date", y="count", hue="top_topic",
                                       estimator=np.sum, data=fulldf_without_election, size=6, aspect=4)
dailyplot_wo_election.savefig("Graphs/LA/Daily_WO_Election")

# Daily Plot as Percentage Without Election
dailyplot_woelection_percentage = sns.factorplot(x="Date", y="topic_percentage", hue="top_topic",
                                                 estimator=np.sum, data=fulldf_without_election, size=10, aspect=6)

dailyplot_woelection_percentage.savefig("Graphs/LA/Daily_Plot_WOELECTION_Percentage.png")

#################### Day of The Week Plots#####################
"""
Plot Activity Throughout Days of the Week
"""
# Creating new variable for day of the week
# converting string to datetime
fulldf['Date1'] = fulldf['Date'].apply(lambda row: datetime.strptime(row, '%Y-%m-%d').date())
# Calling day of the week
fulldf['Day of Week'] = fulldf['Date1'].apply(lambda row: row.weekday())

# Mapping integer to name of day
map_days = {0: "Monday", 1: "Tuesday", 2: "Wednesday",
            3: "Thursday", 4: "Friday", 5: "Saturday", 6: "Sunday"}

fulldf['Day of Week'] = fulldf['Day of Week'].map(map_days)

# Day of Week Plot
dayoftheweek = sns.factorplot(x="Day of Week", y="count",
                              hue="top_topic", estimator=np.sum, data=fulldf)
dayoftheweek.savefig("Graphs/LA/Day_of_The_Week.png")

# Day of the Week As Percentage of Topic
dayoftheweek_percentage = sns.factorplot(x="Day of Week", y="topic_percentage", hue="top_topic",
                                         estimator=np.sum, data=fulldf, size=10, aspect=6)

dayoftheweek_percentage.savefig("Graphs/LA/Day_of_The_Week_Percentage.png")

# Day of the Week without Election aftermath
dayoftheweek_without_election = dayoftheweek[dayoftheweek.Date != '2016-11-09']
dayoftheweek_woaftermath = sns.factorplot(x="Day of Week", y="count", hue="top_topic",
                                          estimator=np.sum, data=dayoftheweek_without_election)
dayoftheweek_woaftermath.savefig("Graphs/LA/Day_of_The_Week_WO_Election.png")

# Day of the Week without Election aftermath as percentage
dayoftheweek_woaftermath_percentage = sns.factorplot(x="Day of Week", y="topic_percentage", hue="top_topic",
                                                     estimator=np.sum, data=dayoftheweek_without_election, size=10, aspect=6)

dayoftheweek_woaftermath_percentage.savefig("Graphs/LA/Day_of_The_Week_Percentage.png")
