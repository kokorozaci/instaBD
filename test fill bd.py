# !/usr/bin/python3
# -*- coding: utf-8 -*-

import pymysql
import hashlib
import string
import random
import json
from time import sleep
from datetime import datetime, timedelta
import pandas as pd
import openpyxl
import os
import re
from os import path
from instagram_web_api import Client, ClientCompatPatch, ClientError, ClientLoginError
from pandas.io.json import json_normalize


class MyClient(Client):
    @staticmethod
    def _extract_rhx_gis(html):
        options = string.ascii_lowercase + string.digits
        text = ''.join([random.choice(options) for _ in range(8)])
        return hashlib.md5(text.encode()).hexdigest()


web_api = MyClient(auto_patch=True, drop_incompat_keys=False)

con = pymysql.connect('localhost', 'root',
                      'q3141592654', 'instabd')

path = 'D:/PyProgects/bot/3_0/json'
files = os.listdir(path)

f_name = [i for i in files if i.endswith('.json')]
print(len(f_name))

with con:
    cur = con.cursor(pymysql.cursors.DictCursor)
    for file in f_name[:30]:
        with open(f'D:/PyProgects/bot/3_0/json/{file}', 'r') as json_line:
            datastore = json.load(json_line)
        biography = datastore['biography']
        if "'" in biography:
            biography = biography.split("'")
            biography = " ".join(biography)
        print(biography)
        if ':' in biography:
            biography = biography.split(":")
            biography = ' '.join(biography)
            print(biography)
        cur.execute(f"INSERT IGNORE INTO users (id, username) VALUES ('{datastore['id']}', '{str(datastore['username'])}')")
        cur.execute(f"INSERT IGNORE INTO profiles (user_id, biography, blocked_by_viewer, country_block, external_url,"
                    f"followed_count, follow_count, full_name, is_business_account, business_category, is_private,"
                    f"is_verified, profile_pic_url, profile_pic_url_hd, connected_fb_page) "
                    f"VALUES ('{str(datastore['id'])}', '{biography}', {datastore['blocked_by_viewer']},"
                    f"'{str(datastore['country_block'])}', '{str(datastore['external_url'])}', "
                    f"'{str(datastore['edge_followed_by']['count'])}', '{str(datastore['edge_follow']['count'])}', "
                    f"'{str(datastore['full_name'])}', {datastore['is_business_account']}"
                    f",'{str(datastore['business_category_name'])}', {datastore['is_private']}, {datastore['is_verified']}"
                    f",'{str(datastore['profile_pic_url'])}', '{str(datastore['profile_pic_url_hd'])}', '{str(datastore['connected_fb_page'])}')")

# tag_list = ['linendress']
# hashtag = tag_list[0]
# end_cursor = None
# count = 50
#
# tag_all = web_api.tag_feed(hashtag, count=count, end_cursor = end_cursor)
# with open(f'D:/PyProgects/instaBD/test.json', "w", encoding="utf-8") as f:
#     json.dump(tag_all, f)
# y = pd.DataFrame.from_dict(json_normalize(tag_all), orient='columns')
# print(y.columns)
