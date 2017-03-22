"""Processing Language for Topic Modeling."""
from nltk.tokenize import RegexpTokenizer
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from Parsing.Cleaning import dffiltered, text_clean

# Pulls in data frame created in previous sheet.
# See README for describtion of process
df = dffiltered


def process(text, lang):
    """
    Function to deal with tokenizing, stemming or lemmantizing, and stop word filtering.

    Parameters
    ----------
    text : text of interest in string format.
    lang : language for stop word filtering.

    """
    # functions used
    tokenizer = RegexpTokenizer(r'\w+')
    lemmatizer = WordNetLemmatizer()

    # remove case
    text = text.lower()

    # tokenizing
    words = tokenizer.tokenize(text)

    # lemmantizing
    lemmed_tokenized_words = [lemmatizer.lemmatize(i) for i in words]

    # stop words
    stop_words = [i for i in lemmed_tokenized_words if i not in lang]

    return stop_words


# recasting
df['cleaned_user_desc'] = df['cleaned_user_desc'].apply(str)
df['cleaned_q_author_text'] = df['cleaned_q_author_text'].apply(str)
df['cleaned_author_text'] = df['cleaned_author_text'].apply(str)

# merging all text into one column
df['final_combined_text'] = df[['cleaned_user_desc', 'cleaned_q_author_text',
                                'cleaned_author_text']].apply(lambda x: ''.join(x), axis=1)

# clean the text
df['final_combined_text'] = df['final_combined_text'].apply(text_clean)
df['final_combined_text'] = df['final_combined_text'].apply(str)

print(df.shape)
# Stop Words
# english
english = stopwords.words('english')
# Spanish
spanish = stopwords.words('spanish')


# applying function to dataframe
df_en = df[df.user_language == 'English']
df_en['final_combined_text'] = df_en['final_combined_text'].apply(lambda row: process(row, english))

# free up memory
del df
