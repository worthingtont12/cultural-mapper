# Order
1. Joining
2. Cleaning
3. Language Processing

# Description
The cleaning is broken up into 3 parts for simplicity. The first script , Joining, takes in all the datasets and joins them into one dataframe. The second script , Cleaning, joins observations by user_id and does some preliminary text cleaning. It also deletes duplicates and throws out unnecessary variables. The final script, Language Processing, creates the main variable of interest from the merging of all text columns. It also does the necessary text processing for topic modeling, ie stemming, removing case, tokenizing, ect.
