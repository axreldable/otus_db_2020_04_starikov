drop table if exists hw_1;
drop table if exists titles;
drop table if exists titles_tmp;
drop table if exists languages;
drop table if exists languages_tmp;

create temp table if not exists titles_tmp
(
    id    serial primary key not null,
    title varchar(30)        not null
);

create table if not exists titles
(
    id    serial primary key not null,
    title varchar(30)        not null
);

COPY titles_tmp (title)
    FROM PROGRAM 'cut -d "," -f 1 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

insert into titles
select distinct on (title) *
from titles_tmp;

create temp table if not exists languages_tmp
(
    id       serial primary key not null,
    language varchar(30)
);

create table if not exists languages
(
    id       serial primary key not null,
    language varchar(30)
);

COPY languages_tmp (language)
    FROM PROGRAM 'cut -d "," -f 4 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete from languages_tmp
where language is null;

insert into languages
select distinct on (language) *
from languages_tmp;

create table if not exists hw_1
(
    id                      serial primary key not null,
    title                   varchar(30)        not null,
    title_id                integer,
    language_id             integer,
    first_name              varchar(50)        not null,
    last_name               varchar(50)        not null,
    correspondence_language varchar(50),
    birth_date              varchar(50),
    gender                  varchar(50)        not null,
    marital_status          varchar(50)        not null,
    country                 varchar(50)        not null,
    postal_code             varchar(50)        not null,
    region                  varchar(50)        not null,
    city                    varchar(50)        not null,
    street                  varchar(100)       not null,
    building_number         varchar(50)        not null,
    FOREIGN KEY (title_id) REFERENCES titles (id),
    FOREIGN KEY (language_id) REFERENCES languages (id)
);

COPY hw_1 (title, first_name, last_name, correspondence_language, birth_date, gender, marital_status, country,
           postal_code, region, city, street, building_number)
    FROM '/tmp/input_data/some_customers.csv' DELIMITER ',' CSV HEADER;

update hw_1
set title_id = titles.id
from titles
where hw_1.title = titles.title;

update hw_1
set language_id = languages.id
from languages
where hw_1.correspondence_language = languages.language;

alter table hw_1
    drop column title,
    drop column correspondence_language;
