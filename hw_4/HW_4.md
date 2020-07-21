# HW_4

1. Развернуть контейнер с PostgreSQL или установить СУБД на виртуальную машину.
2. Запустить сервер.

```docker-compose up -d```

3. Создать клиента с подключением к базе данных postgres через командную строку.

```bash
docker exec -ti postgres_otus_hw_4 bash
su postgres
psql
\l

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```



4. Подключиться к серверу используя pgAdmin или другое аналогичное приложение.

```
http://localhost:5050
login: test@mail.ru
password: admin
```

При подключении укажите Hostname/address:
```
Hostname/address: postgres-db
Username: postgres
Password: postgres
```

Скриншот по пути `http://localhost:5050/browser/`
![pgadmin](https://github.com/axreldable/otus_db_2020_04_starikov/tree/master/hw_4/pgadmin.png)
