"""Parse Tweets and export them into a working format for Topic Modeling."""
import json
import os
#import re
import pandas as pd
os.chdir("/Users/tylerworthington/Git_Repos/Cultural_Mapper/Data")
#importing json language file
with open("Langauge.json") as json_file:
    json_data = json.load(json_file)
    print(json_data)
#Import CSVs
df = pd.read_csv("test.csv")

#transforming language variable
print(df['lang'].value_counts())
print(df['user_lang'].value_counts())

languages = []
for i in df['lang']:
    for j in json_data:
        if i == j['code']:
            languages.append(j['name'])
df['language'] = languages

languages1 = []
for i in df['user_lang']:
    for j in json_data:
        if i == j['code']:
            languages1.append(j['name'])

df['user_language'] = languages1

#handling @

#handling links

#stripping non text characters ie @, # ,https://, ect
clean1 = []
for i in df['text']:
    tmp = ' '.join(re.sub("(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)", " ", i).split())
    clean1.append(tmp)

df['cleaned.text'] = clean1

#collapsing tweets by user.id
df['author.text'] = df[['user.id', 'cleaned.text']].groupby(['user.id'])['cleaned.text'].transform(lambda x: ','.join(x))

#remove extra whitespace

#remove punctuation

#ignore case

#remove stop words

#stem all words

#Export Tweets
#df.to_csv('df.csv')
