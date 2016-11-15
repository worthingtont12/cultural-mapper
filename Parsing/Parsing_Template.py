"""Parse Tweets and export them into a working format for Topic Modeling."""
import json
import os
from string import punctuation
import re
import pandas as pd
os.chdir("/Users/tylerworthington/Git_Repos")
#importing json language file
with open("Cultural_Mapper/Data/Langauge.json") as json_file:
    json_data = json.load(json_file)
#Import CSVs
primary = pd.read_csv("Data/la-primary_102616.csv", error_bad_lines=False)
secondary = pd.read_csv("Data/la-secondary_102616.csv", error_bad_lines=False)
quoted = pd.read_csv("Data/la-quoted102616.csv", error_bad_lines=False)
user_desc = pd.read_csv("Data/la_user_desc_102616.csv", error_bad_lines=False)

#transforming language variable
print(primary['user_lang'].value_counts())

languages1 = []
for i in primary['user_lang']:
    for j in json_data:
        if i == j['code']:
            languages1.append(j['name'])

primary['user_language'] = languages1

# handling @,#, and URL's
# Create empty lists for each category.
mentions = []
links = []
hashtags = []

# Iterate over the text, extracting and adding

for tweet in primary['text']:
    mentions.append(re.findall('@\S*\b', tweet))
    links.append(re.findall('https?://\S*', tweet))
    hashtags.append(re.findall('#\S*\b', tweet))

# Append features as a new column to the existing dataframe.
primary['hashtags'] = hashtags
primary['mentions'] = mentions
primary['links'] = links

#stripping non text characters ie @, # ,https://, ect
clean1 = []
for i in primary['text']:
    tmp = ' '.join(re.sub("(@\S*\b)|(https?://\S*)|(#\S*\b)", " ", i).split())
    tmp1 = re.sub('[\s]+', ' ', tmp)
    tmp1 = re.sub('[^\w]', ' ', tmp1)
    clean1.append(tmp1)

primary['cleaned.text'] = clean1

#dealing with quoted df
# handling @,#, and URL's
# Create empty lists for each category.
mentions1 = []
links1 = []
hashtags1 = []

# Iterate over the text, extracting and adding

for tweet in quoted['q_text']:
    mentions1.append(re.findall('@\S*\b', tweet))
    links1.append(re.findall('https?://\S*', tweet))
    hashtags1.append(re.findall('#\S*\b', tweet))

# Append features as a new column to the existing dataframe.
quoted['hashtags'] = hashtags1
quoted['mentions'] = mentions1
quoted['links'] = links1

#stripping non text characters ie @, # ,https://, ect
clean2 = []

for i in quoted['q_text']:
    tmp = ' '.join(re.sub("(@\S*\b)|(https?://\S*)|(#\S*\b)", " ", i).split())
    tmp1 = re.sub('[\s]+', ' ', tmp)
    tmp1 = re.sub('[^\w]', ' ', tmp1)
    clean2.append(tmp1)

quoted['q_cleaned.text'] = clean2

#merge text from quoted with primary
primary = pd.merge(primary, quoted, on='id')


#creating new df
#collapsing tweets by user_id
primary['author.text'] = primary[['user_id', 'cleaned.text']].groupby(['user_id'])['cleaned.text'].transform(lambda x: ','.join(x))
primary['q_author.text'] = primary[['user_id', 'q_cleaned.text']].groupby(['user_id'])['q_cleaned.text'].transform(lambda x: ','.join(x))
primary['c_text_lang'] = primary[['user_id', 'text_lang']].groupby(['user_id'])['text_lang'].transform(lambda x: ','.join(x))
primary['c_user_location'] = primary[['user_id', 'user_location']].groupby(['user_id'])['user_location'].transform(lambda x: ','.join(x))
primary['c_user_lang'] = primary[['user_id', 'user_lang']].groupby(['user_id'])['user_lang'].transform(lambda x: ','.join(x))
primary['c_source'] = primary[['user_id', 'source']].groupby(['user_id'])['source'].transform(lambda x: ','.join(x))
primary['c_q_text_lang'] = primary[['user_id', 'q_text_lang']].groupby(['user_id'])['q_text_lang'].transform(lambda x: ','.join(x))
primary['c_q_user_location'] = primary[['user_id', 'q_user_location']].groupby(['user_id'])['q_user_location'].transform(lambda x: ','.join(x))
primary['c_q_user_lang'] = primary[['user_id', 'q_user_lang']].groupby(['user_id'])['q_user_lang'].transform(lambda x: ','.join(x))

#throwout duplicates
primary = pd.DataFrame(primary)

#merge with user desc
primary2 = pd.merge(primary, user_desc, on='user_id')

# Export Tweets
primary2.to_csv('primary.csv')
