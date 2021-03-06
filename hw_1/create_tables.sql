drop table if exists customers;
drop table if exists titles;
drop table if exists titles_tmp;
drop table if exists languages;
drop table if exists languages_tmp;
drop table if exists genders;
drop table if exists genders_tmp;
drop table if exists marital_statuses;
drop table if exists marital_statuses_tmp;
drop table if exists addresses;
drop table if exists regions;
drop table if exists regions_tmp;
drop table if exists countries;
drop table if exists countries_tmp;
drop table if exists postal_codes;
drop table if exists postal_codes_tmp;
drop table if exists cities;
drop table if exists cities_tmp;
drop table if exists streets;
drop table if exists streets_tmp;
drop table if exists houses;
drop table if exists houses_tmp;

--------------------------------------------------------
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

--------------------------------------------------------
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

--------------------------------------------------------
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

--------------------------------------------------------
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

--------------------------------------------------------
create table if not exists houses
(
    id              serial primary key not null,
    building_number varchar(50)        not null
);

create table if not exists houses_tmp
(
    id              serial primary key not null,
    building_number varchar(50)        not null
);

COPY houses_tmp (building_number)
    FROM PROGRAM 'cut -d "," -f 13 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from houses_tmp
where building_number is null
   or building_number = '';

insert into houses
select distinct on (building_number) *
from houses_tmp;

drop table houses_tmp;

--------------------------------------------------------
create table if not exists streets
(
    id              serial primary key not null,
    house_id        integer,
    street          varchar(100)       not null,
    building_number varchar(50)        not null,
    FOREIGN KEY (house_id) REFERENCES houses (id)
);

create table if not exists streets_tmp
(
    id              serial primary key not null,
    house_id        integer,
    street          varchar(100)       not null,
    building_number varchar(50)        not null,
    FOREIGN KEY (house_id) REFERENCES houses (id)
);

COPY streets_tmp (street, building_number)
    FROM PROGRAM 'cut -d "," -f 12,13 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from streets_tmp
where street is null
   or street = '';

insert into streets (street, building_number)
select distinct street, building_number
from streets_tmp;

update streets
set house_id = houses.id
from houses
where streets.building_number = houses.building_number;

alter table streets
    drop column building_number;

drop table streets_tmp;

--------------------------------------------------------
create table if not exists cities
(
    id        serial primary key not null,
    street_id integer,
    city      varchar(50)        not null,
    street    varchar(100)       not null,
    FOREIGN KEY (street_id) REFERENCES streets (id)
);

create table if not exists cities_tmp
(
    id        serial primary key not null,
    street_id integer,
    city      varchar(50)        not null,
    street    varchar(100)       not null,
    FOREIGN KEY (street_id) REFERENCES streets (id)
);

COPY cities_tmp (city, street)
    FROM PROGRAM 'cut -d "," -f 11,12 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from cities_tmp
where city is null
   or city = '';

insert into cities (city, street)
select distinct city, street
from cities_tmp;

update cities
set street_id = streets.id
from streets
where cities.street = streets.street;

alter table cities
    drop column street;

drop table cities_tmp;

--------------------------------------------------------
create table if not exists postal_codes
(
    id              serial primary key not null,
    house_id        integer,
    street_id       integer,
    city_id         integer,
    building_number varchar(50)        not null,
    street          varchar(100)       not null,
    city            varchar(50)        not null,
    postal_code     varchar(50)        not null,
    FOREIGN KEY (house_id) REFERENCES houses (id),
    FOREIGN KEY (street_id) REFERENCES streets (id),
    FOREIGN KEY (city_id) REFERENCES cities (id)
);

create table if not exists postal_codes_tmp
(
    id              serial primary key not null,
    house_id        integer,
    street_id       integer,
    city_id         integer,
    building_number varchar(50)        not null,
    street          varchar(100)       not null,
    city            varchar(50)        not null,
    postal_code     varchar(50)        not null,
    FOREIGN KEY (house_id) REFERENCES houses (id),
    FOREIGN KEY (street_id) REFERENCES streets (id),
    FOREIGN KEY (city_id) REFERENCES cities (id)
);

COPY postal_codes_tmp (postal_code, city, street, building_number)
    FROM PROGRAM 'cut -d "," -f 9,11,12,13 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from postal_codes_tmp
where postal_code is null
   or postal_code = '';

insert into postal_codes (postal_code, city, street, building_number)
select distinct postal_code, city, street, building_number
from postal_codes_tmp;

update postal_codes
set house_id = houses.id
from houses
where postal_codes.building_number = houses.building_number;

update postal_codes
set street_id = streets.id
from streets
where postal_codes.street = streets.street;

update postal_codes
set city_id = cities.id
from cities
where postal_codes.city = cities.city;

alter table postal_codes
    drop column building_number,
    drop column street,
    drop column city;

drop table postal_codes_tmp;

--------------------------------------------------------
create table if not exists regions
(
    id      serial primary key not null,
    city_id integer,
    region  varchar(30)        not null,
    city    varchar(50)        not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);

create table if not exists regions_tmp
(
    id      serial primary key not null,
    city_id integer,
    region  varchar(30)        not null,
    city    varchar(50)        not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);

COPY regions_tmp (region, city)
    FROM PROGRAM 'cut -d "," -f 10,11 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from regions_tmp
where region is null
   or region = '';

insert into regions (region, city)
select distinct region, city
from regions_tmp;

update regions
set city_id = cities.id
from cities
where regions.city = cities.city;

alter table regions
    drop column city;

drop table regions_tmp;

--------------------------------------------------------
create table if not exists countries
(
    id      serial primary key not null,
    city_id integer,
    country varchar(2)         not null,
    city    varchar(50)        not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);

create table if not exists countries_tmp
(
    id      serial primary key not null,
    city_id integer,
    country varchar(2)         not null,
    city    varchar(50)        not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);

COPY countries_tmp (country, city)
    FROM PROGRAM 'cut -d "," -f 8,11 /tmp/input_data/some_customers.csv' WITH (FORMAT CSV, HEADER);

delete
from countries_tmp
where country is null
   or country = '';

insert into countries (country, city)
select distinct country, city
from countries_tmp;

update countries
set city_id = cities.id
from cities
where countries.city = cities.city;

alter table countries
    drop column city;

drop table countries_tmp;

--------------------------------------------------------
create table if not exists addresses
(
    id              serial primary key not null,
    house_id        integer,
    street_id       integer,
    city_id         integer,
    postal_code_id  integer,
    country_id      integer,
    region_id       integer,
    building_number varchar(50)        not null,
    street          varchar(100)       not null,
    city            varchar(50)        not null,
    country         varchar(2)         not null,
    region          varchar(50)        not null,
    postal_code     varchar(50)        not null,
    FOREIGN KEY (house_id) REFERENCES houses (id),
    FOREIGN KEY (street_id) REFERENCES streets (id),
    FOREIGN KEY (city_id) REFERENCES cities (id),
    FOREIGN KEY (country_id) REFERENCES countries (id),
    FOREIGN KEY (region_id) REFERENCES regions (id),
    FOREIGN KEY (region_id) REFERENCES postal_codes (id)
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

update addresses
set city_id = cities.id
from cities
where addresses.city = cities.city;

update addresses
set street_id = streets.id
from streets
where addresses.street = streets.street;

update addresses
set house_id = houses.id
from houses
where addresses.building_number = houses.building_number;

update addresses
set postal_code_id = postal_codes.id
from postal_codes
where addresses.postal_code = postal_codes.postal_code;

alter table addresses
    drop column country,
    drop column city,
    drop column region,
    drop column street,
    drop column postal_code,
    drop column building_number;

--------------------------------------------------------
create table if not exists customers
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
    country                 varchar(2)         not null,
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

COPY customers (title, first_name, last_name, correspondence_language, birth_date, gender, marital_status, country,
                postal_code, region, city, street, building_number)
    FROM '/tmp/input_data/some_customers.csv' DELIMITER ',' CSV HEADER;

delete
from customers
where (first_name is null or first_name = '') and (last_name is null or last_name = '');

update customers
set title_id = titles.id
from titles
where customers.title = titles.title;

update customers
set language_id = languages.id
from languages
where customers.correspondence_language = languages.language;

update customers
set gender_id = genders.id
from genders
where customers.gender = genders.gender;

update customers
set address_id = ad.ad_id
from (
         select addresses.id as ad_id, *
         from addresses
                  join countries c on addresses.country_id = c.id
                  join regions r on addresses.region_id = r.id
                  join cities c2 on addresses.city_id = c2.id
                  join streets s on addresses.street_id = s.id
                  join houses h on addresses.house_id = h.id
                  join postal_codes pc on addresses.postal_code_id = pc.id
     ) ad
where customers.country = ad.country
  and customers.city = ad.city
  and customers.region = ad.region
  and customers.street = ad.street
  and customers.building_number = ad.building_number
  and customers.postal_code = ad.postal_code;

update customers
set gender_id = marital_statuses.id
from marital_statuses
where customers.marital_status = marital_statuses.marital_status;

alter table customers
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
