# !/usr/bin/python3
# -*- coding: utf-8 -*-

import pymysql
import re
from shlex import quote

NULL = 'NULL'

class Extracter:
    def __init__(self):
        self.hashtag_re = re.compile("(?:^|[\S\s])[＃#]{1}(\w+)", re.UNICODE)
        self.mention_re = re.compile("(?:^|\s)[＠ @]{1}([^\s#<>[\]|{}]+)", re.UNICODE)

    def hashtags(self, text):
        return self.hashtag_re.findall(text)

    def mentions(self, text):
        return self.mention_re.findall(text)

class ParseMedia:
    def __init__(self):
        self.edges = None
        self.con = pymysql.connect('localhost', 'root',
                                   'q3141592654', 'instabd')
        self.hashtag_id = NULL
        self.hashtag_name = NULL
        self.cur = None
        self.error_medias = []
        self.extract = Extracter()

    def parse_ht_info(self, json):
        with self.con:
            self.cur = self.con.cursor(pymysql.cursors.DictCursor)
            self.cur.execute(f"insert into hashtags (name, id_by_instagram, count_media, profile_pic_url) "
                             f"values ('{json['data']['hashtag']['name']}', '{json['data']['hashtag']['id']}', "
                             f"'{json['data']['hashtag']['edge_hashtag_to_media']['count']}', "
                             f"'{json['data']['hashtag']['profile_pic_url']}') "
                             f"ON DUPLICATE KEY UPDATE name='{json['data']['hashtag']['name']}', "
                             f"id_by_instagram = '{json['data']['hashtag']['id']}', "
                             f"count_media = '{json['data']['hashtag']['edge_hashtag_to_media']['count']}', "
                             f"profile_pic_url = '{json['data']['hashtag']['profile_pic_url']}';")
            self.cur.execute(f"select id from hashtags where name = '{json['data']['hashtag']['name']}';")
            self.hashtag_name = json['data']['hashtag']['name']
            self.hashtag_id = self.cur.fetchall()[0]['id']

    def parse_profiles(self, json):
        with self.con:
            self.cur = self.con.cursor(pymysql.cursors.DictCursor)
            try:
                self.cur.execute(
                    f"call bp_fill_profiles('{quote(json['username'])}', {json['id']}, "
                    f"'{json.get('full_name', NULL)}', {quote(json['biography'])}, '{json.get('business_category_name', 'None')}', "
                    f"'{json['website']}', {json['counts']['media']}, {json['counts']['followed_by']}, "
                    f"{json['counts']['follows']}, '{json['profile_pic_url']}',"
                    f"'{json['profile_pic_url_hd']}', '{json['connected_fb_page']}', "
                    f"'{json['country_block']}', {json['has_channel']}, {json['highlight_reel_count']}, "
                    f"{json['is_joined_recently']}, {json['is_private']}, "
                    f"{json['is_verified']}, @tran_result);")
            except Exception as e:
                print(e)
                self.cur.execute(
                    f"call bp_fill_profiles('{quote(json['username'])}', {json['id']}, "
                    f"{NULL}, {quote(json['biography'])}, '{json.get('business_category_name', NULL)}', "
                    f"'{json['website']}', {json['counts']['media']}, {json['counts']['followed_by']}, "
                    f"{json['counts']['follows']}, '{json['profile_pic_url']}', '{json['profile_pic_url_hd']}', "
                    f"'{json['connected_fb_page']}', "
                    f"'{json['country_block']}', {json['has_channel']}, {json['highlight_reel_count']}, "
                    f"{json['is_joined_recently']}, {json['is_private']}, "
                    f"{json['is_verified']}, @tran_result);")

    def insert_user(self, user_id=NULL, user_name=NULL):
        with self.con:
            self.cur = self.con.cursor(pymysql.cursors.DictCursor)
            if user_name == NULL:
                self.cur.execute(f"insert ignore into users (id, name) values ({user_id}, '{quote(user_name)}');")
            else:
                self.cur.execute(f"insert into users (id, name) values ({user_id}, '{quote(user_name)}')"
                                 f"ON DUPLICATE KEY UPDATE name='{quote(user_name)}';")

    def parse_followers(self, edges, user_id, user_is_follower=1):
        if not edges:
            return
        self.edges = edges
        with self.con:
            self.cur = self.con.cursor(pymysql.cursors.DictCursor)
            for follows in self.edges:
                try:
                    self.cur.execute(f"call bp_fill_follows ({user_is_follower}, {user_id}, '{quote(follows['username'])}',"
                                     f"{follows['id']}, '{follows.get('full_name', NULL)}', '{follows['profile_pic_url']}',"
                                     f"{follows['is_private']}, {follows['is_verified']}, @tran_result);")
                except Exception as e:
                    self.cur.execute(
                        f"call bp_fill_follows ({user_is_follower}, {user_id}, '{quote(follows['username'])}',"
                        f"{follows['id']}, {NULL}, '{follows['profile_pic_url']}',"
                        f"{follows['is_private']}, {follows['is_verified']}, @tran_result);")

    def parse_edges(self, edges):
        self.edges = edges  # json["data"]["hashtag"]["edge_hashtag_to_media"]["edges"]
        with self.con:
            self.cur = self.con.cursor(pymysql.cursors.DictCursor)
            for media in self.edges:
                if media['node']['edge_media_to_caption']['edges']:
                    body = quote(media['node']['edge_media_to_caption']['edges'][0]['node']['text'])
                    hashtags = self.extract.hashtags(body)
                else:
                    body = NULL
                    hashtags = None
                try:
                    self.cur.execute(
                        f"call bp_fill_medias('{media['node']['__typename']}', {media['node']['id']}, {self.hashtag_id}, '{media['node']['shortcode']}',"
                        f"{media['node']['owner']['id']}, {body},"
                        f"{media['node']['taken_at_timestamp']}, {quote(media['node']['display_url'])}, "
                        f"{media['node']['dimensions']['height']}, {media['node']['dimensions']['width']},"
                        f"{media['node']['edge_media_to_comment']['count']}, {media['node']['edge_liked_by']['count']}, "
                        f"{media['node']['is_video']}, {media['node'].get('video_view_count', NULL)}, "
                        f"{quote(media['node'].get('accessibility_caption', NULL))}, @tran_result);")
                    self.cur.execute("SELECT @tran_result;")
                except Exception as e:
                    print(e)
                    self.cur.execute(
                        f"call bp_fill_medias('{media['node']['__typename']}', {media['node']['id']}, {self.hashtag_id}, "
                        f"'{media['node']['shortcode']}',"
                        f"{media['node']['owner']['id']}, {NULL},"
                        f"{media['node']['taken_at_timestamp']}, {quote(media['node']['display_url'])}, "
                        f"{media['node']['dimensions']['height']}, {media['node']['dimensions']['width']},"
                        f"{media['node']['edge_media_to_comment']['count']}, {media['node']['edge_liked_by']['count']}, "
                        f"{media['node']['is_video']}, {media['node'].get('video_view_count', NULL)}, "
                        f"{NULL}, @tran_result);")
                    self.error_medias.append(media['node']['shortcode'])
                if hashtags:
                    for ht in hashtags:
                        if self.hashtag_name in hashtags:
                            hashtags.remove(self.hashtag_name)
                        self.cur.execute(f"call bp_insert_ht('{ht}', {media['node']['id']});")

    def parse_comments(self, comments, shortcode):
        self.comments = comments[0]  # json["data"]["hashtag"]["edge_hashtag_to_media"]["edges"]
        with self.con:
            self.cur = self.con.cursor(pymysql.cursors.DictCursor)
            for comment in self.comments:
                text = quote(comment['text'])
                hashtags = self.extract.hashtags(text)
                try:
                    self.cur.execute(
                        f"call bp_fill_comment('{shortcode}', {comment['id']}, {quote(comment['text'])},"
                        f"{comment['created_at']}, {comment['owner']['id']}, '{comment['owner']['profile_pic_url']}',"
                        f"'{quote(comment['owner']['username'])}', @tran_result);")
                    # self.cur.execute('select @tran_result;')
                    # print(self.cur.fetchall())
                except Exception as e:
                    try:
                        self.cur.execute(
                            f"call bp_fill_comment('{shortcode}', {comment['id']}, '{comment['text']}',"
                            f"{comment['created_at']}, {comment['owner']['id']}, '{comment['owner']['profile_pic_url']}',"
                            f"'{quote(comment['owner']['username'])}', @tran_result);")
                    except Exception as e:
                        print('1', e)
                    print(e)
                else:
                    if hashtags:
                        for ht in hashtags:
                            self.cur.execute(f"call bp_insert_ht_comments('{ht}', {comment['id']});")

    def media_hashtags(self):
        index = 0
        with self.con:
            self.cur = self.con.cursor(pymysql.cursors.DictCursor)
            self.cur.execute(f"select body, id from medias where body rlike '＃|#' "
                             f"and id not in (select media_id from medias_hashtags);")
            media_body_id = self.cur.fetchall()
            for med in media_body_id:
                body = med['body']
                hashtags = self.extract.hashtags(body)
                if hashtags:
                    for ht in hashtags:
                        self.cur.execute(f"call bp_insert_ht('{ht}', {med['id']});")
                        index += 1
                        if index%5000 == 0:
                            self.con.commit()



if __name__ == '__main__':
    # class MyClient(Client):
    #     @staticmethod
    #     def _extract_rhx_gis(html):
    #         options = string.ascii_lowercase + string.digits
    #         text = ''.join([random.choice(options) for _ in range(8)])
    #         return hashlib.md5(text.encode()).hexdigest()
    #
    #
    # web_api = MyClient(auto_patch=True, drop_incompat_keys=False)
    #
    # tag_list = ['linen']
    # hashtag = tag_list[0]
    # end_cursor = None
    # count = 50
    #
    # tag_all = web_api.tag_feed(hashtag, count=count, end_cursor=end_cursor)
    pm = ParseMedia()
    # pm.parse_ht_info(tag_all)  # сохраняем информацию о хештеге
    # pm.parse_edges(tag_all)  # сохраняем информациюо постах, эта часть используется в цикле
    # print(pm.error_medias)
    pm.media_hashtags()
