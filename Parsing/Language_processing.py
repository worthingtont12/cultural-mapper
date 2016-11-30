"""Processing Language for Topic Modeling."""
import os
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from Cleaning import df

os.chdir("/Users/tylerworthington/Git_Repos/Data")

# Function to deal with tokenizing,stemming, and stop word filtering


def process(text, lang):
    # functions used
    tokenizer = RegexpTokenizer(r'\w+')
    stemmer = PorterStemmer()

    # remove case
    text = text.lower()

    # tokenizing
    words = tokenizer.tokenize(text)

    # stemming
    stemmed_tokenized_words = [stemmer.stem(i) for i in words]

    # stop words
    stop_words = [i for i in stemmed_tokenized_words if i not in lang]

    return stop_words

# recasting
df['cleaned_user_desc'] = df['cleaned_user_desc'].apply(str)
df['cleaned.q.author.text'] = df['cleaned.q.author.text'].apply(str)
df['cleaned.author.text'] = df['cleaned.author.text'].apply(str)

# merging all text into one column
df['final_combined_text'] = df[['cleaned_user_desc', 'cleaned.q.author.text',
                                'cleaned.author.text']].apply(lambda x: ' '.join(x), axis=1)

# Stop Words
# english
english = stopwords.words('english')
# Spanish
spanish = stopwords.words('spanish')
# Portuguese
portuguese = stopwords.words('portuguese')
# French
french = stopwords.words('french')
# German
german = stopwords.words('german')
# Russian
russian = stopwords.words('russian')
# Dutch
dutch = stopwords.words('dutch')
# Turkish
turkish = stopwords.words('turkish')
# Finnish
finnish = stopwords.words('finnish')
# Swedish
swedish = stopwords.words('swedish')

# applying function to dataframe
df_en = df[df.user_language == 'English']
df_en['final_combined_text'] = df_en['final_combined_text'].apply(lambda row: process(row, english))

df_es = df[df.user_language == 'Spanish']
df_es['final_combined_text'] = df_es['final_combined_text'].apply(lambda row: process(row, spanish))

# exporting
df_en.to_csv('cleaned_tweets.csv')
