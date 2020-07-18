drop table if exists cross_category_params;
drop table if exists product_params;
drop table if exists category_params;
drop table if exists products_to_vendors;
drop table if exists products_to_suppliers;
drop table if exists vendors;
drop table if exists suppliers;
drop table if exists orders_to_products;
drop table if exists price_logs;
drop table if exists prices;
drop table if exists currency;
drop table if exists products;
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
drop table if exists product_statues;
drop table if exists product_logs;

--
create table if not exists titles
(
    id    integer primary key auto_increment,
    title varchar(30) not null comment 'Possible variants: Dr., Miss, Mr., etc.'
)
    COMMENT = 'A title of the customer.';
--
create table if not exists languages
(
    id       integer primary key auto_increment,
    language varchar(30) not null comment '2 symbols language code: CS, DE, etc.'
)
    COMMENT = 'Customer language.';
--
create table if not exists genders
(
    id     integer primary key auto_increment,
    gender varchar(30) not null comment 'Possible variants: Female, Male, Unknown, etc.'
)
    COMMENT = 'Customer gender.';
--
create table if not exists marital_statuses
(
    id             integer primary key auto_increment,
    marital_status varchar(30) comment 'Possible variants: single etc.'
)
    COMMENT = 'Customer marital status.';
--
create table if not exists houses
(
    id              integer primary key auto_increment,
    building_number varchar(50) not null comment 'Possible variants: 100/10 10/7, 101 etc.'
)
    COMMENT = 'House numbers for addresses.';
--
create table if not exists streets
(
    id       integer primary key auto_increment,
    house_id integer,
    street   varchar(100) not null,
    FOREIGN KEY (house_id) REFERENCES houses (id)
)
    COMMENT = 'Street names for addresses. The street contains particular building numbers.';
--
create table if not exists cities
(
    id        integer primary key auto_increment,
    street_id integer,
    city      varchar(50) not null,
    FOREIGN KEY (street_id) REFERENCES streets (id)
)
    COMMENT = 'Cities names for addresses. The city contains particular streets.';
--
create table if not exists postal_codes
(
    id          integer primary key auto_increment,
    house_id    integer,
    street_id   integer,
    city_id     integer,
    postal_code varchar(50) not null,
    FOREIGN KEY (house_id) REFERENCES houses (id),
    FOREIGN KEY (street_id) REFERENCES streets (id),
    FOREIGN KEY (city_id) REFERENCES cities (id)
)
    COMMENT = 'Postal code depends on the city, street and building number.';
--
create table if not exists regions
(
    id      integer primary key auto_increment,
    city_id integer,
    region  varchar(30) not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
)
    COMMENT = 'Regions names for addresses. The region contains particular cities.';
--
create table if not exists countries
(
    id      integer primary key auto_increment,
    city_id integer,
    country varchar(2) not null,
    FOREIGN KEY (city_id) REFERENCES cities (id)
)
    COMMENT = 'Countries names for addresses. The country contains particular cities.';
--
create table if not exists addresses
(
    id             integer primary key auto_increment,
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
)
    COMMENT = 'Denormalize representation of address. Consistency control works on the client.';
--
create table if not exists customers
(
    id                integer primary key auto_increment,
    title_id          integer,
    language_id       integer,
    gender_id         integer,
    marital_status_id integer,
    first_name        varchar(50) not null,
    last_name         varchar(50) not null,
    birth_date        date,
    FOREIGN KEY (title_id) REFERENCES titles (id),
    FOREIGN KEY (language_id) REFERENCES languages (id),
    FOREIGN KEY (gender_id) REFERENCES genders (id),
    FOREIGN KEY (marital_status_id) REFERENCES marital_statuses (id)
)
    COMMENT = 'Customers table. Each customer can have several addresses and vice a versa each address has several customers.';
--
create table if not exists customers_to_addresses
(
    id          integer primary key auto_increment,
    customer_id integer,
    address_id  integer,
    FOREIGN KEY (customer_id) REFERENCES customers (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
)
    COMMENT = 'Many to many connection between customers and addresses';
--
create table if not exists order_statues
(
    id     integer primary key auto_increment,
    status varchar(50) comment 'Possible variants: client_buying, approved, assembling at warehouse  etc.'
)
    COMMENT = 'Statuses of the orders.';
--
create table if not exists orders
(
    id            integer primary key auto_increment,
    customer_id   integer,
    address_id    integer,
    creation_date date comment 'Date of the order creation.',
    delivery_date date comment 'Date of the order delivery.',
    FOREIGN KEY (customer_id) REFERENCES customers (id),
    FOREIGN KEY (address_id) REFERENCES addresses (id)
)
    COMMENT = 'Customer orders. Can be to the address which is not belonged to the client.';
--
create table if not exists order_logs
(
    id        integer primary key auto_increment,
    status_id integer,
    order_id  integer,
    comment   varchar(1024),
    datetime  date,
    FOREIGN KEY (status_id) REFERENCES order_statues (id),
    FOREIGN KEY (order_id) REFERENCES orders (id)
)
    COMMENT = 'Change log of the order changing. Status with latest datetime is active.';
--
create table if not exists vendors
(
    id   integer primary key auto_increment,
    name varchar(100)
)
    COMMENT = 'Vendor of the product.';
--
create table if not exists suppliers
(
    id   integer primary key auto_increment,
    name varchar(100)
)
    COMMENT = 'Supplier of the product.';
--
create table if not exists categories
(
    id        integer primary key auto_increment,
    parent_id integer,
    category  varchar(255),
    FOREIGN KEY (parent_id) REFERENCES categories (id)
)
    COMMENT = 'Category of the product. Support tree hierarchy.';
--
create table if not exists currency
(
    id   integer primary key auto_increment,
    code varchar(3) comment 'Possible variants: RUB, USD, EUR etc.'
)
    COMMENT = 'Currency dictionary';
--
create table if not exists products
(
    id            integer primary key auto_increment,
    category_id   integer,
    currency_id   integer,
    name          varchar(100),
    creation_date date comment 'Date of the product creation.',
    price         decimal,
    FOREIGN KEY (category_id) REFERENCES categories (id),
    FOREIGN KEY (currency_id) REFERENCES currency (id)
)
    COMMENT = 'Product table.';
--
create table if not exists products_to_vendors
(
    id         integer primary key auto_increment,
    vendor_id  integer,
    product_id integer,
    FOREIGN KEY (vendor_id) REFERENCES vendors (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
)
    COMMENT = 'Many to many connection between products and vendors';
--
create table if not exists products_to_suppliers
(
    id          integer primary key auto_increment,
    supplier_id integer,
    product_id  integer,
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
)
    COMMENT = 'Many to many connection between products and suppliers';
--
create table if not exists orders_to_products
(
    id         integer primary key auto_increment,
    order_id   integer,
    product_id integer,
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
)
    COMMENT = 'Many to many connection between orders and products';
--
create table if not exists product_statues
(
    id     integer primary key auto_increment,
    status varchar(50) comment 'Possible variants: price changed, vendor changed etc.'
)
    COMMENT = 'Statuses of the orders.';
--
create table if not exists product_logs
(
    id         integer primary key auto_increment,
    status_id  integer,
    product_id integer,
    comment    varchar(1024),
    datetime   date,
    FOREIGN KEY (status_id) REFERENCES product_statues (id),
    FOREIGN KEY (product_id) REFERENCES products (id)
)
    COMMENT = 'Change log of the product changing.';
--
create table if not exists category_params
(
    id            integer primary key auto_increment,
    param_name    varchar(1024),
    param_type    varchar(50) comment 'A type of the parameter.',
    default_value varchar(1024)
)
    COMMENT = 'Category param table.';
--
create table if not exists product_params
(
    id                integer primary key auto_increment,
    product_id        integer,
    category_param_id integer,
    varchar_value     varchar(1024),
    int_value         integer,
    float_value       float,
    text_value        text,
    FOREIGN KEY (product_id) REFERENCES products (id),
    FOREIGN KEY (category_param_id) REFERENCES category_params (id)
)
    COMMENT = 'Table with params with different types.';
--
create table if not exists cross_category_params
(
    id                integer primary key auto_increment,
    category_id       integer,
    category_param_id integer,
    FOREIGN KEY (category_id) REFERENCES categories (id),
    FOREIGN KEY (category_param_id) REFERENCES category_params (id)
)
    COMMENT = 'Many to many connection between categories and category_params';
