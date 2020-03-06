# !/usr/bin/python3
# -*- coding: utf-8 -*-

import pymysql
import hashlib
import string
import random
from time import sleep
from datetime import datetime
from instagram_web_api import Client, ClientCompatPatch, ClientError, ClientLoginError
from save_to_mysql.save_from_hashtag_serch import ParseMedia


class MyClient(Client):
    @staticmethod
    def _extract_rhx_gis(html):
        options = string.ascii_lowercase + string.digits
        text = ''.join([random.choice(options) for _ in range(8)])
        return hashlib.md5(text.encode()).hexdigest()


web_api = MyClient(auto_patch=True, drop_incompat_keys=False)

con = pymysql.connect('localhost', 'root',
                      'q3141592654', 'instabd')

with con:
    cur = con.cursor(pymysql.cursors.DictCursor)
    cur.execute(f"select shortcode from medias where count_comments > 10 and body not rlike "
                     f"'розыгрыш|конкурс|победитель|помогите|разыгрываем|подпишитесь|дарим' "
                     f"order by created_at_timestamp desc limit 10000;")
    shortcode_list = cur.fetchall()
pm = ParseMedia()
pointer = None
for short_code in shortcode_list:
    while True:
        time1 = datetime.now()
        try:
            comments = web_api.media_comments(short_code['shortcode'], count=50, end_cursor=pointer)
        except Exception as e:
            print(e)
            sleep(2)
            pointer = None
            break
        for comment in comments[0]:
            pm.parse_comments(comments, short_code['shortcode'])
        sleep(2)
        print(datetime.now()-time1)
        if 'end_cursor' in comments[1]:
            pointer = comments[1]['data']['shortcode_media']['edge_media_to_comment']['page_info']['end_cursor']
        else:
            pointer = None
            break
