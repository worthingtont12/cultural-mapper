"""Parse and clean tweets and export them into a working format for Topic Modeling."""
import re
from Parsing.Joining import primary2
import pandas as pd
# Pulls in data frame created in previous sheet.
# See README for describtion of process
df = primary2

# functions


def text_clean(dirtytext):
    """Cleans text by stripping out unnecessary characters.
    Parameters
    ----------
    dirtytext : The text to be cleaned.
    """
    tmp = re.sub("'", '', dirtytext)
    tmp = re.sub(",", '', tmp)
    tmp = re.sub("(@\S*)|(https?://\S*)", " ", tmp)
    tmp = ' '.join(re.sub("(\w+:\/\/\S+)", " ", tmp).split())
    tmp = re.sub('[\s]+', ' ', tmp)
    tmp = re.sub('[^\w]', ' ', tmp)
    tmp = re.sub(' +', ' ', tmp)
    tmp = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', tmp)
    tmp = re.sub('nan', ' ', tmp)
    tmp = tmp.lower()
    return tmp


# recasting
df['id'] = df['id'].apply(str)
df['text'] = df['text'].apply(str)
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
df['q_text'] = df['q_text'].apply(str)
df['user_desc'] = df['user_desc'].apply(str)

# filter out job bots, weather bots, geo bots, ect
df = df[~df['source'].str.contains("TweetMYJOBS")]
df = df[~df['source'].str.contains("tweetmyjobs")]
df = df[~df['user_desc'].str.contains("Follow this account for geo-targeted")]
df = df[~df['text'].str.contains("Want to work in")]
df = df[~df['text'].str.contains("Can you recommend anyone for this")]
df = df[~df['text'].str.contains("CareerArc")]

df1 = df[df['source'].str.contains("Twitter for")]
df2 = df[df['source'].str.contains("for Android")]
df3 = df[df['source'].str.contains("for iOS")]
df4 = df[df['source'].str.contains("for iPhone")]
df5 = df[df['source'].str.contains("for Windows Phone")]
df6 = df[df['source'].str.contains("for iPad")]
df7 = df[df['source'].str.contains("for Mac")]
df8 = df[df['source'].str.contains("Twitter Web Client")]
df9 = df[df['source'].str.contains("Instagram")]
df10 = df[df['source'].str.contains("Foursquare")]
df11 = df[df['source'].str.contains("tron")]

dfs = [df1, df2, df3, df4, df5, df6, df7, df8, df9, df10, df11]
dffiltered = pd.concat(dfs)

# number of documents
print(dffiltered.shape)
# transforming language variable for clearer interpretation
map_lang = {'en': "English", 'fr': "French", 'und': "Unknown", 'ar': "Arabic", 'ja': "Japanese", 'es': "Spanish",
            'de': "German", 'it': 'Italian', 'id': "Indonesian", "pt": "Portuguese", 'ko': "Korean", 'tr': "Turkish",
            'ru': "Russian", 'nl': "Dutch", 'fil': "Filipino", 'msa': "Malay", 'zh-tw': "Chinese", 'zh-cn': "Chinese",
            'zh': "Chinese", 'hi': "Hindi", 'no': "Norwegian", 'sv': "Swedish", 'fi': "Finnish", 'da': "Danish",
            'pl': "Polish", 'hu': "Hungarian", 'fa': "Persian", 'he': "Hebrew", 'th': "Thai", 'uk': "Ukrainian",
            'cs': "Czech", 'ro': "Romanian", 'en-gb': "English", 'en-GB': "English", 'en-AU': "English",
            'vi': "Vietnamese", 'bn': "Bengali"}

dffiltered['user_language'] = dffiltered["user_lang"].map(map_lang)

# langauge counts
print(dffiltered['user_language'].value_counts())

# collapsing tweets by user_id
dffiltered['author.text'] = dffiltered[['user_id', 'text']].groupby(
    ['user_id'])['text'].transform(lambda x: ','.join(x))
dffiltered['q_author.text'] = dffiltered[['user_id', 'q_text']].groupby(
    ['user_id'])['q_text'].transform(lambda x: ','.join(x))
dffiltered['c_text_lang'] = dffiltered[['user_id', 'text_lang']].groupby(
    ['user_id'])['text_lang'].transform(lambda x: ','.join(x))
dffiltered['c_user_location'] = dffiltered[['user_id', 'user_location']].groupby(
    ['user_id'])['user_location'].transform(lambda x: ','.join(x))
dffiltered['c_user_lang'] = dffiltered[['user_id', 'user_lang']].groupby(
    ['user_id'])['user_lang'].transform(lambda x: ','.join(x))
dffiltered['c_source'] = dffiltered[['user_id', 'source']].groupby(
    ['user_id'])['source'].transform(lambda x: ','.join(x))
dffiltered['c_q_text_lang'] = dffiltered[['user_id', 'q_text_lang']].groupby(
    ['user_id'])['q_text_lang'].transform(lambda x: ','.join(x))
dffiltered['c_q_user_location'] = dffiltered[['user_id', 'q_user_location']].groupby(
    ['user_id'])['q_user_location'].transform(lambda x: ','.join(x))
dffiltered['c_q_user_lang'] = dffiltered[['user_id', 'q_user_lang']].groupby(
    ['user_id'])['q_user_lang'].transform(lambda x: ','.join(x))

# number of users
print(dffiltered.shape)

# drop non unique observations
# dffiltered = dffiltered.loc[~dffiltered['user_id'].duplicated()]
dffiltered.drop(['created_at', 'id', 'source', 'text',
                 'text_lang', 'user_location', 'user_handle', 'user_lang', 'q_id',
                 'q_created_at', 'q_text', 'q_text_lang', 'q_user_id',
                 'q_user_location', 'q_user_handle', 'q_user_lang'], inplace=True,
                axis=1)
dffiltered.drop_duplicates(subset='user_id', inplace=True)

# handling @,#, and URL's
# Create empty lists for each category.
mentions = []
links = []
hashtags = []

# Iterate over the text, extracting and adding

for tweet in dffiltered['author.text']:
    mentions.append(re.findall('@\S*', tweet))
    links.append(re.findall('https?://\S*', tweet))
    hashtags.append(re.findall('#\S*', tweet))

# Append features as a new column to the existing dataframe.
dffiltered['hashtags'] = hashtags
dffiltered['mentions'] = mentions
dffiltered['links'] = links

# dealing with quoted dffiltered
# handling @,#, and URL's
# Create empty lists for each category.
mentions1 = []
links1 = []
hashtags1 = []

# Iterate over the text, extracting and adding

for tweet in dffiltered['q_author.text']:
    mentions1.append(re.findall(r'@\S*', tweet))
    links1.append(re.findall('https?://\S*', tweet))
    hashtags1.append(re.findall(r'#\S*', tweet))

# Append features as a new column to the existing dataframe.
dffiltered['q_hashtags'] = hashtags1
dffiltered['q_mentions'] = mentions1
dffiltered['q_links'] = links1

# recasting variables
dffiltered['author.text'] = dffiltered['author.text'].apply(str)
dffiltered['q_author.text'] = dffiltered['q_author.text'].apply(str)
dffiltered['user_desc'] = dffiltered['user_desc'].apply(str)

# stripping non text characters ie @, # ,https://, ect
dffiltered['cleaned_author_text'] = dffiltered['author.text'].apply(text_clean)
dffiltered['cleaned_q_author_text'] = dffiltered['q_author.text'].apply(text_clean)
dffiltered['cleaned_user_desc'] = dffiltered['user_desc'].apply(text_clean)

# free up memory
del df1, df2, df3, df4, df5, df6, df7, df8, df9, df10, df11
