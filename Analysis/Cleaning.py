"""Imports and Cleans Tweets for Time Series Analysis"""
import pandas as pd
import pandas.io.sql as psql
import psycopg2

# database keys
from login_info import user, host, password

# sql command
from SQL_Commands import Istanbul_Sql

#######Importing and Cleaning######
# connect to database
conn = psycopg2.connect(
    "dbname='culturalmapper_Istanbul' user=%s host=%s password=%s" % (user, host, password))

# import csv locally
df = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/Istanbul/Combined_Istanbul_035.csv")
# Query database for data within interested time frame
primary = psql.read_sql(Istanbul_Sql, conn)

# Dropping uneeded variables
df.drop(['Unnamed: 0'], inplace=True, axis=1)

# number of tweets
len(primary)

# Merge datasets
fulldf = pd.merge(primary, df, on=['user_id'], how='left')
fulldf.dropna(inplace=True)  # dropping where I don't have topic assignments

# stripping date and time from created_at
fulldf['Date'] = fulldf['tzone'].apply(lambda row: str(row).split()[0])
fulldf['Time'] = fulldf['tzone'].apply(lambda row: str(row).split()[1])

# Sorting
fulldf['Date1'] = pd.to_datetime(fulldf.Date)
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
cluster_mapping_istanbul = {"Turkish_0": 5, "Turkish_1": 4, "Turkish_2": 4, "Turkish_16": 3,
                            "Turkish_3": 4, "Turkish_9": 1, "Turkish_4": 4, "Turkish_7":  2,
                            "Turkish_8": 4, "Turkish_5": 4, "Turkish_13": 1, "Turkish_14": 5, "Turkish_15": 1, "Turkish_12": 1, "Turkish_6": 4, "Turkish_10": 1, "Turkish_11": 3, "English_0": 5, "English_2": 5, "English_1": 5}

cluster_mapping_chicago = {0: 5, 1: 4, 2: 4, 3: 3, 4: 4, 5: 1, 6: 4,
                           7:  2, 8: 4, 9: 4, 10: 1, 11: 5, 12: 1, 13: 1, 14: 4, 15: 1, 16: 3, 17: 5, 18: 5, 19: 5}

fulldf["Cluster"] = fulldf["top_topic"].map(cluster_mapping_chicago)
