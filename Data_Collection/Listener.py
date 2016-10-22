import datetime
import time
import tweepy
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import sys
#from pymongo import MongoClient
import json
import psycopg2

conn = psycopg2.connect("dbname='cultural_mapper' user='tylerworthington' host='localhost'")

start_time = time.time()  # grabs the system time
 # track list
class listener(StreamListener):
    def __init__(self, start_time, time_limit=120):

        self.time = start_time
        self.limit = time_limit

    def on_data(self, status):
        d = json.loads(status)
        while (time.time() - self.time) < self.limit:
            try:
                #if d['coordinates'] is not None:
                    cur = conn.cursor()
                    command = ("INSERT INTO city_primary( id, created_at, source, text, tweet_lang, user_id, long, lat, user_location, user_handle, user_desc, user_lang ) VALUES ('%s','%s','%s','%s', '%s', '%s', '%s','%s','%s','%s', '%s', '%s');" % (d['id'],(datetime.datetime.strptime(d['created_at'],'%a %b %d %H:%M:%S +0000 %Y')),d['source'],d['text'].replace("'","''"),d['lang'],d['user']['id'],d['coordinates']['coordinates'][0],d['coordinates']['coordinates'][1],d['user']['location'],d['user']['screen_name'],d['user']['description'].replace("'","''"),d['user']['lang']))
                    cur.execute(command)
                    conn.commit()
                    cur.close()
            except BaseException as e:
                print("PRIMATRY Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            try:
                if d['coordinates'] is not None:
                    cur = conn.cursor()
                    command = ("INSERT INTO city_secondary( id, long, lat, coordinates) VALUES ('%s', '%s', '%s', ST_SetSRID(ST_MakePoint(%s, %s),4326));" % (d['id'],d['coordinates']['coordinates'][0],d['coordinates']['coordinates'][1],d['coordinates']['coordinates'][0],d['coordinates']['coordinates'][1]))
                    cur.execute(command)
                    conn.commit()
                    cur.close()
            except BaseException as e:
                print("SECONDARY: Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            try:
                if d['entities'] is not None:
                    cur = conn.cursor()
                    command = ("INSERT INTO city_tertiary( id, hashtags, urls, mentions) VALUES ('%s', '%s', '%s', '%s');" % (d['id'],d['entities']['hashtags'],d['entities']['urls'],d['entities']['user_mentions']))
                    cur.execute(command)
                    conn.commit()
                    cur.close()
            except BaseException as e:
                print("TERTIARY Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            return True

    def on_error(self, status):
        print(status)
        return True
try:
    ckey = ''
    consumer_secret = ''
    access_token_key = ''
    access_token_secret = ''
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
