drop table if exists users;
drop table if exists titles;
drop table if exists titles_tmp;
drop table if exists languages;
drop table if exists languages_tmp;
drop table if exists genders;
drop table if exists genders_tmp;
drop table if exists marital_statuses;
drop table if exists marital_statuses_tmp;
drop table if exists addresses;
drop table if exists countries;
drop table if exists countries_tmp;
drop table if exists regions;
drop table if exists regions_tmp;

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

delete
from titles_tmp
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
    language varchar(30)        not null
);

COPY languages_tmp (language)
    FROM PROGRAM 'cut -d "," -f 4 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from languages_tmp
where language is null;

insert into languages
select distinct on (language) *
from languages_tmp;

create temp table if not exists genders_tmp
(
    id     serial primary key not null,
    gender varchar(30)        not null
);

create table if not exists genders
(
    id     serial primary key not null,
    gender varchar(30)        not null
);

COPY genders_tmp (gender)
    FROM PROGRAM 'cut -d "," -f 6 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from genders_tmp
where gender = '';

insert into genders
select distinct on (gender) *
from genders_tmp;

create temp table if not exists marital_statuses_tmp
(
    id             serial primary key not null,
    marital_status varchar(30)
);

create table if not exists marital_statuses
(
    id             serial primary key not null,
    marital_status varchar(30)        not null
);

COPY marital_statuses_tmp (marital_status)
    FROM PROGRAM 'cut -d "," -f 7 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from marital_statuses_tmp
where marital_status is null
   or marital_status = '';

insert into marital_statuses
select distinct on (marital_status) *
from marital_statuses_tmp;

create temp table if not exists countries_tmp
(
    id      serial primary key not null,
    country varchar(30)        not null
);

create table if not exists countries
(
    id      serial primary key not null,
    country varchar(30)        not null
);

COPY countries_tmp (country)
    FROM PROGRAM 'cut -d "," -f 8 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from countries_tmp
where country = '';

insert into countries
select distinct on (country) *
from countries_tmp;

create temp table if not exists regions_tmp
(
    id     serial primary key not null,
    region varchar(30)        not null
);

create table if not exists regions
(
    id     serial primary key not null,
    region varchar(30)        not null
);

COPY regions_tmp (region)
    FROM PROGRAM 'cut -d "," -f 10 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from regions_tmp
where region = '';

insert into regions
select distinct on (region) *
from regions_tmp;

create table if not exists addresses
(
    id              serial primary key not null,
    country_id      integer,
    region_id       integer,
    country         varchar(50)        not null,
    postal_code     varchar(50)        not null,
    region          varchar(50)        not null,
    city            varchar(50)        not null,
    street          varchar(100)       not null,
    building_number varchar(50)        not null,
    FOREIGN KEY (country_id) REFERENCES countries (id),
    FOREIGN KEY (region_id) REFERENCES regions (id)
);

COPY addresses (country, postal_code, region, city, street, building_number)
    FROM PROGRAM 'cut -d "," -f 8,9,10,11,12,13 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

update addresses
set country_id = countries.id
from countries
where addresses.country = countries.country;

update addresses
set region_id = regions.id
from regions
where addresses.region = regions.region;

alter table addresses
    drop column country,
    drop column region;

create table if not exists users
(
    id                      serial primary key not null,
    title_id                integer,
    language_id             integer,
    gender_id               integer,
    marital_status_id       integer,
    address_id              integer,
    title                   varchar(30)        not null,
    first_name              varchar(50)        not null,
    last_name               varchar(50)        not null,
    correspondence_language varchar(50),
    birth_date              date,
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
    FOREIGN KEY (marital_status_id) REFERENCES marital_statuses (id),
    FOREIGN KEY (address_id) REFERENCES ADDRESSES (id)
);

COPY users (title, first_name, last_name, correspondence_language, birth_date, gender, marital_status, country,
            postal_code, region, city, street, building_number)
    FROM '/tmp/input_data/some_customers.csv' DELIMITER ',' CSV HEADER;

update users
set title_id = titles.id
from titles
where users.title = titles.title;

update users
set language_id = languages.id
from languages
where users.correspondence_language = languages.language;

update users
set gender_id = genders.id
from genders
where users.gender = genders.gender;

update users
set gender_id = marital_statuses.id
from marital_statuses
where users.marital_status = marital_statuses.marital_status;

update users
set address_id = addresses.id
from addresses
where users.postal_code = addresses.postal_code
  and users.city = addresses.city
  and users.street = addresses.street
  and users.building_number = addresses.building_number;

alter table users
    drop column title,
    drop column correspondence_language,
    drop column gender,
    drop column marital_status,
    drop column country,
    drop column postal_code,
    drop column region,
    drop column city,
    drop column street,
    drop column building_number;
