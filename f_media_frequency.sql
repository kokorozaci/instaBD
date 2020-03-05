/*
������� ������ �� �������, �������,  post_per_week    - �������� ��������� ��������
*/
USE instabd;

DROP FUNCTION IF EXISTS f_media_frequency;

DELIMITER $$ -- �������� �����������
CREATE FUNCTION f_media_frequency(check_user_id BIGINT)
RETURNS INT READS SQL DATA
  BEGIN
  	DECLARE first_post_date int;
    DECLARE last_post_date int;
    DECLARE count_posts int;
   	declare week_dif FLOAT;

   set count_posts = 
   		(select count(*)
   		 from medias
   		 where owner_id = check_user_id);
   		
   set first_post_date = 
   		(select created_at_timestamp 
   		 from medias
   		 where owner_id = check_user_id
   		 order by created_at_timestamp 
   		 limit 1);
   		
   	 set last_post_date = 
   		(select created_at_timestamp 
   		 from medias
   		 where owner_id = check_user_id
   		 order by created_at_timestamp desc
   		 limit 1);
   		
   	set  week_dif = (last_post_date - first_post_date)/604800;
   
    RETURN ROUND((count_posts/week_dif), 0);
  END$$ 
DELIMITER ; 


-- ��������

set @u_id = (select id from users where name = 'vaganni_77');
select f_media_frequency(@u_id);