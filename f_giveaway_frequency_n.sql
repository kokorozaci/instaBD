/*
 * частота конкурсов (посты с конкурсами / все посты) в %  - частота проведения конкурсов относительно всех известных постов
 */
USE instabd;

DROP FUNCTION IF EXISTS f_giveaway_frequency_n;

DELIMITER $$ 
CREATE FUNCTION f_giveaway_frequency_n(check_user_id BIGINT)
RETURNS FLOAT READS SQL DATA
  BEGIN
    DECLARE count_posts_giw int;
   	declare count_posts int;
 

   set count_posts_giw = 
   		(select count(*)
   		from (select shortcode
		from medias
		where owner_id = check_user_id and body rlike 'розыгрыш|конкурс|победитель|помогите|разыгрываем|подпишитесь|дарим') m_giw);

   		
	set count_posts = 
   		(select count(*)
   		 from medias
   		 where owner_id = check_user_id);
   
    RETURN (count_posts_giw/count_posts) * 100;
  END$$ 
DELIMITER ; 


-- проверка

select round(f_giveaway_frequency_n(16008823), 2) '% конкурсов';  -- обычных постов на 1 конкурсный