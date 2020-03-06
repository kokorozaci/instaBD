-- представление, выбирающее посты пользователей, для того чтобы время было в нужном формате + есть имя автора поста

CREATE or replace VIEW v_view_media
AS 
  select DATE_FORMAT(FROM_UNIXTIME(m.created_at_timestamp), '%Y-%m-%d %H:%i:%s') as create_at, m.shortcode, m.body, m.count_comments comments, u.name owner_name, u.id owner_id
  FROM users u
    JOIN medias m ON u.id = m.owner_id
   order by  comments desc;
  
  

explain select shortcode, count_comments
from medias
where count_comments > 2 and body not rlike 'розыгрыш|конкурс|победитель|помогите|разыгрываем|подпишитесь|дарим' 
order by created_at_timestamp desc
limit 10;

select *
from v_view_media
where comments > 1 and body not rlike 'розыгрыш|конкурс|победитель|помогите|разыгрываем|подпишитесь|дарим'
limit 5;

select *
from medias md
join comments cmm
on md.id = cmm.media_id
where cmm.body like '%куп%'
order by md.id ;

select count(*)
from comments;
