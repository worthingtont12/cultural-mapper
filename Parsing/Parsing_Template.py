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

#handling @

#handling links

#
# #stripping non text characters ie @, # ,https://, ect
# clean1 = []
# for i in primary['text']:
#     tmp = ' '.join(re.sub("(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)", " ", i).split())
#     clean1.append(tmp)
#
# primary['cleaned.text'] = clean1
#
# #merge text from quoted with primary
#
# ##creating new df
# #collapsing tweets by user.id
# primary['author.text'] = primary[['user.id', 'cleaned.text']].groupby(['user.id'])['cleaned.text'].transform(lambda x: ','.join(x))
#
# #throwout duplicates
#
# #merge with user desc
#
# #Remove additional white spaces
# primary['text'] = re.sub('[\s]+', ' ', primary['text'])
#
# #Convert www.* or https?://* to URL
# primary['text'] = re.sub('((www\.[^\s]+)|(https?://[^\s]+))','URL', primary['text'])
#
# #Replace #word with word
# primary['text'] = re.sub(r'#([^\s]+)', r'\1', primary['text'])
# #
# # #remove punctuation
# for p in list(punctuation):
#     tweet_processed=tweet_processed.replace(p,'')
# #or
# df.replace({'\n': '<br>'}, regex=True)

#ignore case
str.lower()
#remove stop words

#stem all words

# Export Tweets
# primary.to_csv('primary.csv')
