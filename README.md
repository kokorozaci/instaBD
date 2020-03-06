База данных для сервиса по анализу данных из instagram
=====================
Общее писание проекта
-----------------------------------
База данных представляет собой проекцию бвзы данных instagram с учётом особенностей парсинга и возможных пропусков в данных. В частности, пришлось отказаться значения ` NOT NULL ` для поля `name` в таблице `users` и добавить столбец с оригинальными индексами инстаграма в таблицу `hashtags`.
***
В проекте реализована вставка данных из JSON файлов при помощи библиотеки `pymysql` на Python.
***
В базе данных реализованы процедуры для анализа частоты хештегов, характера комментариев под публикациями пользователей и выборки постов выбранных пользователей.
Так же реализована процедура находящая аккаунты на которые подписаны подписчики исследуемого пользователя. 
***
В базе реализованы фукции для посчёта коэффециентов, характерезующих активность аккаунта, частота проведения конкурсов, индекса вовлечённости подписчиков (ER)
***
Создание структуры БД
---
`craete db.sql`   

Процедуры
---
Для вставки информации из фалов типа: `acc_info.json` :

`bp_fill_accounts.sql`

`bp_fill_comment.sql`

`bp_fill_follows.sql `

`bp_fill_medias.sql`

`bp_insert_ht.sql`

`bp_insert_ht_comments.sql`

с помощью кода Python:
```python
import pymysql

con = pymysql.connect('localhost', 'root', 'password', 'instabd')
with con:
    cur = con.cursor(pymysql.cursors.DictCursor)
    for comment in comments:
        text = quote(comment['text'])
        hashtags = extract.hashtags(text)
        cur.execute(f"call bp_fill_comment('{shortcode}', {comment['id']}, {quote(comment['text'])}, {comment['created_at']}, {comment['owner']['id']}, '{comment['owner']['profile_pic_url']}', '{quote(comment['owner']['username'])}', @tran_result);")
```

Группы на которые подписаны подписчики:

`bp_follows_follows.sql`

Лента новостей по хештегу

`bp_view_media.sql`

Триггеры
---
Проверка на подписку самого на себя. Если значения в полях follower и follows совпадают, позвращается ошибка:
`check_one_value trigger.sql`

Заменяет пустые значения в полях с `None` на `NULL` при заполнении таблиц:

`none_to_null_before_insert trigger.sql`

Функции
---
Коэффециент покупательской активности на основании текста комментариев под публикациями пользователя:
`f_buying_activity.sql` /
`f_buying_activity_n.sql `

Коэффециент вовлечённости: 

`f_engagement_rate.sql `

Количество конкурсов в месяц и количество обычных постов одтонсительно конкурсных:

`f_giveaway_frequency_n.sql ` /
 `f_giveaway_frequency_per_month.sql `

Частота публикаций пользователя (в неделю):

`f_media_frequency.sql `

Представления
---
Объединение бизнес-категории авторов постов и информации о постах:

`v_busness_category_media.sql ` 

Объединение постов и комментариев к ним:

`v_media_comments.sql ` 

Информация о пользователях и вычисляемый столбец с коэффециентом вовлечённости:

`v_users_er.sql`

Пользователи и их публикации:

`v_users_er.sql`

Дополнения
---
`count_media_to_name_ht.sql `

SELECT запросы на разные темы, например какие хештеги чаще встречаются вместе с исследуемым хештегом.
***
ERDiagram для БД
---
![ERDiagram для БД](https://github.com/kokorozaci/instaBD/blob/master/ERDiagram_instaBD.png)

