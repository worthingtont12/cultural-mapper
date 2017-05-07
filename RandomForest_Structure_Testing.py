"""Uncovering Structure in TF-IDF."""
import logging
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import sklearn.feature_extraction.text as text
from sklearn import model_selection
from Parsing.Language_processing import df_en

logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

# import data
df_en['final_combined_text'] = df_en['final_combined_text'].apply(str)
# creating tfidf matrix
vectorizer = text.TfidfVectorizer(max_df=0.075, min_df=1000)
dtm = vectorizer.fit_transform(df_en.final_combined_text).toarray()

corpus_tfidf = pd.DataFrame(dtm)

# permute the ifidf
random_corpus_tfidf = pd.DataFrame(np.random.permutation(corpus_tfidf))

# label the permuted matrix
random_corpus_tfidf['random'] = np.zeros(shape=(len(df_en['final_combined_text']), 1))

# label the non-permuted matrix
corpus_tfidf['random'] = np.ones(shape=(len(df_en['final_combined_text']), 1))

# cocatenate matrixes
tfidfs = pd.concat([random_corpus_tfidf, corpus_tfidf])

# splitting target attribute from examples
X = tfidfs[tfidfs.columns[:-1]]
Y = np.array(tfidfs.loc[:, ['random']])

# Random Forest
seed = 7
rf = RandomForestClassifier(n_jobs=-1)

# Cross Validate
kfold = model_selection.KFold(n_splits=10, random_state=seed)
results = model_selection.cross_val_score(rf, X, Y.ravel(), cv=kfold)

# results
print(results.mean())
