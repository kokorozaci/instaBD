CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_fill_medias`(media_types_name VARCHAR(255), 
media_id bigint, 
hashtag_id BIGINT, 
shortcode VARCHAR(12), 
owner_id BIGINT, 
body text, 
created_at_timestamp INT, 
display_url VARCHAR(255), 
dimensions_height INT,
dimensions_width INT, 
count_comments INT, 
count_likes INT, 
is_video BIT, 
video_view_count BIGINT, 
accessibility_caption VARCHAR(100), 
OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code varchar(100);
   	DECLARE error_string varchar(100);
    DECLARE media_types_id bigint;

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
		        
    START TRANSACTION;
   		/*
   		if (select id from media_types where name = media_types_name) is null then 
   			INSERT INTO media_types (name) values (media_types_name);
			set media_types_id := last_insert_id();
   		else 
   			set media_types_id := (select id from media_types where name = media_types_name);
   		end if;
*/
   		set media_types_id := (select id from media_types where name = media_types_name);
   		
		if (select id from users where id = owner_id) is Null then 
			INSERT INTO users (id)
		  		VALUES (owner_id); 
		end if;

		insert into medias (id, shortcode, media_type_id, owner_id, body, created_at_timestamp, display_url, dimensions_height, dimensions_width,
			count_comments, count_likes, is_video, video_view_count, accessibility_caption)
		values (media_id, shortcode, media_types_id, owner_id, body, created_at_timestamp, display_url, dimensions_height,
    		dimensions_width, count_comments, count_likes, is_video, video_view_count, accessibility_caption)
    	ON DUPLICATE KEY 
    	UPDATE 
    		count_likes = count_likes,
    		count_comments = count_comments;
    				
    	if hashtag_id then
    		insert into instabd.medias_hashtags (media_id, hashtag_id) values (media_id, hashtag_id);
    	end if;
	
	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END