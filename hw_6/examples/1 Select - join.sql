-- Создание таблицы дней июня 2020
SELECT * into days
FROM generate_series(
  '2020-06-01'::TIMESTAMP,
  '2020-06-01'::TIMESTAMP + INTERVAL '1 month -1 day',
  INTERVAL '1 day'
) AS days(day);
-----
create table departments(id_d serial primary key,
						name_d varchar(50),
						date_create date);
----
insert into departments(name_d, date_create)
values ('юридический','06/20/2020'),
		('бухгалтерия','06/05/2020'),
		('продажи','06/10/2020');
---
create table workers(id_w serial primary key,
		fio varchar(100),
		date_create date,
		id_d integer,
		CONSTRAINT fk_dep_id FOREIGN KEY (id_d)
        REFERENCES public.departments (id_d));

insert into workers(fio, date_create, id_d)
values ('Иванов', '06/05/2020', 1),
		('Савин', '06/10/2020', 2),
		('Клюев', '06/11/2020', 2),
		('Павлов', '06/15/2020', NULL);

--------CROSS JOIN
select * from days cross join departments;

select * from days, departments;

select * from days inner join departments on 1 = 1;
---- 

select * from days inner join departments 
						on day >= date_create;

select * from days inner join departments on 1 = 1
	where day >= date_create;

select * from days inner join departments on true
	where day >= date_create;
	
select * from days cross join departments
	where day >= date_create;	

--- INNER JOIN

select * from departments inner join workers 
		on departments.id_d <> workers.id_d;
		
select * from departments, workers 
	where departments.id_d = workers.id_d;

select * from departments, workers 
		where departments.id_d = workers.id_d;
		
		
select * from days, departments inner join workers 
		on departments.id_d = workers.id_d;

select * from days as dys, departments as dpt inner join workers as wrr 
		on dpt.id_d = wrr.id_d;

select * from days as dys, departments as dpt inner join workers as wrr 
		on dys.day >= wrr.date_create;

select * from days as dys cross join departments as dpt inner join workers as wrr 
		on dys.day >= wrr.date_create;

----	using	
select * from departments join workers 
		using(id_d);

----- NATURAL
select * from departments natural join workers; 

select * from departments join workers 
		using(id_d, date_create);
		
------- Left, Rigth, Full
select * from departments left join workers 
		using(id_d);

select * from departments right join workers 
		using(id_d);

select * from departments full join workers 
		using(id_d);

----отделы с количеством человек в них
select name_d, count(workers.id_d) from departments join workers 
	on departments.id_d = workers.id_d
	group by departments.name_d;

---- union
create table clients(id_c serial primary key,
					fio varchar(100),
					credit integer default(0));

insert into clients(fio, credit)
 values ('Сергеева', 500),
 		('Иванов', 400),
		('Клюев', 550),
		('Потапова', 0),
		('Николаев', 1000);

select fio from workers
 union ALL
  select fio  from clients
order by fio;


-- error
select fio, date_create from workers
 union 
  select fio from clients;

select fio, credit + 100 as credit
 from clients where credit < 500
 union 
  select fio, credit + 200 as credit
   from clients where credit >= 500
    order by credit;
	
---except
select fio from workers
 except 
  select fio from clients;
  
---intersect
select fio from clients
 intersect 
  select fio from workers;


--- Вопрос: вывести все неповторяющиеся ФИО из таблиц ???