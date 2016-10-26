"""Parse Tweets and export them into a working format for Topic Modeling."""

import os
import re
import pandas as pd
os.chdir("CaseStudy2/Data/")

#Import CSV
df = pd.read_csv("tweets.csv")

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
