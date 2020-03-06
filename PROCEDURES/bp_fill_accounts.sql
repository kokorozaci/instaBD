CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_fill_profiles`(user_name VARCHAR(50), 
	user_id BIGINT, 
	full_name VARCHAR(100),
    biography TEXT,
    busness_category_name VARCHAR(150),
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
	OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code varchar(100);
   	DECLARE error_string varchar(100);
    DECLARE busness_category_id bigint;

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
		        
    START TRANSACTION;
   		if busness_category_name = 'None' then
   			set busness_category_id := null;
   		elseif (select id from busness_category where name = busness_category_name) is null then 
   			INSERT INTO busness_category (name) values (busness_category_name);
			set busness_category_id := last_insert_id();
   		else 
   			set busness_category_id := (select id from busness_category where name = busness_category_name);
   		end if;
   	
   	-- set busness_category_id := (select id from busness_category where name = busness_category_name);
   		
		INSERT INTO users (id, name)
		VALUES (user_id, user_name)
		ON DUPLICATE KEY 
    	UPDATE 
    		name = user_name; 

		insert into users_profiles (user_id, full_name, biography, busness_category_id, website, counts_media, counts_followed_by,
			counts_follows, profile_pic_url, profile_pic_url_hd, connected_fb_page, country_block, has_channel, highlight_reel_count,
			is_joined_recently, is_private, is_verified)
		values (user_id, full_name, biography, busness_category_id, website, counts_media, counts_followed_by,
			counts_follows, profile_pic_url, profile_pic_url_hd, connected_fb_page, country_block, has_channel, highlight_reel_count,
			is_joined_recently, is_private, is_verified)
    	ON DUPLICATE KEY 
    	UPDATE 
    		counts_media = counts_media,
    		counts_followed_by = counts_followed_by,
    		counts_follows = counts_follows,
    		busness_category_id = busness_category_id;
    					
	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END