# TODO
# Memory Needed
    # of docs * size of vocabulary
    * unit of memory for the document term matrix
    #if it's a tf-idf matrix, they store the values as floating point (roughly 4 B, capital B is byte and lowercase b is bit)
    #if it's just document-term frequency, it's probably an int
    then you have total memory consumption in bytes
    divide by 1024 B to get that value to Kilobytes (KB)
    divide again by 1024 (KB) to get to MB

# Language problems
* filter out multiple stop word languages?

# Dimension Reduction
* decreasing number of unique words

#Langauge Processing
* strip_accents

# Consider other implementations
* Streaming lda
* Mahout
    http://sujitpal.blogspot.com/2013/10/topic-modeling-with-mahout-on-amazon-emr.html
    https://mahout.apache.org/users/clustering/latent-dirichlet-allocation.html
* Mallet
    http://www.oracle.com/technetwork/articles/java/micro-1925135.html
* Gensim
