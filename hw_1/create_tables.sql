drop table if exists hw_1;
create table if not exists hw_1
(
    id                      serial primary key not null,
    title                   varchar(50)           not null,
    first_name              varchar(50)           not null,
    last_name               varchar(50)           not null,
    correspondence_language varchar(50),
    birth_date              varchar(50),
    gender                  varchar(50)           not null,
    marital_status          varchar(50)           not null,
    country                 varchar(50)           not null,
    postal_code             varchar(50)           not null,
    region                  varchar(50)           not null,
    city                    varchar(50)           not null,
    street                  varchar(100)           not null,
    building_number         varchar(50)           not null
);


COPY hw_1 (title, first_name, last_name, correspondence_language, birth_date, gender, marital_status, country,
           postal_code, region, city, street, building_number)
    FROM '/tmp/input_data/some_customers.csv' DELIMITER ',' CSV HEADER;
