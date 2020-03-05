
SET @@global.sql_mode= 'STRICT_TRANS_TABLES';
SET @@global.sql_mode= '';


truncate table users_profiles;
truncate table follows;
delete from users where id = 1;
delete from comments;

truncate table instabd.comments_hashtags;
truncate table instabd.medias_hashtags ;