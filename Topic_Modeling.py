"""Topic Modeling on Authored Tweets Using Latent Dirichlet Allocation"""

import smtplib
import numpy as np
import sklearn.feature_extraction.text as text
from sklearn import decomposition
from Parsing.Language_processing import df_en
from Parsing.login_info import username, password2, recipient1


# import data
df_en['final_combined_text'] = df_en['final_combined_text'].apply(str)
print(df_en['final_combined_text'].head)

# create document term matrix
vectorizer = text.CountVectorizer(max_df=0.75, min_df=200, strip_accents='unicode', lowercase=False)
dtm = vectorizer.fit_transform(df_en.final_combined_text).toarray()
vocab = np.array(vectorizer.get_feature_names())

# document term matrix size
print(dtm.shape)

# Parameters for topic model
num_topics = 20

num_top_words = 20

lda = decomposition.LatentDirichletAllocation(
    n_topics=num_topics, learning_method='online', learning_offset=50., random_state=0)

# train model
doctopic = lda.fit_transform(dtm)

# Top words in topic models
topic_words = []

for topic in lda.components_:
    word_idx = np.argsort(topic)[::-1][0:num_top_words]
    topic_words.append([vocab[i] for i in word_idx])

for t in range(len(topic_words)):
    print("Topic {}: {}".format(t, ' '.join(topic_words[t][:15])))


# assigning Topic to documents
topic_assignment = []
for n in range(len(df_en['final_combined_text'])):
    topic_assignment.append(doctopic[n].argmax())
df_en['top_topic'] = topic_assignment


# email when done
server = smtplib.SMTP("smtp.gmail.com", 587)
server.starttls()

server.login(username, password2)

server.sendmail(username, recipient1, 'Topic Models Built')
