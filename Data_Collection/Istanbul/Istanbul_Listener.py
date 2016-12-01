"""

This is a listener for tweets in Istanbul.
Thank you Mohammad al Boni for your initial assistance.

"""
import datetime
import time
import sys
import json
import tweepy
from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import psycopg2
from keys import *
from login_info import *

conn = psycopg2.connect(
    "dbname='culturalmapper_LA' user= host= password=")


class listener(StreamListener):

    def on_data(self, status):
        d = json.loads(status)
        while True:
            try:
                cur = conn.cursor()
                command = ("INSERT INTO istanbul_city_primary(id, created_at, source, text, text_lang, user_id, user_location, user_handle, user_lang ) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');" % (
                    d['id'], (datetime.datetime.strptime(d['created_at'], '%a %b %d %H:%M:%S +0000 %Y')), d['source'], d['text'].replace("'", ""), d['lang'], d['user']['id'], d['user']['location'], d['user']['screen_name'], d['user']['lang']))
                cur.execute(command)
                conn.commit()
                cur.close()
            except BaseException as e:
                print("PRIMARY Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            try:
                if d['coordinates'] is not None:
                    cur = conn.cursor()
                    command = ("INSERT INTO istanbul_city_secondary( id, long, lat) VALUES ('%s', '%s', '%s');" % (
                        d['id'], d['coordinates']['coordinates'][0], d['coordinates']['coordinates'][1]))
                    cur.execute(command)
                    conn.commit()
                    cur.close()
            except BaseException as e:
                print("SECONDARY: Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            try:
                if d['is_quote_status'] is True:
                    cur = conn.cursor()
                    command = ("INSERT INTO istanbul_quoted(id, q_id, q_created_at, q_text, q_text_lang, q_user_id, q_user_location, q_user_handle, q_user_lang ) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');" % (d['id'], d['quoted_status']['id'], (datetime.datetime.strptime(d['quoted_status'][
                               'created_at'], '%a %b %d %H:%M:%S +0000 %Y')), d['quoted_status']['text'].replace("'", " "), d['quoted_status']['lang'], d['quoted_status']['user']['id'], d['quoted_status']['user']['location'], d['quoted_status']['user']['screen_name'], d['quoted_status']['user']['lang']))
                    cur.execute(command)
                    conn.commit()
                    cur.close()
            except BaseException as e:
                print("User Quoted: Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            try:
                if d['user']['description'] is not None:
                    cur = conn.cursor()
                    command = ("INSERT INTO istanbul_user_desc(id, user_id, user_desc) VALUES ('%s','%s','%s');" % (
                        d['id'], d['user']['id'], d['user']['description'].replace("'", " ")))
                    cur.execute(command)
                    conn.commit()
                    cur.close()
            except BaseException as e:
                print("User Desc: Error on_data: %s %s" % (str(e), status))
                conn.rollback()
            return True

    def on_error(self, status):
        print(status)
        return True


if __name__ == '__main__':
    while 1:
        try:
            ckey = consumer_key
            consumer_secret = consumer_secret
            access_token_key = access_token
            access_token_secret = access_token_secret
            # start instance
            auth = OAuthHandler(ckey, consumer_secret)  # Consumer keys
            auth.set_access_token(access_token_key, access_token_secret)
            api = tweepy.API(auth)
            # initialize Stream object
            twitterStream = Stream(auth=api.auth, listener=listener())
            # set bounding box filter
            twitterStream.filter(locations=[28.448009, 40.802731, 29.45787, 41.23595])
            # Istanbul
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
