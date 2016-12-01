"""Joining datasets for parsing."""
import pandas as pd
import pandas.io.sql as psql
import psycopg2

conn = psycopg2.connect(
    "dbname='culturalmapper_LA' user=culturalmapper host=culturalmapper-la.cbjpxqmibsmf.us-east-1.rds.amazonaws.com password=UVAdsi2017")

primary = psql.read_sql("SELECT * FROM la_city_primary", conn)
quoted = psql.read_sql("SELECT * FROM la_quoted", conn)
user_desc = psql.read_sql("SELECT * FROM la_user_desc", conn)

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
