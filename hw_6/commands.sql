docker exec -ti postgres_otus_hw_6 bash
su postgres

psql
------------------------------------------------------------------
create_tables.sql
------------------------------------------------------------------
insert into titles(id, title)
values (default, 'Мистер'),
       (default, 'Мисс');
------------------------------------------------------------------
select *
from titles;
------------------------------------------------------------------
-- 3. Напишите запрос на добавление данных с выводом информации о добавленных строках.
insert into customers(id, title_id, first_name, last_name, birth_date)
values (default, 1, 'Иван_1', 'Иванов', '05/13/2020'),
       (default, null, 'Иван_2', 'Иванов', '04/02/2006'),
       (default, null, 'Петр_1', 'Петров', '03/22/2020'),
       (default, 2, 'Петр_2', 'Петров', '12/01/1992')
returning first_name, birth_date;
------------------------------------------------------------------
select *
from customers;
------------------------------------------------------------------
-- 1. Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.
--    Найти всех customers, first_name которых начинается с Иван_ (регистр важен) и заканчивается любыми символами (осутствие символов подходит)
select *
from customers
where first_name like 'Иван_%';
------------------------------------------------------------------
-- 2. Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?
-- Выводятся все записи таблицы customers, если title отсутствует, то на его месте null.
select t.id, c.id, first_name, last_name, title
from customers c
         left join titles t
                   on c.title_id = t.id;

-- Выводятся все записи таблицы title, так как title-ов меньше, видим только customer-ов, у которых есть title.
select t.id, c.id, first_name, last_name, title
from titles t
         left join customers c
                   on c.title_id = t.id;

-- Выводятся только customer-ы, у которых есть title, не зависимо от порядка
select t.id, c.id, first_name, last_name, title
from customers c
         inner join titles t
                    on c.title_id = t.id;

select t.id, c.id, first_name, last_name, title
from titles t
         inner join customers c
                    on c.title_id = t.id;
------------------------------------------------------------------
-- 4. Напишите запрос с обновлением данные используя UPDATE FROM.
-- Меняет titles всех Иванов на Mr.
UPDATE titles AS t
SET title = 'Mr.'
FROM customers AS c
WHERE t.id = c.title_id
  and first_name like 'Иван_%';
------------------------------------------------------------------
-- 5. Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.
-- Сначал переименовывваем имя столбца, чтобы имена совпадали
ALTER TABLE titles
    RENAME COLUMN id TO title_id;
-- Затем используем using
select title_id, first_name, last_name, title
from customers c
         inner join titles t
                    using (title_id);
-- Сам  delete - удалить всех customers, у которых есть title
delete
from customers
where title_id in (
    select t.title_id
    from customers c
             inner join titles t
                        using (title_id)
);

------------------------------------------------------------------
-- 6. Приведите пример использования утилиты COPY
COPY titles (title)
    FROM PROGRAM 'cut -d "," -f 1 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);
------------------------------------------------------------------