# !/usr/bin/python3
# -*- coding: utf-8 -*-

import pymysql
import hashlib
import string
import random
import json
import os
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

path = 'D:/PyProgects/bot/3_0/json_info/json'
files = os.listdir(path)

f_name = [i for i in files if i.endswith('.json') and i.startswith('folowers')]
# f_name2 = [i for i in files if i.endswith('.json') and (not (i.startswith('feed') or i.startswith('acc') or i.startswith('folowing') or i.startswith('folowers') or i.startswith('following')))]
# print(len(f_name2))
tag_list = ['linendress']
hashtag = tag_list[0]
end_cursor = None
count = 50

# tag_all = web_api.tag_feed(hashtag, count=count, end_cursor=end_cursor)
user = 1308428836
pm = ParseMedia()
pm.insert_user(user_id=user, user_name='zveroshmotka')
for file in f_name:
    print(file)
    cont = False
    with open(f'D:/PyProgects/bot/3_0/json_info/json/{file}', 'r') as json_line:
        try:
            edges1 = json.load(json_line)
        except Exception as e:
            print(e)
            continue
    pm.parse_followers(edges1, user, user_is_follower=0)
    for follower in edges1:
        i = 0
        while True:
            i += 1
            try:
                with open(f"D:/PyProgects/bot/3_0/json_info/json/following_{follower['id']}_{i}.json", 'r') as json_line:
                    edges = json.load(json_line)
            except Exception as e:
                try:
                    with open(f"D:/PyProgects/bot/3_0/json_info/json/folowing_{follower['id']}_{i}.json", 'r') as json_line:
                        edges = json.load(json_line)
                except Exception as e:
                    print(e)
                    cont = True
                    break
            if follower['id'] == user:
                print('1')
            pm.parse_followers(edges, follower['id'], user_is_follower=1)
        if cont:
            continue
# for file in f_name2:
#
#     print(file)
#     with open(f'D:/PyProgects/bot/3_0/json_info/json/{file}', 'r') as json_line:
#         try:
#             tag_all = json.load(json_line)
#         except Exception as e:
#             print(e)
#     try:
#         pm.parse_ht_info(tag_all)  # сохраняем информацию о хештеге
#         pm.parse_edges(tag_all["data"]["hashtag"]["edge_hashtag_to_media"]["edges"])  # сохраняем информациюо постах, эта часть используется в цикле
#     except Exception as e:
#         print (e)
# print(pm.error_medias)
#
# for file in f_name:
#     with open(f'D:/PyProgects/bot/3_0/json/{file}', 'r') as json_line:
#         try:
#             datastore = json.load(json_line)
#         except Exception as e:
#             print(e)
#     pm.parse_profiles(datastore)
#     pm.parse_edges(datastore.get('edge_owner_to_timeline_media', {}).get('edges', []))
