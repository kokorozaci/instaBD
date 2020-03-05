/*
 * создание представления с комментариями к постам
 */
CREATE or replace VIEW v_media_comments
AS
select 
date_format(from_unixtime(m.created_at_timestamp), '%Y-%m-%d %H:%i:%s') as media_time, 
m.shortcode, 
m.body media_text, 
m.owner_id media_owner,
date_format(from_unixtime(c.created_at), '%Y-%m-%d %H:%i:%s') as comment_time , 
c.body comment_text
c.owner_id comment_owner
from medias m 
join comments c 
	on m.id = c.media_id;

-- ----------------------------

select shortcode , media_text,  count(*) count_comm -- подсчёт комментариев к посту, считаются только комментарии с ключевым словом 
from v_media_comments
where (comment_text like '%куп%' or comment_text like '%цен%') and comment_owner <> media_owner 
group by shortcode
having count_comm > 5
order by count_comm desc
limit 20;


-- выбор постов по хештегу который есть или в тексте сообщения или в тексте комментария
call bp_view_media('dress', 0, @media_count);
select @media_count;

-- выбираем все комментарии к посту не от автора поста
select comment_time, comment_text --  media_time, count(*) c, shortcode
from v_media_comments
where shortcode = 'B2mbgbiBzdU' and media_owner <> comment_owner -- and comment_time > date('2019-09-20')-- group by shortcode
order by comment_time desc;