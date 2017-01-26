"""Topic Modeling on Authored Tweets Using Parralelized Latent Dirichlet Allocation"""
import smtplib
import logging
from multiprocessing import cpu_count
from gensim import corpora, models
from gensim.models.ldamulticore import LdaMulticore
from Parsing.Language_processing import df_en
from Parsing.login_info import username, password2, recipient1
# logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

# import data
df_en['final_combined_text'] = df_en['final_combined_text'].apply(str)

# creating dictionary
dictionary = corpora.Dictionary(line.lower().split() for line in df_en['final_combined_text'])

# formatting corpus for use


class MyCorpus(object):

    def __iter__(self):
        for line in df_en['final_combined_text']:
            yield dictionary.doc2bow(line.lower().split())


corpus = MyCorpus()
corpora.MmCorpus.serialize('corpus.mm', corpus)  # Save corpus to disk
corpus = corpora.MmCorpus('corpus.mm')  # Load corpus

# creating tfidf matrix
tfidf = models.TfidfModel(corpus)
corpus_tfidf = tfidf[corpus]

# train model
lda = LdaMulticore(corpus_tfidf, workers=cpu_count() - 1, id2word=dictionary, num_topics=20)
print(lda)

# topic distribution for documents
docTopicProbMat = lda[corpus]
print(docTopicProbMat[0])
print(type(docTopicProbMat[0]))

#
K = lda.num_topics
topicWordProbMat = lda.print_topics(K)
print(topicWordProbMat)


# # assigning Topic to documents
# topic_assignment = []
# for n in range(len(df_en['final_combined_text'])):
#     topic_assignment.append(doc_lda[n].argmax())
# df_en['top_topic'] = topic_assignment


# email when done
server = smtplib.SMTP("smtp.gmail.com", 587)
server.starttls()

server.login(username, password2)

server.sendmail(username, recipient1, 'Topic Models Built')
