-- create database instaBD;
DROP DATABASE IF EXISTS instabd;
CREATE DATABASE instabd;
USE instabd;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    name VARCHAR(50),
    INDEX users_name(name)
);


DROP TABLE IF EXISTS busness_category;
CREATE TABLE busness_category(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150)

);

insert into busness_category (id, name)
values (1, 'Personal Goods & General Merchandise Stores'),
(2, 'Creators & Celebrities'),
(3, 'Home Services'),
(4, 'Food & Personal Goods'),
(5, 'General Interest'),
(6, 'Business & Utility Services'),
(7, 'Local Events'),
(8, 'Publishers'),
(9, 'Lifestyle Services');

DROP TABLE IF EXISTS users_profiles;
CREATE TABLE users_profiles (
	user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    biography TEXT,
	busness_category_id BIGINT UNSIGNED NULL,
	website VARCHAR(255),
	counts_media BIGINT,
	counts_followed_by BIGINT,
	counts_follows BIGINT,
	profile_pic_url VARCHAR(255),
	profile_pic_url_hd VARCHAR(255),
	connected_fb_page VARCHAR(255),
    country_block BIT,
    has_channel BIT,
    highlight_reel_count BIGINT,
	is_joined_recently BIT,
	is_private BIT,
	is_verified BIT,
    FOREIGN KEY (user_id) REFERENCES users(id), 
    FOREIGN KEY (busness_category_id) REFERENCES busness_category(id) 
);

DROP TABLE IF EXISTS hashtags;
CREATE TABLE hashtags (
	id SERIAL PRIMARY KEY,
    id_by_instagram BIGINT UNIQUE,
	name VARCHAR(100) UNIQUE NOT NULL,
	count_media BIGINT,
	profile_pic_url VARCHAR(255),
	INDEX hashtag_name_idx(name)
);


DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

insert into media_types (name) 
values 
	('GraphImage'),
	('GraphSidecar'),
	('GraphVideo');

DROP TABLE IF EXISTS medias;
CREATE TABLE medias(
	id SERIAL PRIMARY KEY,
	shortcode VARCHAR(15) UNIQUE NOT NULL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    owner_id BIGINT UNSIGNED NOT NULL,
  	body text,
  	created_at_timestamp INT,
    display_url VARCHAR(255),
    dimensions_height INT,
    dimensions_width INT,
    count_comments INT,
    count_likes INT,
    is_video BIT default 0,
    video_view_count BIGINT,
    accessibility_caption VARCHAR(255),
    INDEX (owner_id),
    FOREIGN KEY (owner_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS medias_hashtags;
CREATE TABLE medias_hashtags(
	media_id BIGINT UNSIGNED NOT NULL,
	hashtag_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (media_id, hashtag_id), 
    FOREIGN KEY (media_id) REFERENCES medias(id),
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(id)
);

CREATE INDEX medias_index ON medias_hashtags(media_id);
CREATE INDEX hashtags_index ON medias_hashtags(hashtag_id);

DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
	id SERIAL PRIMARY KEY,
    owner_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    parent_comment_id BIGINT UNSIGNED,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (owner_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES medias(id),
    FOREIGN KEY (parent_comment_id) REFERENCES comments(id)
);

DROP TABLE IF EXISTS comments_hashtags;
CREATE TABLE comments_hashtags(
	comment_id BIGINT UNSIGNED NOT NULL,
	hashtag_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (comment_id, hashtag_id), 
    FOREIGN KEY (comment_id) REFERENCES comments(id),
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(id)
);
/*
DROP TABLE IF EXISTS mentions;
CREATE TABLE mentions(
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,  -- при заполнении надо продумать как заполнять это поле если упоминание в комментарии или в медиа
	owner_metion_id BIGINT UNSIGNED NOT null,
	PRIMARY KEY (user_id, media_id, owner_metion_id), -- может быть несколько упоминаний под медиа от разных юзеров
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES medias(id),
    FOREIGN KEY (owner_metion_id) REFERENCES users(id)
);
*/

DROP TABLE IF EXISTS likes_media;
CREATE TABLE likes_media(
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, media_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES medias(id)
);

DROP TABLE IF EXISTS likes_comment;
CREATE TABLE likes_comment(
    user_id BIGINT UNSIGNED NOT NULL,
    comment_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, comment_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (comment_id) REFERENCES comments(id)
);

DROP TABLE IF EXISTS follows;
CREATE TABLE follows(
	follower_id BIGINT UNSIGNED NOT NULL, -- подписчик
	follows_id BIGINT UNSIGNED NOT NULL, -- тот на кого подписан
	PRIMARY KEY (follower_id, follows_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (follower_id) REFERENCES users(id),
    FOREIGN KEY (follows_id) REFERENCES users(id)
);

CREATE INDEX follower_index ON follows(follower_id);
CREATE INDEX follows_index ON follows(follows_id);

