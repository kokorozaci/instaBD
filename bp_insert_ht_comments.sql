CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_insert_ht_comments`(hashtag_name varchar(100), comment_id bigint)
begin
	DECLARE hashtag_id bigint;

	set hashtag_id := (select id from hashtags where name = hashtag_name);

	if hashtag_id then
		insert ignore into comments_hashtags (comment_id, hashtag_id)
        values (comment_id, hashtag_id);
    else
    	insert into hashtags (name)
    	values (hashtag_name);
    	set hashtag_id := last_insert_id();
    	insert into comments_hashtags (comment_id, hashtag_id)
        values (comment_id, hashtag_id);
    end if;

END