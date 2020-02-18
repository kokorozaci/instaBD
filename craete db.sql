-- create database instaBD;

use instabd;

DROP TABLE IF EXISTS hashtags;
CREATE TABLE hashtags (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    id_origin BIGINT unique,
	name VARCHAR(50),
	profile_pic_url VARCHAR(255),
	hashtag_to_media_count BIGINT,
	allow_following BIT default 0,
	is_following BIT default 0,
	is_top_media_only BIT default 0,
    
    INDEX hashtag_name_idx(name)
);


DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255)

);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
	shortcode VARCHAR(255) unique not null,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    display_url VARCHAR(255),
    media_to_comment INT,
    media_to_likes INT,
    dimensions_height INT,
    dimensions_width INT,
    created_at_timestamp INT,
    thumbnail_resources JSON,
    is_video BIT default 0,
    video_view_count INT,
    INDEX (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);


DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY 

);