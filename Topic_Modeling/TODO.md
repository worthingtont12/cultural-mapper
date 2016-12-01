# TODO
# Memory Needed
    # of docs * size of vocabulary
    * unit of memory for the document term matrix
    #if it's a tf-idf matrix, they store the values as floating point (roughly 4 B, capital B is byte and lowercase b is bit)
    #if it's just document-term frequency, it's probably an int
    then you have total memory consumption in bytes
    divide by 1024 B to get that value to Kilobytes (KB)
    divide again by 1024 (KB) to get to MB

# Dimension Reduction
    * decreasing number of unique words

# Consider other implementations
* Streaming lda
* hadoop lda
