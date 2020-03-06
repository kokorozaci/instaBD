/*
Частота конкурсов в месяц  - насколько аккаунт активно работает с подписчиками и привлекает новую аудиторию
*/

USE instabd;

DROP FUNCTION IF EXISTS f_giveaway_frequency_per_month;

DELIMITER $$ -- выставим разделитель
CREATE FUNCTION f_giveaway_frequency_per_month(check_user_id BIGINT)
RETURNS FLOAT READS SQL DATA
  BEGIN
  	DECLARE first_post_date int;
    DECLARE last_post_date int;
    DECLARE count_posts_giw int;
   	declare week_dif FLOAT;
 

   set count_posts_giw = 
   		(select count(*)
   		from (select shortcode
		from medias
		where owner_id = check_user_id and body rlike 'розыгрыш|конкурс|победитель|помогите|разыгрываем|подпишитесь|дарим') m_giw);

   		
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
   		
   	set  week_dif = (last_post_date - first_post_date)/2592000;
   
    RETURN count_posts_giw/week_dif;
  END$$ 
DELIMITER ; 


-- проверка

-- set @u_id = (select id from users where name = 'vaganni_77');
select f_giveaway_frequency_per_month(1308428836);  -- конкурсов в месяц


-- пользователи с конкурсами
select owner_id, count(*) 
from medias
where body rlike 'розыгрыш|конкурс|победитель|помогите|разыгрываем|подпишитесь|дарим'
group by owner_id;