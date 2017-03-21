"""Analyzing Topic Distributions."""
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from datetime import datetime
import numpy as np
import seaborn as sns
import pandas.io.sql as psql
import psycopg2
from login_info import user, host, password
# Connection to database
conn = psycopg2.connect(
    "dbname='culturalmapper_LA' user=%s host=%s password=%s" % (user, host, password))


# Reading in Data
df = pd.read_csv(
    "/Users/tylerworthington/Git_Repos/Data/Cultural_Mapper_Data/LA/English_LA/075Data/English_LA.csv")
primary = psql.read_sql(
    "SELECT * FROM la_city_primary WHERE created_at > '2016-10-28' AND created_at < '2017-01-28' LIMIT 10", conn)

# Dropping uneeded variables
df.drop(['Unnamed: 0'], inplace=True, axis=1)
primary.drop(['id', 'source', 'text',
              'text_lang', 'user_location', 'user_handle', 'user_lang'], inplace=True,
             axis=1)

# Merge datasets
fulldf = pd.merge(primary, df, on=['user_id'], how='left')
fulldf.dropna(inplace=True)

# Bar Graph Distribution
fulldf['top_topic'].value_counts().plot(kind='bar')

# stripping date from created_at and converting into date
fulldf['Date'] = fulldf['created_at'].apply(lambda row: row.split()[0])
fulldf['Date'] = fulldf['Date'].apply(lambda row: datetime.strptime(row, '%Y-%m-%d').date())

# converting to categorical variable
fulldf["top_topic"] = fulldf["top_topic"].astype('category')

# #time series plots
