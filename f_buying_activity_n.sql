/*
Покупательская активность (вопросы о цене / общее количество комментов не от автора )
*/

USE instabd;

DROP FUNCTION IF EXISTS f_buying_activity_n;

DELIMITER $$ 
CREATE FUNCTION f_buying_activity_n(check_user_id BIGINT)
RETURNS FLOAT READS SQL DATA
  BEGIN
    DECLARE count_comment int;
   	declare count_buying_question int;
 
   set count_buying_question = 
   		(select count(*)
		from medias md
		join comments cmm
			on md.id = cmm.media_id
		where (cmm.body like '%куп%' or cmm.body like '%цен%') and md.owner_id <> cmm.owner_id and md.owner_id = check_user_id);


	set count_comment = 
   		(select count(*)
		from medias md
		join comments cmm
			on md.id = cmm.media_id
		where md.owner_id <> cmm.owner_id and md.owner_id = check_user_id);
   		
    RETURN (count_buying_question/count_comment)*100;
  END$$ 
DELIMITER ; 

-- проверка

select round(f_buying_activity_n(16008823), 2) as BA; 

-- анализ постов с известными комментариями, тут их всего 3 шт. + исключены комментарии автора поста
select count(*) 
from medias md
join comments cmm
	on md.id = cmm.media_id
where md.owner_id <> cmm.owner_id and  md.owner_id = 16008823
group by md.id;

-- информация берётся из instabd.medias.count_comments  т.е. тут не исключены посты для которых не скачаны комментарии
select sum(count_comments) comments 
from medias
where owner_id = 16008823;