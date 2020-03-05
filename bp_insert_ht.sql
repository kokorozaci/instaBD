CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_insert_ht`(hashtag_name varchar(100), media_id bigint)
begin
	DECLARE hashtag_id bigint;

	set hashtag_id := (select id from hashtags where name = hashtag_name);

	if hashtag_id then
		insert ignore into medias_hashtags (media_id, hashtag_id) values (media_id, hashtag_id);
    else
    	insert into hashtags (name)
    	values (hashtag_name);
    	set hashtag_id := last_insert_id();
    	insert into medias_hashtags (media_id, hashtag_id)
        values (media_id, hashtag_id);
    end if;

END