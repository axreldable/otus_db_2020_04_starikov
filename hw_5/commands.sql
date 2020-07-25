docker exec -ti postgres_otus_hw_5 bash
su postgres

mkdir -p /var/lib/postgresql/data/pg_tblspc/quick_ssd
mkdir -p /var/lib/postgresql/data/pg_tblspc/slow_hdd

psql
------------------------------------------------------------------
CREATE ROLE admin_user WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	CREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1;

CREATE ROLE dev_user WITH
	LOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1;
------------------------------------------------------------------
CREATE TABLESPACE quick_ssd
  OWNER admin_user
  LOCATION '/var/lib/postgresql/data/pg_tblspc/quick_ssd';

CREATE TABLESPACE slow_hdd
  OWNER admin_user
  LOCATION '/var/lib/postgresql/data/pg_tblspc/slow_hdd';
------------------------------------------------------------------
CREATE DATABASE internet_store
    WITH
    OWNER = admin_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = slow_hdd
    CONNECTION LIMIT = -1;
------------------------------------------------------------------
psql -d internet_store
------------------------------------------------------------------
REVOKE CREATE ON SCHEMA public FROM public;
GRANT ALL ON SCHEMA public to admin_user; -- admin_user will be owner of all tables
------------------------------------------------------------------
create schema mirror; -- sandbox for dev user
GRANT ALL ON SCHEMA mirror TO dev_user;
------------------------------------------------------------------
psql -d internet_store -U admin_user
------------------------------------------------------------------
drop table if exists cross_category_params;
drop table if exists product_params;
drop table if exists category_params;
drop table if exists products_to_vendors;
drop table if exists products_to_suppliers;
drop table if exists vendors;
drop table if exists suppliers;
drop table if exists orders_to_products;
drop table if exists currency;
drop table if exists product_logs;
drop table if exists products;
drop table if exists product_statues;
drop table if exists categories;
drop table if exists order_logs;
drop table if exists order_statues;
drop table if exists orders;
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
COMMENT ON TABLE titles IS 'A title of the customer.';
COMMENT ON COLUMN titles.title IS 'Possible variants: Dr., Miss, Mr., etc.';
--------------------------------------------------------
create table if not exists languages
(
    id       serial primary key not null,
    language varchar(30)        not null
);
COMMENT ON TABLE languages IS 'Customer language.';
COMMENT ON COLUMN languages.language IS '2 symbols language code: CS, DE, etc.';
--------------------------------------------------------
create table if not exists genders
(
    id     serial primary key not null,
    gender varchar(30)        not null
);
COMMENT ON TABLE genders IS 'Customer gender.';
COMMENT ON COLUMN genders.gender IS 'Possible variants: Female, Male, Unknown, etc.';
--------------------------------------------------------
create table if not exists marital_statuses
(
    id             serial primary key not null,
    marital_status varchar(30)
);
COMMENT ON TABLE marital_statuses IS 'Customer marital status.';
COMMENT ON COLUMN marital_statuses.marital_status IS 'Possible variants: single etc.';
--------------------------------------------------------
create table if not exists houses
(
    id              serial primary key not null,
    building_number varchar(50)        not null
);
COMMENT ON TABLE houses IS 'House numbers for addresses.';
COMMENT ON COLUMN houses.building_number IS 'Possible variants: 100/10 10/7, 101 etc.';
--------------------------------------------------------
create table if not exists streets
(
    id       serial primary key not null,
    house_id integer,
    street   varchar(100)       not null,
    FOREIGN KEY (house_id) REFERENCES houses (id)
);
COMMENT ON TABLE streets IS 'Street names for addresses. The street contains particular building numbers.';
--------------------------------------------------------
create table if not exists cities
(
    id        serial primary key not null,
    street_id integer,
    city      varchar(50)        not null,
    FOREIGN KEY (street_id) REFERENCES streets (id)
);
COMMENT ON TABLE cities IS 'Cities names for addresses. The city contains particular streets.';
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
COMMENT ON TABLE postal_codes IS 'Postal code depends on the city, street and building number.';
--------------------------------------------------------
create table if not exists regions
(
    id      serial primary key not null,
    city_id integer,
    region  varchar(30)        not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
COMMENT ON TABLE regions IS 'Regions names for addresses. The region contains particular cities.';
--------------------------------------------------------
create table if not exists countries
(
    id      serial primary key not null,
    city_id integer,
    country varchar(2)         not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
COMMENT ON TABLE countries IS 'Countries names for addresses. The country contains particular cities.';
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
COMMENT ON TABLE addresses IS 'Denormalize representation of address. Consistency control works on the client.';
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
COMMENT ON TABLE customers IS 'Customers table. Each customer can have several addresses and vice a versa each address has several customers.';
--------------------------------------------------------
create table if not exists customers_to_addresses
(
    id          serial primary key not null,
    customer_id integer,
    address_id  integer,
    FOREIGN KEY (customer_id) REFERENCES customers (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
);
COMMENT ON TABLE customers_to_addresses IS 'Many to many connection between customers and addresses';
--------------------------------------------------------
create table if not exists order_statues
(
    id     serial primary key not null,
    status varchar(50)
);
COMMENT ON TABLE order_statues IS 'Statuses of the orders.';
COMMENT ON COLUMN order_statues.status IS 'Possible variants: client_buying, approved, assembling at warehouse  etc.';
--------------------------------------------------------
create table if not exists orders
(
    id            serial primary key not null,
    customer_id   integer,
    address_id    integer,
    creation_date date,
    delivery_date date,
    FOREIGN KEY (customer_id) REFERENCES customers (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
);
COMMENT ON TABLE orders IS 'Customer orders. Can be to the address which is not belonged to the client.';
COMMENT ON COLUMN orders.creation_date IS 'Date of the order creation.';
COMMENT ON COLUMN orders.delivery_date IS 'Date of the order delivery.';
--------------------------------------------------------
create table if not exists order_logs
(
    id        serial primary key not null,
    status_id integer,
    order_id  integer,
    comment   varchar(1024),
    datetime  date,
    FOREIGN KEY (status_id) REFERENCES order_statues (id),
    FOREIGN KEY (order_id) REFERENCES orders (id)
);
COMMENT ON TABLE order_logs IS 'Change log of the order changing. Status with latest datetime is active.';
--------------------------------------------------------
create table if not exists vendors
(
    id   serial primary key not null,
    name varchar(100)
);
COMMENT ON TABLE vendors IS 'Vendor of the product.';
--------------------------------------------------------
create table if not exists suppliers
(
    id   serial primary key not null,
    name varchar(100)
);
COMMENT ON TABLE suppliers IS 'Supplier of the product.';
--------------------------------------------------------
create table if not exists categories
(
    id        serial primary key not null,
    parent_id integer,
    category  varchar(255),
    FOREIGN KEY (parent_id) REFERENCES categories (id)
);
COMMENT ON TABLE categories IS 'Category of the product. Support tree hierarchy.';
--------------------------------------------------------
create table if not exists currency
(
    id   serial primary key not null,
    code varchar(3)
);
COMMENT ON TABLE currency IS 'Currency dictionary';
COMMENT ON COLUMN currency.code IS 'Possible variants: RUB, USD, EUR etc.';
--------------------------------------------------------
create table if not exists products
(
    id            serial primary key not null,
    category_id   integer,
    currency_id   integer,
    name          varchar(100),
    creation_date date,
    price         decimal,
    FOREIGN KEY (category_id) REFERENCES categories (id),
    FOREIGN KEY (currency_id) REFERENCES currency (id)
);
COMMENT ON TABLE products IS 'Product table.';
COMMENT ON COLUMN products.creation_date IS 'Date of the product creation.';
--------------------------------------------------------
create table if not exists products_to_vendors
(
    id         serial primary key not null,
    vendor_id  integer,
    product_id integer,
    FOREIGN KEY (vendor_id) REFERENCES vendors (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
);
COMMENT ON TABLE products_to_vendors IS 'Many to many connection between products and vendors';
--------------------------------------------------------
create table if not exists products_to_suppliers
(
    id          serial primary key not null,
    supplier_id integer,
    product_id  integer,
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
);
COMMENT ON TABLE products_to_suppliers IS 'Many to many connection between products and suppliers';
--------------------------------------------------------
create table if not exists orders_to_products
(
    id         serial primary key not null,
    order_id   integer,
    product_id integer,
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
);
COMMENT ON TABLE orders_to_products IS 'Many to many connection between orders and products';
--------------------------------------------------------
create table if not exists product_statues
(
    id     serial primary key not null,
    status varchar(50)
);
COMMENT ON TABLE product_statues IS 'Statuses of the orders.';
COMMENT ON COLUMN product_statues.status IS 'Possible variants: price changed, vendor changed etc.';
--
create table if not exists product_logs
(
    id         serial primary key not null,
    status_id  integer,
    product_id integer,
    comment    varchar(1024),
    datetime   date,
    FOREIGN KEY (status_id) REFERENCES product_statues (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
);
COMMENT ON TABLE product_logs IS 'Change log of the product changing.';
--------------------------------------------------------
create table if not exists category_params
(
    id            serial primary key not null,
    param_name    varchar(1024),
    param_type    varchar(50),
    default_value varchar(1024)
);
COMMENT ON TABLE category_params IS 'Category param table.';
COMMENT ON COLUMN category_params.param_type IS 'A type of the parameter.';
--------------------------------------------------------
create table if not exists product_params
(
    id                serial primary key not null,
    product_id        integer,
    category_param_id integer,
    varchar_value     varchar(1024),
    int_value         integer,
    float_value       float,
    text_value        text,
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (category_param_id) REFERENCES category_params (id)
);
COMMENT ON TABLE product_params IS 'Table with params with different types.';
--------------------------------------------------------
create table if not exists cross_category_params
(
    id                serial primary key not null,
    category_id       integer,
    category_param_id integer,
    FOREIGN KEY (category_id) REFERENCES categories (id),
    FOREIGN KEY (category_param_id) REFERENCES category_params (id)
);
COMMENT ON TABLE orders_to_products IS 'Many to many connection between categories and category_params';
--------------------------------------------------------

------------------------------------------------------------------
psql -d internet_store
------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dev_user; -- admin_user will be allowed to read from tables
GRANT INSERT ON ALL TABLES IN SCHEMA public TO dev_user; -- admin_user will be allowed to insert to tables
------------------------------------------------------------------
psql -d internet_store -U dev_user
------------------------------------------------------------------
insert into languages values (1, 'DE');
insert into languages values (2, 'CS');
select * from languages;
------------------------------------------------------------------
create table if not exists mirror.languages
(
    id       serial primary key not null,
    language varchar(30)        not null
) tablespace slow_hdd;
COMMENT ON TABLE mirror.languages IS 'Customer language.';
COMMENT ON COLUMN mirror.languages.language IS '2 symbols language code: CS, DE, etc.';

insert into mirror.languages values (1, 'DE');
insert into mirror.languages values (2, 'CS');
select * from mirror.languages;
------------------------------------------------------------------
psql -d internet_store -U admin_user
------------------------------------------------------------------
select * from languages;
select * from mirror.languages; -- permission denied
------------------------------------------------------------------