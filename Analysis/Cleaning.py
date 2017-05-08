"""Imports and Cleans Tweets for Time Series Analysis"""
import pandas as pd
import pandas.io.sql as psql
import psycopg2

# database keys
from login_info import user, host, password

# sql command
from SQL_Commands import LA_Sql
#######Importing and Cleaning######
# connect to database
conn = psycopg2.connect(
    "dbname='culturalmapper_LA' user=%s host=%s password=%s" % (user, host, password))

# import csv locally
df = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/LA/English_LA/035Data/035Data/English_LA.csv")

# Query database for data within interested time frame
primary = psql.read_sql(LA_Sql, conn)

# Dropping uneeded variables
df.drop(['Unnamed: 0'], inplace=True, axis=1)

# number of tweets
len(primary)

# Merge datasets
fulldf = pd.merge(primary, df, on=['user_id'], how='left')

# dropping where I don't have topic assignments
fulldf.top_topic = fulldf.top_topic.fillna(value=fulldf.user_lang)

# stripping date and time from created_at
fulldf['Date'] = fulldf['tzone'].apply(lambda row: str(row).split()[0])
fulldf['Time'] = fulldf['tzone'].apply(lambda row: str(row).split()[1])
fulldf['Date']

# Sorting
fulldf['Date1'] = pd.to_datetime(fulldf.Date)  # convert to datetime
fulldf = fulldf.sort_values(by='Date1')

# converting to categorical variable
fulldf["top_topic"] = fulldf["top_topic"].astype('category')

# creating count variable to get around difficulties with categorical variables
fulldf["count"] = 1

######Feature Engineering######
# mapping community size to topic number and divide 1 over the size, the
# resulting variable when summed will give average tweets by community size
communitysize = fulldf.groupby('top_topic').user_id.nunique()
community_size = dict(zip(communitysize.index, communitysize.values))
fulldf["topic_percentage"] = (1 / fulldf["top_topic"].map(community_size))

# Assigning heirarchial clustering results to topics
cluster_mapping_istanbul = {"ar": 1,
                            "fr": 2,
                            "de": 2,
                            "ru": 3,
                            "es": 1,
                            "English_0": 2,
                            "Turkish_0": 2,
                            "Turkish_13": 3,
                            "Turkish_16": 4,
                            "English_1": 2,
                            "Turkish_1": 5,
                            "English_2": 2,
                            "Turkish_2": 5,
                            "Turkish_3": 5,
                            "Turkish_4": 5,
                            "Turkish_5": 5,
                            "Turkish_6": 5,
                            "Turkish_7": 4,
                            "Turkish_8": 5,
                            "Turkish_9": 3, }

cluster_mapping_chicago = {"es": 1,
                           0: 2,
                           10: 3,
                           11: 4,
                           12: 4,
                           13: 4,
                           14: 4,
                           15: 4,
                           16: 4,
                           17: 4,
                           18: 1,
                           1: 2,
                           2: 2,
                           3: 2,
                           4: 2,
                           5: 2,
                           6: 2,
                           7: 5,
                           8: 1,
                           9: 4,
                           'ar': 7}

cluster_mapping_la = {"ar": 1,
                      "fr": 2,
                      "ja": 3,
                      "pt": 4,
                      "es": 2,
                      0: 3,
                      12: 5,
                      15: 5,
                      16: 5,
                      17: 5,
                      19: 5,
                      1: 3,
                      2: 3,
                      3: 3,
                      4: 3,
                      5: 3,
                      6: 3,
                      7: 3,
                      8: 5,
                      9: 5}

# mapping topic assignmnets to cluster assignments
fulldf["Cluster"] = fulldf["top_topic"].map(cluster_mapping_la)

# dropping whoever doesnt have cluster assignments
fulldf["Cluster"].dropna(inplace=True)
