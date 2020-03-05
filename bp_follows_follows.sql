CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_follows_follows`(in for_user_name VARCHAR(50))
begin
	declare for_user_id BIGINT;
	set for_user_id := (select id from users where name = for_user_name);

	select u.id, u.name , count(*) count_follows  -- сообщества на которые подписаны подписчики группы
	from follows f1
	join follows f2 
		    on f1.follower_id = f2.follower_id and f2.follower_id in (select f3.follower_id from follows f3 group by f3.follows_id having count(f3.follows_id)>0)
	join users u 
			on f2.follows_id = u.id
	where f1.follows_id = for_user_id
	group by f2.follows_id 
	order by count_follows desc;
  END