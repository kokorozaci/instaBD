create or replace
algorithm = UNDEFINED view `instabd`.`v_media_comments` as
select
    date_format(from_unixtime(`m`.`created_at_timestamp`), '%Y-%m-%d %H:%i:%s') as `media_time`,
    `m`.`shortcode` as `shortcode`,
    `m`.`body` as `media_text`,
    `m`.`owner_id` as `media_owner`,
    date_format(from_unixtime(`c`.`created_at`), '%Y-%m-%d %H:%i:%s') as `comment_time`,
    `c`.`body` as `comment_text`,
    `c`.`owner_id` as `comment_owner`
from
    (`instabd`.`medias` `m`
join `instabd`.`comments` `c` on
    ((`m`.`id` = `c`.`media_id`)))