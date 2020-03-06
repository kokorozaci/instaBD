CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_fill_follows`(user_is_follower BIT, 
	owner_id BIGINT,
	user_name VARCHAR(50), 
	user_id BIGINT, 
	full_name VARCHAR(100),
	profile_pic_url VARCHAR(255),
	is_private BIT,
	is_verified BIT, 
	OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code varchar(100);
   	DECLARE error_string varchar(100);

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
		        
    START TRANSACTION;
		insert into users (id, name) 
   		values (user_id, user_name)
		ON DUPLICATE KEY UPDATE name=user_name;
		
        insert ignore into users_profiles (user_id, full_name, profile_pic_url, is_private, is_verified)
        values (user_id, full_name, profile_pic_url, is_private, is_verified);
   		
       if user_is_follower then    
            insert ignore into follows (follower_id, follows_id)
            values (owner_id, user_id);
         else
            insert ignore into follows (follower_id, follows_id)
            values (user_id, owner_id);
          
   		 end if;
   	
    					
	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END