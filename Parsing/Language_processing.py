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

df = pd.read_csv("primary.csv", error_bad_lines=False)

###################Function to deal with special characters, tokenizing, and stemming#####################
def clean(text):
    #functions used
    tokenizer = RegexpTokenizer(r'\w+')
    stemmer = PorterStemmer()

    #dealing with special cases
    text = text.replace('\'', '')
    text = text.replace('"', ' ')
    text = text.replace('_', ' ')
    text = text.replace('-', ' ')
    text = re.sub(' +', ' ', text)
    text = re.sub('[1|2|3|4|5|6|7|8|9|0]', '', text)

    #remove case
    text = text.lower()

    # tokenizing
    words = tokenizer.tokenize(text)

    # stemming
    stemmed_tokenized_words = [stemmer.stem(i) for i in words]

    return stemmed_tokenized_words


#applying function to dataframe
df.apply(clean)


# English       19633
# Spanish         127
# Portuguese       59
# Arabic           48
# Japanese         42
# French           19
# German           18
# Russian          11
# Polish           11
# Dutch             5
# Turkish           5
# Finnish           2
# Korean            1
# Swedish           1

####Stop Words
#English
english = stopwords.words('english')
words = [w for w in df if not w in stopwords.words("english")]

#Spanish
spanish = stopwords.words('spanish')

#Portuguese
portuguese = stopwords.words('portuguese')

#French
french = stopwords.words('french')

#German
german = stopwords.words('german')

#Russian
russian = stopwords.words('russian')

#Dutch
dutch  = stopwords.words('dutch')

#Turkish
turkish = stopwords.words('turkish')

#Finnish
finnish = stopwords.words('finnish')

#Swedish
swedish = stopwords.words('swedish')
