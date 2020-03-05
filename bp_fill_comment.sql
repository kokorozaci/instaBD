CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_fill_comment`(shortcode VARCHAR(15), 
comment_id bigint, 
body text,
created_at_timestamp INT, 
owner_id BIGINT,
profile_url VARCHAR(500), 
owner_username VARCHAR(255), 
OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code varchar(100);
   	DECLARE error_string varchar(100);
    DECLARE media_id bigint;

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
		        
    START TRANSACTION;
   		set media_id := (select id from medias where shortcode = shortcode);
   		
		if (select id from users where id = owner_id) is Null then 
			INSERT INTO users (id, name)
		  		VALUES (owner_id, owner_username); 
		else 
		update users set name = owner_username where id = owner_id;
		end if;
	
		insert ignore users_profiles (user_id, profile_pic_url) values (owner_id, profile_url);

		insert ignore into comments (id, owner_id, media_id, body, created_at)
		values (comment_id, owner_id, media_id, body, created_at_timestamp);
	
	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END