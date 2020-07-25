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
create table test_1(id integer) tablespace slow_hdd;
create table test_2(id integer) tablespace quick_ssd;
------------------------------------------------------------------
psql -d internet_store
------------------------------------------------------------------
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dev_user; -- admin_user will be allowed to read from tables
GRANT INSERT ON ALL TABLES IN SCHEMA public TO dev_user; -- admin_user will be allowed to insert to tables
------------------------------------------------------------------
psql -d internet_store -U dev_user
------------------------------------------------------------------
insert into test_1 values (1);
insert into test_2 values (1);
select * from test_1;
select * from test_2;

create table mirror.test_1(id integer) tablespace slow_hdd;
create table mirror.test_2(id integer) tablespace slow_hdd;
insert into mirror.test_1 values (1);
insert into mirror.test_2 values (1);
select * from mirror.test_1;
select * from mirror.test_2;
------------------------------------------------------------------
psql -d internet_store -U admin_user
------------------------------------------------------------------
select * from test_1;
select * from test_2;

select * from mirror.test_1; -- permission denied
select * from mirror.test_2; -- permission denied
------------------------------------------------------------------