"""Processing Language for Topic Modeling."""
import re
import os
import pandas as pd
import nltk
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
from sklearn.feature_extraction.text import TfidfVectorizer
from io import StringIO

os.chdir("/Users/tylerworthington/Git_Repos")

df = pd.read_csv("author_tweets.csv", error_bad_lines=False)
# recasting
df['cleaned_user_desc'] = df['cleaned_user_desc'].apply(str)
df['cleaned.q.author.text'] = df['cleaned.q.author.text'].apply(str)
df['cleaned.author.text'] = df['cleaned.author.text'].apply(str)

# merging all text into one column
df['final_combined_text'] = df[['cleaned_user_desc', 'cleaned.q.author.text',
                                'cleaned.author.text']].apply(lambda x: ' '.join(x), axis=1)

# Function to deal with special characters, tokenizing,


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


# applying function to dataframe
english = stopwords.words('english')
df_en = df[df.user_language == 'English']
df_en['final_combined_text'] = df_en['final_combined_text'].apply(lambda row: process(row, english))

# # Stop Words
# English

#
# def stop(doc, lang):
#     stop_words = " ".join([i for i in doc if i not in lang])
#     return stop_words
#
#
# df['final_combined_text1'] = df['final_combined_text'].apply(lambda doc: stop(doc, english))

# exporting
df_en.to_csv('cleaned_tweets.csv')
