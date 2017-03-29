"""Imports and Cleans Tweets for Time Series Analysis"""
import pandas as pd
import pandas.io.sql as psql
import psycopg2

# database keys
from login_info import user, host, password
# connect to database
conn = psycopg2.connect(
    "dbname='culturalmapper_LA' user=%s host=%s password=%s" % (user, host, password))

# import csv locally
df = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/LA/English_LA/035Data/035Data/English_LA.csv")

# Query database for data within interested time frame
primary = psql.read_sql(
    "SELECT * FROM la_city_primary WHERE timezone('America/Los_Angeles', CAST(created_at as timestamptz)) BETWEEN '2016-10-28' AND '2017-01-27'", conn)
primary

# Dropping uneeded variables
df.drop(['Unnamed: 0'], inplace=True, axis=1)
primary.drop(['id', 'source', 'text',
              'text_lang', 'user_location', 'user_handle', 'user_lang'], inplace=True,
             axis=1)

# Merge datasets
fulldf = pd.merge(primary, df, on=['user_id'], how='left')
fulldf.dropna(inplace=True)  # dropping where I don't have topic assignments


# stripping date and time from created_at
fulldf['Date'] = fulldf['created_at'].apply(lambda row: row.split()[0])
fulldf['Time'] = fulldf['created_at'].apply(lambda row: row.split()[1])

# Sorting
fulldf['Date1'] = pd.to_datetime(fulldf.Date)
fulldf = fulldf.sort_values(by='Date1')
# converting to categorical variable
fulldf["top_topic"] = fulldf["top_topic"].astype('category')

# creating count variable to get around difficulties with categorical variables
fulldf["count"] = 1

# Mapping topic number size of community
map_topics_la = {0: 175586, 1: 77648, 2: 25969, 3: 10993, 19: 6112, 12: 6087, 16: 5426, 17: 5101, 8: 4719,
                 15: 4405, 9: 4048, 4: 4015, 18: 3649, 5: 3412, 10: 3144, 13: 3138, 7: 2905, 14: 2841, 6: 2578, 11: 2111}

map_topics_chicago = {
    0: 114242, 1: 42130, 2: 12954, 12: 6894, 3: 5482, 4: 4293, 9: 4236, 16: 3534, 17: 3344, 5: 2997, 15:  2935, 7: 2850, 8: 2428, 18: 2039, 14: 2020, 13: 2015, 11: 1753, 6: 1683, 19: 1672, 10: 1531}

map_topics_istanbul = {"Turkish_0": 109565, "Turkish_1":     26665, "Turkish_2":     11233, "Turkish_16":      4829, "Turkish_3":      4323, "Turkish_9":      4279, "Turkish_4":      4056, "Turkish_7":      2479, "Turkish_8":      2395, "Turkish_5":      2371,
                       "Turkish_13":      2021, "Turkish_14":      1878, "Turkish_15":      1644, "Turkish_12":      1563, "Turkish_6":      1489, "Turkish_10":      1231, "Turkish_11":       765, "English_0":    24826, "English_2":     3018, "English_1":     2508}

# Creating variable that when summed will give the relative activity of a topic
fulldf["topic_percentage"] = (1 / (fulldf["top_topic"].map(map_topics_istanbul)))
