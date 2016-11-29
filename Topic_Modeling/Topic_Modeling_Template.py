"""Topic Modeling on Authored Tweets"""
import os
import pandas as pd
import numpy as np
import sklearn.feature_extraction.text as text
from sklearn import decomposition
# https://de.dariah.eu/tatom/topic_model_python.html

os.chdir("/Users/tylerworthington/Git_Repos")

df = pd.read_csv("cleaned_tweets.csv")

vectorizer = text.CountVectorizer()
dtm = vectorizer.fit_transform(df.final_combined_text).toarray()
vocab = np.array(vectorizer.get_feature_names())

# Parameters for topic model
num_topics = 20

num_top_words = 20

clf = decomposition.NMF(n_components=num_topics, random_state=1)

# train model
doctopic = clf.fit_transform(dtm)

# display results
topic_words = []

for topic in clf.components_:
    word_idx = np.argsort(topic)[::-1][0:num_top_words]
    topic_words.append([vocab[i] for i in word_idx])

for t in range(len(topic_words)):
    print("Topic {}: {}".format(t, ' '.join(topic_words[t][:15])))
