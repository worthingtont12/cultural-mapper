"""Parse Tweets and export them into a working format for Topic Modeling."""
import json
import os
import re
import pandas as pd
os.chdir("/Users/tylerworthington/Git_Repos")
# importing json language file
with open("Cultural_Mapper/Assets/Langauge.json") as json_file:
    json_data = json.load(json_file)
# Import CSVs
primary = pd.read_csv("Data/la-primary_102616.csv", error_bad_lines=False)
secondary = pd.read_csv("Data/la-secondary_102616.csv", error_bad_lines=False)
quoted = pd.read_csv("Data/la-quoted102616.csv", error_bad_lines=False)
user_desc = pd.read_csv("Data/la_user_desc_102616.csv", error_bad_lines=False)

# transforming language variable

languages1 = []
for i in primary['user_lang']:
    for j in json_data:
        if i == j['code']:
            languages1.append(j['name'])

primary['user_language'] = languages1
print(primary['user_language'].value_counts())

# merge text from quoted with primary
primary = pd.merge(primary, quoted, on='id')

# creating new df
# collapsing tweets by user_id
primary['author.text'] = primary[['user_id', 'text']].groupby(
    ['user_id'])['text'].transform(lambda x: ','.join(x))
primary['q_author.text'] = primary[['user_id', 'q_text']].groupby(
    ['user_id'])['q_text'].transform(lambda x: ','.join(x))
primary['c_text_lang'] = primary[['user_id', 'text_lang']].groupby(
    ['user_id'])['text_lang'].transform(lambda x: ','.join(x))
primary['c_user_location'] = primary[['user_id', 'user_location']].groupby(
    ['user_id'])['user_location'].transform(lambda x: ','.join(x))
primary['c_user_lang'] = primary[['user_id', 'user_lang']].groupby(
    ['user_id'])['user_lang'].transform(lambda x: ','.join(x))
primary['c_source'] = primary[['user_id', 'source']].groupby(
    ['user_id'])['source'].transform(lambda x: ','.join(x))
primary['c_q_text_lang'] = primary[['user_id', 'q_text_lang']].groupby(
    ['user_id'])['q_text_lang'].transform(lambda x: ','.join(x))
primary['c_q_user_location'] = primary[['user_id', 'q_user_location']].groupby(
    ['user_id'])['q_user_location'].transform(lambda x: ','.join(x))
primary['c_q_user_lang'] = primary[['user_id', 'q_user_lang']].groupby(
    ['user_id'])['q_user_lang'].transform(lambda x: ','.join(x))

# handling @,#, and URL's
# Create empty lists for each category.
mentions = []
links = []
hashtags = []

# Iterate over the text, extracting and adding

for tweet in primary['author.text']:
    mentions.append(re.findall('@\S*', tweet))
    links.append(re.findall('https?://\S*', tweet))
    hashtags.append(re.findall('#\S*', tweet))

# Append features as a new column to the existing dataframe.
primary['hashtags'] = hashtags
primary['mentions'] = mentions
primary['links'] = links

# dealing with quoted df
# handling @,#, and URL's
# Create empty lists for each category.
mentions1 = []
links1 = []
hashtags1 = []

# Iterate over the text, extracting and adding

for tweet in primary['q_author.text']:
    mentions1.append(re.findall(r'@\S*', tweet))
    links1.append(re.findall('https?://\S*', tweet))
    hashtags1.append(re.findall(r'#\S*', tweet))

# Append features as a new column to the existing dataframe.
primary['q_hashtags'] = hashtags1
primary['q_mentions'] = mentions1
primary['q_links'] = links1

# stripping non text characters ie @, # ,https://, ect
clean1 = []
for i in primary['author.text']:
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", i)
    tmp1 = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp1 = re.sub('[\s]+', ' ', tmp)
    tmp1 = re.sub('[^\w]', ' ', tmp1)
    tmp1 = re.sub(' +', ' ', tmp1)
    tmp1 = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp1)
    clean1.append(tmp1)

primary['cleaned.author.text'] = clean1

# stripping non text characters ie @, # ,https://, ect
clean2 = []

for i in primary['q_author.text']:
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", i)
    tmp1 = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp1 = re.sub('[\s]+', ' ', tmp)
    tmp1 = re.sub('[^\w]', ' ', tmp1)
    tmp1 = re.sub(' +', ' ', tmp1)
    tmp1 = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp1)
    clean2.append(tmp1)

primary['cleaned.q.author.text'] = clean2

# merge with user desc
primary2 = pd.merge(primary, user_desc, on='user_id')

# Cleaning user description
clean3 = []
for i in primary2['user_desc']:
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", i)
    tmp1 = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp1 = re.sub('[\s]+', ' ', tmp1)
    tmp1 = re.sub('[^\w]', ' ', tmp1)
    tmp1 = re.sub(' +', ' ', tmp1)
    tmp1 = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp1)
    clean3.append(tmp1)

primary2['cleaned_user_desc'] = clean3

primary2['cleaned_user_desc'] = primary2['cleaned_user_desc'].astype(str)

# Export Tweets
primary2.to_csv('primary.csv')
