/*
ѕокупательска€ активность (вопросов о цене в среднем на 1 пост) по сути отражает проент целевых комментариев в средне в аккаунте
*/

USE instabd;

DROP FUNCTION IF EXISTS f_buying_activity;

DELIMITER $$ 
CREATE FUNCTION f_buying_activity(check_user_id BIGINT)
RETURNS FLOAT READS SQL DATA
  BEGIN
    DECLARE count_posts int;
   	declare count_buying_question int;
 
   set count_buying_question = 
   		(select count(*)
		from medias md
		join comments cmm
			on md.id = cmm.media_id
		where (cmm.body like '%куп%' or cmm.body like '%цен%') and md.owner_id <> cmm.owner_id and md.owner_id = check_user_id);

   		/*
	set count_posts = 
   		(select count(*)
   		 from medias
   		 where owner_id = check_user_id);
   		*/
	
	set count_posts = 
   		(select count(*)
			from medias md
			right join comments cmm
				on md.id = cmm.media_id
			where md.owner_id = check_user_id);
   		
    RETURN (count_buying_question/count_posts)*100;
  END$$ 
DELIMITER ; 


-- проверка

select f_giveaway_frequency_n(16008823); 

-- посты только с известными комментари€ми
select count(*)
from 
(select md.shortcode 
		from medias md
		right join comments cmm
			on md.id = cmm.media_id
		where md.owner_id = 16008823
	group by md.id) media_c;

-- количество комментарив под 'известными' постами
select count(*)
from medias md
		right join comments cmm
			on md.id = cmm.media_id
		where md.owner_id = 16008823;
		
select count(*)
   		 from medias
   		 where owner_id = 16008823;
   		 
select name from users where id = 16008823;