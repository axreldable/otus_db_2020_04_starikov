drop table if exists film_and_actors_stat;

create table film_and_actors_stat
as 
select actor_id, count(*) as film_count, MIN(film_id) as first_film_id, MAX(film_id) as last_film_id
from film_actor 
group by actor_id;


select * from film_and_actors_stat
where film_count < 15;

delete from film_and_actors_stat
where film_count < 15;

select * from film_and_actors_stat
where exists 
	(select *
	from actor
	where first_name like 'JO%'
		and actor.actor_id = film_and_actors_stat.actor_id);

delete from film_and_actors_stat
where exists 
	(select *
	from actor
	where first_name like 'JO%'
		and actor.actor_id = film_and_actors_stat.actor_id)
returning actor_id;

--error: all rows deleted
select * from film_and_actors_stat
where exists 
	(select *
	from actor
		join film_and_actors_stat as fas
			on fas.actor_id = actor.actor_id
	where first_name like 'JO%');

delete from film_and_actors_stat
where exists 
	(select *
	from actor
		join film_and_actors_stat as fas
			on fas.actor_id = actor.actor_id
	where first_name like 'JO%');
--------

select * from film_and_actors_stat, actor
where actor.actor_id = film_and_actors_stat.actor_id
	and actor.first_name like 'JE%';

delete from film_and_actors_stat	
	using actor
where actor.actor_id = film_and_actors_stat.actor_id
	and actor.first_name like 'JE%';
	
--returning film_and_actors_stat.*, actor.*;