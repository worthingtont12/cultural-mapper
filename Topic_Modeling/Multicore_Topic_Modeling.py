"""Topic Modeling on Authored Tweets Using Parralelized Latent Dirichlet Allocation."""
import logging
from multiprocessing import cpu_count
from operator import itemgetter
from gensim import corpora, models
from gensim.models.ldamulticore import LdaMulticore
# local modules
# move this file to root directory in order for this to load properly
from Parsing.Language_processing import df_en
# logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

# functions


def max_val(maxed_value, index):
    """
    Function takes the highest value in a list within a list.

    Parameters
    ----------
    maxed_value : Value to operate on.
    index : First value of list.

    """
    return max(enumerate(map(itemgetter(index), maxed_value)), key=itemgetter(1))


# import data
df_en['final_combined_text'] = df_en['final_combined_text'].apply(str)

# creating dictionary
dictionary = corpora.Dictionary(line.lower().split() for line in df_en['final_combined_text'])

# dimension reduction
dictionary.filter_extremes(no_below=1000, no_above=0.75)

# formatting corpus for use


class MyCorpus(object):

    def __iter__(self):
        for line in df_en['final_combined_text']:
            yield dictionary.doc2bow(line.lower().split())


corpus = MyCorpus()

# Save corpus to disk
corpora.MmCorpus.serialize('Topic_Modeling/Data/75Data/en_corpus.mm', corpus)

# Load corpus
corpus = corpora.MmCorpus('Topic_Modeling/Data/75Data/en_corpus.mm')

# creating tfidf matrix
tfidf = models.TfidfModel(corpus)
corpus_tfidf = tfidf[corpus]

# train model
lda = LdaMulticore(corpus_tfidf, workers=cpu_count() - 1, id2word=dictionary, num_topics=20)
print(lda)

# Topic distribution for documents
docTopicProbMat = lda[corpus]
print(type(docTopicProbMat[0]))

# Word distribution for topics
K = lda.num_topics
topicWordProbMat = lda.print_topics(K)
print(topicWordProbMat)

# assigning Topic to documents with probability fit
topic_assignment = []
topic_probabilities = []
for n in range(len(df_en['final_combined_text'])):
    topic_assignment.append(max_val(docTopicProbMat[n], -1)[0])
    topic_probabilities.append(max_val(docTopicProbMat[n], -1)[1])

df_en['top_topic'] = topic_assignment
df_en['topic_prob'] = topic_probabilities

# saving results
lda.save('Topic_Modeling/Data/en_lda.model')
df_en.to_csv('Topic_Modeling/Data/75Data/English_LA.csv',
             columns=['user_id', 'user_language', 'top_topic', 'topic_prob'])
