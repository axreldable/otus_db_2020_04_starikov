drop table if exists order_statues;
drop table if exists orders;
drop table if exists order_logs;
drop table if exists customers_to_addresses;
drop table if exists customers;
drop table if exists titles;
drop table if exists languages;
drop table if exists genders;
drop table if exists marital_statuses;
drop table if exists addresses;
drop table if exists regions;
drop table if exists countries;
drop table if exists postal_codes;
drop table if exists cities;
drop table if exists streets;
drop table if exists houses;

--------------------------------------------------------
create table if not exists titles
(
    id    serial primary key not null,
    title varchar(30)        not null
);
--------------------------------------------------------
create table if not exists languages
(
    id       serial primary key not null,
    language varchar(30)        not null
);
--------------------------------------------------------
create table if not exists genders
(
    id     serial primary key not null,
    gender varchar(30)        not null
);
--------------------------------------------------------
create table if not exists marital_statuses
(
    id             serial primary key not null,
    marital_status varchar(30)
);
--------------------------------------------------------
create table if not exists houses
(
    id              serial primary key not null,
    building_number varchar(50)        not null
);
--------------------------------------------------------
create table if not exists streets
(
    id       serial primary key not null,
    house_id integer,
    street   varchar(100)       not null,
    FOREIGN KEY (house_id) REFERENCES houses (id)
);
--------------------------------------------------------
create table if not exists cities
(
    id        serial primary key not null,
    street_id integer,
    city      varchar(50)        not null,
    FOREIGN KEY (street_id) REFERENCES streets (id)
);
--------------------------------------------------------
create table if not exists postal_codes
(
    id          serial primary key not null,
    house_id    integer,
    street_id   integer,
    city_id     integer,
    postal_code varchar(50)        not null,
    FOREIGN KEY (house_id) REFERENCES houses (id),
    FOREIGN KEY (street_id) REFERENCES streets (id),
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
--------------------------------------------------------
create table if not exists regions
(
    id      serial primary key not null,
    city_id integer,
    region  varchar(30)        not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
--------------------------------------------------------
create table if not exists countries
(
    id      serial primary key not null,
    city_id integer,
    country varchar(2)         not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
--------------------------------------------------------
create table if not exists addresses
(
    id             serial primary key not null,
    house_id       integer,
    street_id      integer,
    city_id        integer,
    postal_code_id integer,
    country_id     integer,
    region_id      integer,
    FOREIGN KEY (house_id) REFERENCES houses (id),
    FOREIGN KEY (street_id) REFERENCES streets (id),
    FOREIGN KEY (city_id) REFERENCES cities (id),
    FOREIGN KEY (country_id) REFERENCES countries (id),
    FOREIGN KEY (region_id) REFERENCES regions (id),
    FOREIGN KEY (region_id) REFERENCES postal_codes (id)
);
--------------------------------------------------------
create table if not exists customers
(
    id                serial primary key not null,
    title_id          integer,
    language_id       integer,
    gender_id         integer,
    marital_status_id integer,
    first_name        varchar(50)        not null,
    last_name         varchar(50)        not null,
    birth_date        date,
    FOREIGN KEY (title_id) REFERENCES titles (id),
    FOREIGN KEY (language_id) REFERENCES languages (id),
    FOREIGN KEY (gender_id) REFERENCES genders (id),
    FOREIGN KEY (marital_status_id) REFERENCES marital_statuses (id)
);
--------------------------------------------------------
create table if not exists customers_to_addresses
(
    id          serial primary key not null,
    customer_id integer,
    address_id  integer,
    FOREIGN KEY (customer_id) REFERENCES customers (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
);
--------------------------------------------------------
create table if not exists order_statues
(
    id          serial primary key not null,
    name varchar(50)
);
--------------------------------------------------------
create table if not exists orders
(
    id          serial primary key not null,
    customer_id integer,
    address_id  integer,
    creation_date date,
    delivery_date date,
    FOREIGN KEY (customer_id) REFERENCES customers (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
);
--------------------------------------------------------
create table if not exists order_logs
(
    id          serial primary key not null,
    status_id integer,
    order_id  integer,
    comment varchar(1024),
    datetime date,
    FOREIGN KEY (status_id) REFERENCES order_statues (id),
    FOREIGN KEY (order_id) REFERENCES orders (id)
);
--------------------------------------------------------