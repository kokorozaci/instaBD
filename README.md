База данных для сервиса по анализу данных из instagram
=====================
Общее писание проекта
-----------------------------------
База данных представляет собой проекцию базы данных instagram с учётом особенностей парсинга и возможных пропусков в данных. В частности, пришлось отказаться значения ` NOT NULL ` для поля `name` в таблице `users`, и добавить столбец с оригинальными индексами инстаграм в таблицу `hashtags`.

В проекте реализована вставка данных из JSON файлов при помощи библиотеки `pymysql` на Python.

Созданы процедуры для анализа частоты хештегов, характера комментариев под публикациями пользователей и выборки постов выбранных пользователей, а также процедура находящая аккаунты на которые подписаны подписчики исследуемого пользователя. Написаны функции для подсчёта коэффициентов, характеризующих активность аккаунта, частота проведения конкурсов, индекса вовлеченности подписчиков (ER Engagement rate)
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
from shlex import quote  # библиотека для экранирования спецсимволов

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
Проверка на подписку самого на себя. Если значения в полях follower и follows совпадают, возвращается ошибка:
`check_one_value trigger.sql`

Заменяет пустые значения в полях с `None` на `NULL` при заполнении таблиц:

`none_to_null_before_insert trigger.sql`

Функции
---
Коэффициент покупательской активности на основании текста комментариев под публикациями пользователя:
`f_buying_activity.sql` /
`f_buying_activity_n.sql `

Коэффициент вовлеченности:

`f_engagement_rate.sql `

Количество конкурсов в месяц и количество обычных постов относительно конкурсных:

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

Информация о пользователях и вычисляемый столбец с коэффициентом вовлеченности:

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