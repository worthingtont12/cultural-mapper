"""Joining datasets for parsing"""
import os
import pandas as pd

os.chdir("/Users/tylerworthington/Git_Repos/Data")

# Import CSVs
primary = pd.read_csv("Data/1125/1125LA_primary.csv", error_bad_lines=False)
quoted = pd.read_csv("Data/1125/1125LA_quoted.csv", error_bad_lines=False)
user_desc = pd.read_csv("Data/1125/1125LA_userdesc.csv", error_bad_lines=False)

# naming Columns
primary.columns = ['created_at', 'id', 'source', 'text', 'text_lang',
                   'user_id', 'user_location', 'user_handle', 'user_lang']
quoted.columns = ['id', 'q_id', 'q_created_at', 'q_text', 'q_text_lang',
                  'q_user_id', 'q_user_location', 'q_user_handle', 'q_user_lang']
user_desc.columns = ['id', 'user_id', 'user_desc']

# merge text from quoted with primary
primary1 = pd.merge(primary, quoted, on='id')

# merge with user desc
primary2 = pd.merge(primary1, user_desc, on='id')

# out to csv
primary2.to_csv('cleaned_tweets.csv')
primary1.to_csv('cleaned_tweets2.csv')
