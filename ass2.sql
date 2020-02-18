-- COMP3311 19T3 Assignment 2
-- Written by Kirsten Tai

-- Q1 Which movies are more than 6 hours long?

create or replace view Q1(title)
as
	select main_title from Titles
	where format = 'movie' AND runtime > 360
;


-- Q2 What different formats are there in Titles, and how many of each?

create or replace view Q2(format, ntitles)
as
	select distinct format, count (*) from Titles
	group by format
;


-- Q3 What are the top 10 movies that received more than 1000 votes?

create or replace view Q3(title, rating, nvotes)
as
	select main_title, rating from Titles
	where format = 'movie' AND nvotes > 1000
	order by rating desc limit 10
;


-- Q4 What are the top-rating TV series and how many episodes did each have?

create or replace view Q4(title, nepisodes)
as

	select main_title, count (main_title)
	from (select * from Titles where
			(select max(rating) from titles where format LIKE 'tv' || '%'|| 'Series')
		= rating and format LIKE 'tv'||'%'||'Series') as y
		join Episodes e on (y.id = e.parent_id)

	group by main_title
;


-- Q5 Which movie was released in the most languages?
create or replace view movieList(title, qty) as
select t.main_title, count(distinct a.language) from Aliases a, Titles t
where t.format = 'movie' and a.title_id = t.id
group by t.main_title
;

create or replace view Q5(title, nlanguages)
as
	select distinct title, qty
	from movieList
	order by qty desc limit 1
;

-- Q6 Which actor has the highest average rating in movies that they're known for?

create or replace view actList
	as
	select n.name, avg(t.rating)
	from Names n, Worked_as w, Known_for k, Titles t
	where w.name_id = n.id
	and k.name_id = n.id
	and t.id = k.title_id
	and w.work_role = 'actor'
	and t.format = 'movie'
	and t.rating is not null
	group by n.name
	having count(k) >= 2;


create or replace view Q6(name)
as select name from actList
	where avg = (
	select max (actList.avg)
	from actList
);


-- Q7 For each movie with more than 3 genres, show the movie title and a comma-separated list of the genres

create or replace view movieIDList(movie_id, qtyGenres)
as
	select distinct g.title_id, count(distinct g.genre) --STRING_AGG (distinct g.genre, ',')
	from Title_genres g, Titles t
	where g.title_id = t.id
	and t.format = 'movie'
	group by g.title_id
	having count(distinct g.genre) > 3
;

create or replace view Q7(title, genres)
as
	select t.main_title, STRING_AGG (distinct g.genre, ',')
	from movieIDList m, Titles t, Title_genres g
	where t.id = m.movie_id and t.format = 'movie'
	and g.title_id = t.id
	group by t.main_title
;
-- Q8 Get the names of all people who had both actor and crew roles on the same movie

create or replace view actorsMovies(actor, movie)
as

	select n.name, t.main_title, w.work_role
	from Worked_as w, Names n, Actor_roles a, Titles t
	where t.format = 'movie'
	and w.name_id = n.id
	and n.id = a.name_id
	and a.title_id = t.id
;

create or replace view crewsMovies(crew, movie)
as
	select n.name, t.main_title
	from Crew_roles c, Names n, Titles t
	where c.name_id = n.id
	and c.title_id = t.id
;

create or replace view actorCrew(name, movie)
as
	(select actor, movie from actorsMovies) intersect (select crew, movie from crewsMovies)
;

create or replace view Q8(name)
as

	select distinct name
	from actorCrew
;
-- Q9 Who was the youngest person to have an acting role in a movie,
-- and how old were they when the movie started?

create or replace view actorAge(name, birth_year, movie, start_year, age)
as
	select n.name, n.birth_year, t.main_title, t.start_year, t.start_year-n.birth_year
	from Titles t, Actor_roles a, Names n
	where t.id = a.title_id
	and a.name_id = n.id
	and t.format = 'movie'
;

create or replace view Q9(name, age)
as

	select distinct name, age
	from actorAge
	where age = (select min(age) from actorAge)
;

-- Q10 Write a PLpgSQL function that, given part of a title,
-- shows the full title and the total size of the cast and crew

create or replace view castCrews
as

	select p.title_id, p.name_id, p.job_cat from Principals p
	UNION
	select a.title_id, a.name_id, a.played from Actor_roles a
	UNION
	select c.title_id, c.name_id, c.role from Crew_roles c
;

create or replace view countCast
as
	select title_id, count(name_id) as count
	from castCrews
	group by title_id
;

create or replace view showCast(title, headCount)
as
	select main_title, count
	from castCrews cc, Titles t
	where cc.title_id = t.id
	group by main_title, count
;

create or replace function
Q10(partial_title text) returns setof text
as $$
declare
	match integer := 0;
	results record;
	output text;

begin
select count(*) into match from showCast
	where showCast.main_title ilike '%'|| partial_title || '%';
if (match = 0)
then
	return next 'No matching titles';
else
	for results in
		select * from showCast
		where main_title ilike '%' || partial_title || '%'
	loop
		output := results.main_title || ' has '|| results.count || ' cast and crew';
	return next output;
	end loop;
end if;
return;
end;
$$ language plpgsql;
