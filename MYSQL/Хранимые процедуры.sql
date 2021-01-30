
 -- Представление определяющее любимый жанр пользователя по количеству просмотров фильмов с этим жанром --------------------------------------------------
 
create or replace view like_genre as
select 
	u.id as 'user_id',
	u.nickname as 'nickname',
	count(gl.id) as 'number views genre',
	gl.id as 'id',
	gl.name as 'genre'
from browsing_history bh 
join content c on bh.content_id = c.id
join genre_content gc on c.id = gc.content_id 
join genre_list gl on gc.genre_id = gl.id 
left join users u on u.id = bh.user_id 
group by gl.id, u.id
order by 'number views genre' desc;

select * from like_genre where user_id = 1

-- Представление выводящее рейтинг фильмов на сайте основанный на оценках пользователей -------------------------------------------------------------------

create or replace view rating as 
select 
	avg(a.appraisals) as users_appraisals, 
	a.content_id as content_id,  
	c.name as name_film,
	gl.name as genre
from appraisals a
join content c on a.content_id = c.id
join genre_content gc on c.id = gc.content_id 
join genre_list gl on gc.genre_id = gl.id 
group by a.content_id 
order by users_appraisals desc;

select * from rating limit 10

select * from rating where users_appraisals > 6 limit 10

select * from rating where genre = 'Ужасы' and users_appraisals > 5 limit 10

-- Представление выводящее количество просмотров фильмов на сайте от большего к меньшему -------------------------------------------------------------------

create or replace view views as 
select 
	count(bh.content_id) as number_watch, 
	bh.content_id, 
	c.name as name_films,
	gl.name as 'genre'
from browsing_history bh
join content c on content_id = id
join genre_content gc on c.id = gc.content_id 
join genre_list gl on gc.genre_id = gl.id 
group by bh.content_id, gl.name
order by number_watch 
desc; 

select * from views limit 10

select * from views where genre = 'Боевик' limit 10

-- Представление для показа пользователю подборку фильмов на основе его предпочтений и рейтинга


create or replace view offers as 
select 
	lg.user_id as 'user_id',
	c.name as 'movie title',
	c.description as 'description',
	p.picture as 'preview',
	c.number_of_episodes as 'number of episodes',
	c.age_rating as 'age rating',
	v.number_watch as 'views',
	v.genre as 'genre',
	r.users_appraisals as 'rating'
from like_genre lg
join genre_content gc on gc.genre_id = lg.id
join content c on c.id = gc.content_id
join posters p on c.poster_id = p.id 
join views v on v.content_id = c.id 
join rating r on r.content_id = c.id
group by c.id, lg.user_id
order by c.age_rating;

-- Я пытался ещё вкрутить сюда условие что бы несовершеннолетним пользвоателям не показывались фильмы для взрослых но чет не получилось 
-- join profiles p2 on p2.id = lg.user_id
-- where if(p2.majority = false, (c.age_rating = 'G' or 'PG' or 'PG-13'), (c.age_rating = 'G' or 'PG' or 'PG-13'or 'R' or 'NC-17'))

select * from offers where user_id = 1 limit 10

