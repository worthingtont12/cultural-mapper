import datetime
import time
import tweepy
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import sys
from pymongo import MongoClient
import json
import psycopg2

conn = psycopg2.connect("dbname='cultural_mapper' user='tylerworthington' host='localhost'")

start_time = time.time()  # grabs the system time
keyword_list = ['twitter']  # track list


class listener(StreamListener):
    def __init__(self, start_time, time_limit=120):

        self.time = start_time
        self.limit = time_limit
        self.tweet_data = []

    def on_data(self, status):
        d = json.loads(status)
        while (time.time() - self.time) < self.limit:
            try:
                table = "La_Tweets"
                if table != "La_Tweets":
                    command = ("INSERT INTO %s ( created_at, id, text, user_id, coordinates) VALUES ('%s','%s','%s','%s', ST_SetSRID(ST_MakePoint(%s, %s),4326));" % (table, datetime.datetime.strptime(d['created_at'], '%a %b %d %H:%M:%S +0000 %Y'), d['id'], d['text'].replace("'", "''"), d['user']['id'], d['coordinates']['coordinates'][0], d['coordinates']['coordinates'][1]))
                    cur = conn.cursor()
                    cur.execute(command)
                    conn.commit()
                    cur.close()
            except BaseException as e:
                print("Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            return True
    def on_error(self, status):
            print(status)
            return True


try:
    # start instance
    auth = OAuthHandler(ckey, consumer_secret)  # Consumer keys
    auth.set_access_token(access_token_key, access_token_secret)  # Secret Keys
    # initialize Stream object with a time out limit
    twitterStream = Stream(auth, listener(start_time, time_limit=120))
    # set bounding box filter
    twitterStream.filter(locations=[-118.723549, 33.694679, -117.929466, 34.33926])
    # Los Angeles
# various exception handling blocks
except KeyboardInterrupt:
    sys.exit()
except AttributeError as e:
    print('AttributeError was returned, stupid bug')
    pass
except tweepy.TweepError as e:
    print('Below is the printed exception')
    print(e)
    if '401' in e:
        # not sure if this will even work
        print('Below is the response that came in')
        print(e)
        time.sleep(60)
        pass
    else:
        # raise an exception if another status code was returned, we don't like other kinds
        time.sleep(60)
        pass
except Exception as e:
    time.sleep(60)
    pass
