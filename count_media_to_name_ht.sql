select name, count_media from hashtags where id = 144;

select count(*)  'кол-во постов в базе'   -- количество постов в базе по хештегу
from (select mh.media_id 
from hashtags h 
join medias_hashtags mh 
	on h.id = mh.hashtag_id 
where h.name like 'dress'
union
select  c.id 
from comments_hashtags ch
join comments c on ch.comment_id = c.id 
join medias m on c.media_id = m.id 
join hashtags h2 on h2.id = ch.hashtag_id 
where h2.name like 'dress') all_med;

EXPLAIN select count(*) from medias_hashtags; -- количество ссылок на посты по хештегам 5 385 101 записей

explain select * from medias m join users u on m.owner_id = u.id where u.name = 'vaganni_77' order by m.count_comments desc; -- посты пользователя

select  h.name, count(h.name) count_hashtag
from medias_hashtags mh 
join medias m on mh.media_id = m.id 
join users u on m.owner_id = u.id 
join hashtags h on mh.hashtag_id = h.id 
where u.name = 'vaganni_77'
group by h.name
order by count_hashtag desc;  -- хештеги которые использовал пользователь в своих постах сортированные по частоте

set @u_id = (select id from users where name = 'vaganni_77');  
select f_media_frequency(@u_id);  -- частота публикаций в неделю


select * from users_profiles up where user_id = (select id from users where name = 'zveroshmotka')

select count(*)
from follows f1
where f1.follows_id = (select id from users where name = 'zveroshmotka');

select u.name , count(*) c  -- сообщества на которые подписаны подписчики группы
	from follows f1
		join follows f2 
		    on f1.follower_id = f2.follower_id and f2.follower_id in (select f3.follower_id from follows f3 group by f3.follows_id having count(f3.follows_id)>0)
		join users u 
			on f2.follows_id = u.id
		  where f1.follows_id = (select id from users where name = 'zveroshmotka')
		 group by f2.follows_id 
	     order by c desc
		limit 50;

CALL bp_follows_follows ('zveroshmotka'); -- сообщества на которые подписаны подписчики группы


-- выборка бизнес аккаунтов с минимумом подписок и максимумом подписчиков
select bc.name busness_category, up.counts_followed_by/up.counts_follows CP, round((f_engagement_rate(up.user_id)), 2) ER, u.name, up.counts_followed_by , up.counts_follows, up.counts_media 
from users_profiles up 
join busness_category bc 
	on up.busness_category_id = bc.id 
join users u 
	on u.id = up.user_id 
where up.busness_category_id = 1 and (f_engagement_rate(up.user_id)) > 10 and up.counts_followed_by > 1000
order by ER desc
limit 20;

-- хештеги которые встречаются с другими хт
select ht.name, count(*) c
from medias_hashtags mh1
join medias_hashtags mh2 on mh1.media_id = mh2.media_id
join hashtags ht on ht.id = mh2.hashtag_id
where mh1.hashtag_id = (select id from hashtags where name = 'linendress')
group by mh2.hashtag_id
order by c desc
limit 20;













