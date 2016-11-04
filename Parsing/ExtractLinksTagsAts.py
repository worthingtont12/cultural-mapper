''' Feature Extraction of Mentions, Hashtags and Links '''

import pandas as pd
import re

# Read in the tweets - here it's just a sample as proof of concept.
tweets = pd.read_csv('102616 Tweets.csv', nrows = 200)


# Create empty lists for each category.
mentions = []
links = []
hashtags = []

# Iterate over the text, extracting and adding
# Would "apply" be faster?

for tweet in tweets['text']:
    mentions.append(re.findall('@\S*\b', tweet))
    links.append(re.findall('https?://\S*', tweet))
    hashtags.append(re.findall('#\S*\b', tweet))

# Append features as a new column to the existing dataframe.
tweets['hashtags'] = hashtags
tweets['mentions'] = mentions
tweets['links'] = links
