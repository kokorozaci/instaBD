/*
 * создание представления постов с информацией об авторах (бизнес категория и т.д.)
 */
CREATE or replace VIEW v_busness_category_media
AS
select 
date_format(from_unixtime(m.created_at_timestamp), '%Y-%m-%d %H:%i:%s') as media_time, 
m.shortcode, 
u.name user_name,
-- (select(round(f_engagement_rate(up.user_id), 2))) ER,
up.counts_followed_by,
up.counts_media,
bc.name 'busness category'
from users_profiles up
join medias m 
	on m.owner_id = up.user_id and not up.busness_category_id is null
join busness_category bc 
	on up.busness_category_id = bc.id
join users u 
	on m.owner_id = u.id
order by media_time
LIMIT 20;

-- ----------------------------

select *
from v_busness_category_media 
where `busness category` = 1
order by media_time desc 
limit 10;

