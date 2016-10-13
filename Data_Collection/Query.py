import re
from pymongo import MongoClient
client = MongoClient('localhost', 27017)
db = client['twitter1_db']
collection = db['twitter_collection']
tweets_iterator = collection.find()
for tweet in tweets_iterator:
    if tweet['lang'] == 'en':
        tmp = ' '.join(re.sub("(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)", " ", tweet['text']).split())
        print(tmp)
