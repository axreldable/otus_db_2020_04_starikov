# HW_5

DDL скрипты для postgres  
Цель: реализация спроектированной схемы в postgres  
Используя операторы DDL создайте на примере имеющейся схемы интернет-магазина:
1. Базу данных.
2. Табличные пространства и роли.
3. Схему данных.
4. Таблицы своего проекта, распределив их по схемам и
табличным пространствам.

Описание дз:  
[DDL Commands](https://github.com/axreldable/otus_db_2020_04_starikov/blob/master/hw_5/commands.sql)
```
- Создано 2 табличных пространства:
    - quick_ssd - в нем будут хранится таблицы, требующего быстрого доступа (customers + orders) 
    - slow_hdd - обычные диски - все остальные таблицы
- Создано 2 роли:
    - admin_user - является овнером таблиц из public schema (создает их может читать и писать)
    - dev_user - может только писать и читать в схеме public
- Schemas:
    - public - используется как основная схема, содержит все таблицы
    - mirrow - используется как вспомогательная схема для dev_user. В ней dev_user может создавать таблицы. 
                Все таблицы в этой схеме располагаются в slow_hdd пространстве. 
                Предполагается использовать эту схему для тестирования основной public.
```
