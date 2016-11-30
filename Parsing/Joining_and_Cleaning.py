"""Parse Tweets and export them into a working format for Topic Modeling."""
import os
import re
import pandas as pd
os.chdir("/Users/tylerworthington/Git_Repos")

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

# recasting
primary['id'] = primary['id'].apply(str)
primary['user_id'] = primary['user_id'].apply(str)
primary['text_lang'] = primary['text_lang'].apply(str)
primary['user_location'] = primary['user_location'].apply(str)
primary['user_handle'] = primary['user_handle'].apply(str)
primary['user_lang'] = primary['user_lang'].apply(str)
primary['source'] = primary['source'].apply(str)


# transforming language variable
map_lang = {'en': "English", 'fr': "French", 'und': "Unknown", 'ar': "Arabic", 'ja': "Japanese", 'es': "Spanish",
            'de': "German", 'it': 'Italian', 'id': "Indonesian", "pt": "Portuguese", 'ko': "Korean", 'tr': "Turkish",
            'ru': "Russian", 'nl': "Dutch", 'fil': "Filipino", 'msa': "Malay", 'zh-tw': "Chinese", 'zh-cn': "Chinese",
            'zh': "Chinese", 'hi': "Hindi", 'no': "Norwegian", 'sv': "Swedish", 'fi': "Finnish", 'da': "Danish",
            'pl': "Polish", 'hu': "Hungarian", 'fa': "Persian", 'he': "Hebrew", 'th': "Thai", 'uk': "Ukrainian",
            'cs': "Czech", 'ro': "Romanian", 'en-gb': "English", 'en-GB': "English", 'en-AU': "English",
            'vi': "Vietnamese", 'bn': "Bengali"}

primary['user_language'] = primary["user_lang"].map(map_lang)
print(primary['user_language'].value_counts())

# merge text from quoted with primary
primary = pd.merge(primary, quoted, on='id')

# recasting new variables
# primary['q_id'] = primary['q_id'].apply(str)
# primary['q_user_id'] = primary['q_user_id'].apply(str)
primary['q_text_lang'] = primary['q_text_lang'].apply(str)
primary['q_user_location'] = primary['q_user_location'].apply(str)
primary['q_user_handle'] = primary['q_user_handle'].apply(str)
primary['q_user_lang'] = primary['q_user_lang'].apply(str)


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

# drop non unique observations
# primary = primary.loc[~primary['user_id'].duplicated()]
primary.drop(['created_at', 'id', 'source', 'text',
              'text_lang', 'user_location', 'user_handle',  'user_lang', 'q_id',
              'q_created_at', 'q_text', 'q_text_lang',    'q_user_id',
              'q_user_location', 'q_user_handle',  'q_user_lang'], inplace=True,
             axis=1)
primary.drop_duplicates(subset='user_id', inplace=True)

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
    tmp = re.sub("'", '', i)
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", tmp)
    tmp = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp = re.sub('[\s]+', ' ', tmp)
    tmp = re.sub('[^\w]', ' ', tmp)
    tmp = re.sub(' +', ' ', tmp)
    tmp = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp)
    clean1.append(tmp)

primary['cleaned.author.text'] = clean1

# stripping non text characters ie @, # ,https://, ect
clean2 = []

for i in primary['q_author.text']:
    tmp = re.sub("'", '', i)
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", tmp)
    tmp = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp = re.sub('[\s]+', ' ', tmp)
    tmp = re.sub('[^\w]', ' ', tmp)
    tmp = re.sub(' +', ' ', tmp)
    tmp = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp)
    clean2.append(tmp)

primary['cleaned.q.author.text'] = clean2

# merge with user desc
primary2 = pd.merge(primary, user_desc, on='user_id')

# Cleaning user description
clean3 = []
for i in primary2['user_desc']:
    tmp = re.sub("'", '', i)
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", tmp)
    tmp = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp = re.sub('[\s]+', ' ', tmp)
    tmp = re.sub('[^\w]', ' ', tmp)
    tmp = re.sub(' +', ' ', tmp)
    tmp = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp)
    clean3.append(tmp)

primary2['cleaned_user_desc'] = clean3

primary2['cleaned_user_desc'] = primary2['cleaned_user_desc'].astype(str)

primary2.to_csv('cleaned_tweets.csv')
