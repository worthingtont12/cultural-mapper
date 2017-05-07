"""Uncovering Top 15 Words in Predetermined Clusters"""
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from Parsing.Language_processing import df_en

# loading data
df_en['final_combined_text'] = df_en['final_combined_text'].apply(str)
df_en['user_id'] = pd.to_numeric(df_en['user_id'], errors='coerce')
# predetermined cluster assignments

communities = pd.read_csv("Louvain_Clustering/communities/merged_la.csv")
print("df_en")
print(df_en['user_id'])
print("communities")
print(communities['user_id'])
#communities['user_id'] = communities['user_id']

# merging text with community assignments
mergeddf = pd.merge(df_en, communities, on='user_id', how='inner')
print(mergeddf)

# list of unique community numbers
groups = (mergeddf.membership_la.unique()).tolist()
print(groups)

# initialize lists
scorelist = []
groupnum = []

# loop through community numbers
for i in groups:
    mergeddf_loop = mergeddf[mergeddf.membership_la == i]
    print (mergeddf_loop)
    # creating TFIDF Matrix
    transformer = TfidfVectorizer()  # max_df=0.035, min_df=1000)
    tfidf = transformer.fit_transform(mergeddf_loop['final_combined_text']).todense()
    df = pd.DataFrame(tfidf)

    # Dictionary of Words
    vocab = transformer.vocabulary_
    terms = list(vocab.keys())
    df.columns = terms

    # Calculating Average TFIDF Scores for each word
    average_tfidfscores = df.ix[:, :].mean()
    scores = pd.DataFrame(average_tfidfscores)

    # naming columns
    scores.columns = ["Score"]

      # sort column
    scores.sort(["Score"], ascending=False)
    # top 15 words
    scores15 = scores.head(15)

    # append to lists
    scorelist.append(scores15.index.values.tolist())
    groupnum.append(i)
    print (groupnum)
# creating final df
louvain = pd.DataFrame()
louvain["Community"] = groupnum
louvain["Top 15 Words"] = scorelist
print(scorelist)
# Write out csv
louvain.to_csv("Top_15_Words_Per_Community.csv")



