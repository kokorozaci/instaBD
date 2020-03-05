/*
ER Engagement Rate (ER per post = (����� + �����������) / ���������� * 100%)
*/

USE instabd;

DROP FUNCTION IF EXISTS f_engagement_rate;

DELIMITER $$ 
CREATE FUNCTION f_engagement_rate(check_user_id BIGINT)
RETURNS FLOAT READS SQL DATA
  BEGIN
    DECLARE count_likes_comments_per_post int;
    declare count_followers int;
 
-- ���������� � ������������, �� ������ ��� ��� ������� ������ ���� ����������� ������ �����, �.�.  ������ ������� ������, ����������� �� ������������
	set count_likes_comments_per_post = 
   		round((select(((select sum(count_likes)
		from medias
		where owner_id = check_user_id)
		+
		(select sum(count_comments)
		from medias
 		where owner_id = check_user_id))
 		/(select count(*)
 		from medias
 		where owner_id = check_user_id)) as comm_likes), 0);
   		
   	set count_followers = 
   		(select counts_followed_by 
   		 from users_profiles
   		 where user_id = check_user_id);
   
    RETURN (count_likes_comments_per_post / count_followers) * 100; -- ) / count_followers * 100;
  END$$ 
DELIMITER ; 


-- ��������

select round(f_engagement_rate(20803728), 2) as ER;  -- ER

-- ����� � ������� � ������ � ���������
select up.user_id 
from users_profiles up 
join medias m on up.user_id = m.owner_id
where up.counts_followed_by is not null
group by up.user_id;

-- ������� ���������� ������ � ������������ �� ����
select(((select sum(count_likes)
from medias
where owner_id = 4105537)
+
(select sum(count_comments)
from medias
 where owner_id = 4105537))
 /(select count(*)
 from medias
 where owner_id = 4105537)) as comm_likes;
 
