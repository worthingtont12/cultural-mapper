"""Joining datasets for parsing."""
import os
import pandas as pd

os.chdir("/Users/tylerworthington/Git_Repos/Data")

# Import CSVs
primary = pd.read_csv("1125/1125LA_primary.csv", error_bad_lines=False, nrows=1000)
quoted = pd.read_csv("1125/1125LA_quoted.csv", error_bad_lines=False, nrows=1000)
user_desc = pd.read_csv("1125/1125LA_userdesc.csv", error_bad_lines=False, nrows=1000)

# naming Columns
primary.columns = ['created_at', 'id', 'source', 'text', 'text_lang',
                   'user_id', 'user_location', 'user_handle', 'user_lang']
quoted.columns = ['id', 'q_id', 'q_created_at', 'q_text', 'q_text_lang',
                  'q_user_id', 'q_user_location', 'q_user_handle', 'q_user_lang']
user_desc.columns = ['id', 'user_id', 'user_desc']

# recasting
primary['id'] = primary['id'].apply(str)
primary['user_id'] = primary['user_id'].apply(str)
quoted['id'] = quoted['id'].apply(str)
user_desc['id'] = user_desc['id'].apply(str)
user_desc['user_id'] = user_desc['user_id'].apply(str)

# merge text from quoted with primary
primary1 = pd.merge(primary, quoted, on='id', how='left')

# merge with user desc
primary2 = pd.merge(primary1, user_desc, on=['user_id', 'id'], how='left')
