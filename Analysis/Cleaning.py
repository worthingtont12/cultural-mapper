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
fulldf.top_topic = fulldf.top_topic.fillna(value=fulldf.user_lang)
# dropping where I don't have topic assignments

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
cluster_mapping_istanbul = {"Arabic": 1,
                            "French": 2,
                            "German": 2,
                            "Russian": 3,
                            "English0": 2,
                            "Turkish0": 2,
                            "Turkish13": 3,
                            "Turkish16": 4,
                            "English1": 2,
                            "Turkish1": 5,
                            "English2": 2,
                            "Turkish2": 5,
                            "Turkish3": 5,
                            "Turkish4": 5,
                            "Turkish5": 5,
                            "Turkish6": 5,
                            "Turkish7": 4,
                            "Turkish8": 5,
                            "Turkish9": 3}

cluster_mapping_chicago = {0: 4, 1: 4, 2: 4, 3: 4, 4: 4, 5: 4, 6: 4,
                           7:  3, 8: 5, 9: 2, 10: 1, 11: 2, 12: 2, 13: 2, 14: 2, 15: 2, 16: 2, 17: 2, 18: 5, 'es': 5}

cluster_mapping_la = {"Arabic": 1,
                      "French": 2,
                      "Japanese": 3,
                      "Portuguese": 4,
                      "Spanish": 2,
                      0: 3,
                      12: 5,
                      15: 5,
                      16: 5,
                      17: 5,
                      19: 5,
                      5: 3,
                      6: 3,
                      7: 3,
                      8: 5,
                      9: 5}

fulldf["Cluster"] = fulldf["top_topic"].map(cluster_mapping_istanbul)
fulldf["Cluster"].dropna(inplace=True)
