drop table if exists hw_1;
drop table if exists titles;
drop table if exists titles_tmp;
drop table if exists languages;
drop table if exists languages_tmp;
drop table if exists genders;
drop table if exists genders_tmp;
drop table if exists marital_statuses;
drop table if exists marital_statuses_tmp;

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

delete from titles_tmp
where title = '';

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
    language varchar(30) not null
);

COPY languages_tmp (language)
    FROM PROGRAM 'cut -d "," -f 4 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete from languages_tmp
where language is null;

insert into languages
select distinct on (language) *
from languages_tmp;

create temp table if not exists genders_tmp
(
    id    serial primary key not null,
    gender varchar(30)        not null
);

create table if not exists genders
(
    id    serial primary key not null,
    gender varchar(30)        not null
);

COPY genders_tmp (gender)
    FROM PROGRAM 'cut -d "," -f 6 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete from genders_tmp
where gender is null or gender = '';

insert into genders
select distinct on (gender) *
from genders_tmp;

create temp table if not exists marital_statuses_tmp
(
    id    serial primary key not null,
    marital_status varchar(30)
);

create table if not exists marital_statuses
(
    id    serial primary key not null,
    marital_status varchar(30)        not null
);

COPY marital_statuses_tmp (marital_status)
    FROM PROGRAM 'cut -d "," -f 7 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete from marital_statuses_tmp
where marital_status is null or marital_status = '';

insert into marital_statuses
select distinct on (marital_status) *
from marital_statuses_tmp;

create table if not exists hw_1
(
    id                      serial primary key not null,
    title                   varchar(30)        not null,
    title_id                integer,
    language_id             integer,
    gender_id             integer,
    marital_status_id             integer,
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
    FOREIGN KEY (language_id) REFERENCES languages (id),
    FOREIGN KEY (gender_id) REFERENCES genders (id),
    FOREIGN KEY (marital_status_id) REFERENCES marital_statuses (id)
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

update hw_1
set gender_id = genders.id
from genders
where hw_1.gender = genders.gender;

update hw_1
set gender_id = marital_statuses.id
from marital_statuses
where hw_1.marital_status = marital_statuses.marital_status;

alter table hw_1
    drop column title,
    drop column correspondence_language,
    drop column gender,
    drop column marital_status;
