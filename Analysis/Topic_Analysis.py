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
# Connection to database
conn = psycopg2.connect(
    "dbname='culturalmapper_LA' user=%s host=%s password=%s" % (user, host, password))


# Reading in Data
# Topic Assignments
df = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/LA/English_LA/035Data/035Data/English_LA.csv")

# Raw Tweets
primary = psql.read_sql(
    "SELECT * FROM la_city_primary WHERE created_at > '2016-10-28' AND created_at < '2017-01-28' LIMIT 1000", conn)

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

# stripping date from created_at and converting into date
fulldf['Date'] = fulldf['created_at'].apply(lambda row: row.split()[0])

# converting to categorical variable
fulldf["top_topic"] = fulldf["top_topic"].astype('category')

# creating count variable to get around difficulties with categorical variables
fulldf["count"] = 1

# Daily plot
sns.factorplot(x="Date", y="count", hue="top_topic", estimator=np.sum, data=fulldf)

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
sns.factorplot(x="Day of Week", y="count", hue="top_topic", estimator=np.sum, data=fulldf)
