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
print(primary['text_lang'].value_counts())
print(primary['user_lang'].value_counts())

# languages = []
# for i in primary['text_lang']:
#     for j in json_data:
#         if i == j['code']:
#             languages.append(j['name'])
# primary['language'] = languages

languages1 = []
for i in primary['user_lang']:
    for j in json_data:
        if i == j['code']:
            languages1.append(j['name'])

primary['user_language'] = languages1
print(primary['user_language'].value_counts())

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
    tmp = ' '.join(re.sub("(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)", " ", i).split())
    tmp1 = re.sub('[\s]+', ' ', tmp)
    clean1.append(tmp1)

primary['cleaned.text'] = clean1

#dealing with quoted df
# handling @,#, and URL's
# Create empty lists for each category.
mentions1 = []
links1 = []
hashtags1 = []

# Iterate over the text, extracting and adding

for tweet in quoted['text']:
    mentions1.append(re.findall('@\S*\b', tweet))
    links1.append(re.findall('https?://\S*', tweet))
    hashtags1.append(re.findall('#\S*\b', tweet))

# Append features as a new column to the existing dataframe.
quoted['hashtags'] = hashtags
quoted['mentions'] = mentions
quoted['links'] = links

#stripping non text characters ie @, # ,https://, ect
clean2 = []
for i in quoted['q_text']:
    tmp = ' '.join(re.sub("(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)", " ", i).split())
    tmp1 = re.sub('[\s]+', ' ', tmp)
    clean2.append(tmp1)

quoted['q_cleaned.text'] = clean2

#merge text from quoted with primary
pd.merge(primary , quoted, on='id')

#creating new df
#collapsing tweets by user.id
primary['author.text'] = primary[['user.id', 'cleaned.text', 'quoted_text', 'hashtags', 'mentions', 'links']].groupby(['user.id'])['cleaned.text','quoted_text','hashtags','mentions','links'].transform(lambda x: ','.join(x))

#throwout duplicates

#merge with user desc

# #remove punctuation
for p in list(punctuation):
    tweet_processed=tweet_processed.replace(p,'')
#or
df.replace({'\n': '<br>'}, regex=True)

#ignore case
str.lower()
#remove stop words

#stem all words

# Export Tweets
# primary.to_csv('primary.csv')
