/*
 * Выводит сортированные по дате посты, в которых содержится хештег или в комментариях к которым содержится хештег
 * Возврвщвет в переменную значение общего количества постов
 */

CREATE DEFINER=`root`@`localhost` PROCEDURE `instabd`.`bp_view_media`(in hashtag VARCHAR(100), in page INT, out count_media INT)
begin
	declare page_new INT;
	set page_new := 15*page;
	
	select * 
	from (select date_format(from_unixtime(m.created_at_timestamp), '%Y-%m-%d %H:%i:%s') as created_at, m.shortcode, m.body, m.count_comments, ht.name hashtag
	from medias m
	join medias_hashtags mh 
		on m.id = mh.media_id
	join hashtags ht 
		on mh.hashtag_id = ht.id
	where ht.name = hashtag
		
	union 
	
	select date_format(from_unixtime(m.created_at_timestamp), '%Y-%m-%d %H:%i:%s') as created_at, m.shortcode, m.body, m.count_comments, ht.name hashtag
	from medias m
	join comments c 
		on m.id = c.media_id
	join comments_hashtags ch 
		on c.id = ch.comment_id	
	join hashtags ht 
		on ch.hashtag_id = ht.id
	where ht.name = hashtag) mht
	group by shortcode 
	order by created_at desc
	limit 15 OFFSET page_new;

	set count_media := (select count(*)  'кол-во постов в базе'   -- количество постов в базе по хештегу
	from (select mh.media_id 
		 from hashtags h 
		 join medias_hashtags mh 
		  	on h.id = mh.hashtag_id 
		  where h.name like hashtag
		union
		select  c.id 
		from comments_hashtags ch
		join comments c 
			on ch.comment_id = c.id 
		join medias m 
			on c.media_id = m.id 
		join hashtags h2 
			on h2.id = ch.hashtag_id 
		where h2.name like hashtag) all_med);

	
END