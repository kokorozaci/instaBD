
-- активность в аккаунтах

CREATE or replace VIEW v_users_ER
AS
select 
u.name user_name,
(select(round(f_engagement_rate(up.user_id), 2))) ER,
bc.name 'busness category',
up.counts_media n_media,
up.counts_followed_by followers,
up.counts_follows follows
from users u 
right join users_profiles up 
	on up.user_id = u.id
join busness_category bc 
	on up.busness_category_id = bc.id
order by ER desc;

-- -----

select *
from v_users_ER
where followers > 10000
limit 20;