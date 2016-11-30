"""Parse Tweets and export them into a working format for Topic Modeling."""
import os
import re
from Joining import primary2

df = primary2
os.chdir("/Users/tylerworthington/Git_Repos/Data")

# recasting
df['id'] = df['id'].apply(str)
df['user_id'] = df['user_id'].apply(str)
df['text_lang'] = df['text_lang'].apply(str)
df['user_location'] = df['user_location'].apply(str)
df['user_handle'] = df['user_handle'].apply(str)
df['user_lang'] = df['user_lang'].apply(str)
df['source'] = df['source'].apply(str)
df['q_text_lang'] = df['q_text_lang'].apply(str)
df['q_user_location'] = df['q_user_location'].apply(str)
df['q_user_handle'] = df['q_user_handle'].apply(str)
df['q_user_lang'] = df['q_user_lang'].apply(str)

# transforming language variable for clearer interpretation
map_lang = {'en': "English", 'fr': "French", 'und': "Unknown", 'ar': "Arabic", 'ja': "Japanese", 'es': "Spanish",
            'de': "German", 'it': 'Italian', 'id': "Indonesian", "pt": "Portuguese", 'ko': "Korean", 'tr': "Turkish",
            'ru': "Russian", 'nl': "Dutch", 'fil': "Filipino", 'msa': "Malay", 'zh-tw': "Chinese", 'zh-cn': "Chinese",
            'zh': "Chinese", 'hi': "Hindi", 'no': "Norwegian", 'sv': "Swedish", 'fi': "Finnish", 'da': "Danish",
            'pl': "Polish", 'hu': "Hungarian", 'fa': "Persian", 'he': "Hebrew", 'th': "Thai", 'uk': "Ukrainian",
            'cs': "Czech", 'ro': "Romanian", 'en-gb': "English", 'en-GB': "English", 'en-AU': "English",
            'vi': "Vietnamese", 'bn': "Bengali"}

df['user_language'] = df["user_lang"].map(map_lang)

# langauge counts
print(df['user_language'].value_counts())

# collapsing tweets by user_id
df['author.text'] = df[['user_id', 'text']].groupby(
    ['user_id'])['text'].transform(lambda x: ','.join(x))
df['q_author.text'] = df[['user_id', 'q_text']].groupby(
    ['user_id'])['q_text'].transform(lambda x: ','.join(x))
df['c_text_lang'] = df[['user_id', 'text_lang']].groupby(
    ['user_id'])['text_lang'].transform(lambda x: ','.join(x))
df['c_user_location'] = df[['user_id', 'user_location']].groupby(
    ['user_id'])['user_location'].transform(lambda x: ','.join(x))
df['c_user_lang'] = df[['user_id', 'user_lang']].groupby(
    ['user_id'])['user_lang'].transform(lambda x: ','.join(x))
df['c_source'] = df[['user_id', 'source']].groupby(
    ['user_id'])['source'].transform(lambda x: ','.join(x))
df['c_q_text_lang'] = df[['user_id', 'q_text_lang']].groupby(
    ['user_id'])['q_text_lang'].transform(lambda x: ','.join(x))
df['c_q_user_location'] = df[['user_id', 'q_user_location']].groupby(
    ['user_id'])['q_user_location'].transform(lambda x: ','.join(x))
df['c_q_user_lang'] = df[['user_id', 'q_user_lang']].groupby(
    ['user_id'])['q_user_lang'].transform(lambda x: ','.join(x))


# drop non unique observations
# df = df.loc[~df['user_id'].duplicated()]
df.drop(['created_at', 'id', 'source', 'text',
         'text_lang', 'user_location', 'user_handle',  'user_lang', 'q_id',
         'q_created_at', 'q_text', 'q_text_lang',    'q_user_id',
         'q_user_location', 'q_user_handle',  'q_user_lang'], inplace=True,
        axis=1)
df.drop_duplicates(subset='user_id', inplace=True)

# handling @,#, and URL's
# Create empty lists for each category.
mentions = []
links = []
hashtags = []

# Iterate over the text, extracting and adding

for tweet in df['author.text']:
    mentions.append(re.findall('@\S*', tweet))
    links.append(re.findall('https?://\S*', tweet))
    hashtags.append(re.findall('#\S*', tweet))

# Append features as a new column to the existing dataframe.
df['hashtags'] = hashtags
df['mentions'] = mentions
df['links'] = links

# dealing with quoted df
# handling @,#, and URL's
# Create empty lists for each category.
mentions1 = []
links1 = []
hashtags1 = []

# Iterate over the text, extracting and adding

for tweet in df['q_author.text']:
    mentions1.append(re.findall(r'@\S*', tweet))
    links1.append(re.findall('https?://\S*', tweet))
    hashtags1.append(re.findall(r'#\S*', tweet))

# Append features as a new column to the existing dataframe.
df['q_hashtags'] = hashtags1
df['q_mentions'] = mentions1
df['q_links'] = links1

# author text
# stripping non text characters ie @, # ,https://, ect
clean1 = []
for i in df['author.text']:
    tmp = re.sub("'", '', i)
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", tmp)
    tmp = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp = re.sub('[\s]+', ' ', tmp)
    tmp = re.sub('[^\w]', ' ', tmp)
    tmp = re.sub(' +', ' ', tmp)
    tmp = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp)
    clean1.append(tmp)

df['cleaned.author.text'] = clean1

# Quoted author text
# stripping non text characters ie @, # ,https://, ect
clean2 = []

for i in df['q_author.text']:
    tmp = re.sub("'", '', i)
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", tmp)
    tmp = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp = re.sub('[\s]+', ' ', tmp)
    tmp = re.sub('[^\w]', ' ', tmp)
    tmp = re.sub(' +', ' ', tmp)
    tmp = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp)
    clean2.append(tmp)

df['cleaned.q.author.text'] = clean2

# User Description
# stripping non text characters ie @, # ,https://, ect
clean3 = []
for i in df['user_desc']:
    tmp = re.sub("'", '', i)
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", tmp)
    tmp = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp = re.sub('[\s]+', ' ', tmp)
    tmp = re.sub('[^\w]', ' ', tmp)
    tmp = re.sub(' +', ' ', tmp)
    tmp = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp)
    clean3.append(tmp)

df['cleaned_user_desc'] = clean3

df['cleaned_user_desc'] = df['cleaned_user_desc'].astype(str)
