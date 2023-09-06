# Homework IV
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### DDL скрипты для postgresql

**Цель:**<br>
* *Реализовать спроектированную схему в postgres*

Описание/Пошаговая инструкция выполнения домашнего задания:
* Используя операторы DDL создайте на примере схемы интернет-магазина:
1. Базу данных.
2. Табличные пространства и роли.
3. Схему данных.
4. Таблицы своего проекта, распределив их по схемам и табличным пространствам.

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890540-eda943c2-e323-4d0f-8213-ec2afbfc40d9.png&#41;)
[//]: # (   )
# Solution

    Схема таблицы: https://dbdesign.online/model/LDCflu9OcAdd
*Сначала необходимо создать базу данных:*
```sql
CREATE DATABASE delivery_food;
```
*Для создания табличных пространств н0еобходимо предварительно создать папки и назначать владельцем postgres:*
```bash
sudo mkdir /var/lib/postgresql/data/DBMS/delivery
sudo mkdir /var/lib/postgresql/data/DBMS/profile
sudo chown postgresql:postgresql /var/lib/postgresql/data/DBMS/delivery
sudo chown postgresql:postgresql /var/lib/postgresql/data/DBMS/profile
```
*После этого можем создавать табличные пространства:*
```sql
CREATE TABLESPACE delivery_tablespace LOCATION '/var/lib/postgres/DBSM/delivery';
CREATE TABLESPACE metrics_tablespace LOCATION '/var/lib/postgres/DBSM/metrics';
```
*Далее создаем роли:*
```sql
CREATE ROLE staff PASSWORD '{SECRET}';
CREATE ROLE delivery PASSWORD '{SECRET}';
```
*Создаем схемы:*
```sql
CREATE SCHEMA metrics AUTHORIZATION staff;
CREATE SCHEMA delivery AUTHORIZATION delivery;
```
*Создаем таблицы:*
```sql
-- Таблица пользователей
CREATE TABLE delivery.account (
    id INTEGER PRIMARY KEY,
    first_name VARCHAR(256),
    second_name VARCHAR(256),
    phone VARCHAR(16),
    email VARCHAR(256),
    gender VARCHAR(2),
    birthday TIMESTAMP,
    is_push_allow BOOLEAN,
    is_superuser BOOLEAN,
    is_staff BOOLEAN
) TABLESPACE delivery_tablespace;
-- Таблица категорий
CREATE TABLE delivery.category (
    id SERIAL PRIMARY KEY,
    is_active boolean,
    title VARCHAR(255) NOT NULL,
    updated TIMESTAMP NOT NULL,
    created TIMESTAMP NOT NULL,
    slug VARCHAR(1023) UNIQUE,
    image VARCHAR(128) UNIQUE,
    description TEXT,
    parend_id INTEGER REFERENCES delivery.category(id)
) TABLESPACE delivery_tablespace;
-- Таблица товаров
CREATE TABLE delivery.product (
    id SERIAL PRIMARY KEY,
    title VARCHAR(256),
    is_active BOOLEAN,
    updated TIMESTAMP,
    created TIMESTAMP,
    slug VARCHAR(1024),
    description TEXT,
    image VARCHAR(128),
    category_id INTEGER REFERENCES delivery.category(id),
    stock INTEGER
) TABLESPACE delivery_tablespace;
-- Таблица заказов
CREATE TABLE delivery.contract (
    id SERIAL PRIMARY KEY,
    extra_code VARCHAR(256),
    addtext TEXT, 
    total DECIMAL(2, 10),
    updated TIMESTAMP,
    created TIMESTAMP,
    payment_done BOOLEAN,
    payment_date TIMESTAMP,
    phone VARCHAR(16),
    email VARCHAR(128),
    address_id INTEGER REFERENCES delivery.address(id),
    account_id INTEGER REFERENCES delivery.account(id),
    bonuses_used INTEGER,
    bonuses_apply BOOLEAN
) TABLESPACE delivery_tablespace;
-- Таблица адресов
CREATE TABLE delivery.address (
	id SERIAL PRIMARY KEY,
	account_id INTEGER REFERENCES delivery.account,
	dist VARCHAR(256),
	street VARCHAR(256),
	house VARCHAR(32),
	liter INTEGER,
	enterance INTEGER,
	is_doorphone_exist BOOLEAN,
	not_call_doorphone BOOLEAN,
	latitude DECIMAL(2, 10),
	longitude DECIMAL(2, 10),
	geolocation INTEGER PRIMARY KEY
) TABLESPACE delivery_tablespace;
-- Таблица для сбора метрик
CREATE TABLE metrics.metrics (
	id SERIAL PRIMARY KEY,
	table_name VARCHAR(256),
	operation_type VARCHAR(256),
	operation_date TIMESTAMP,
	execution_time NUMERIC(10,2),
	rows_affected INTEGER
) TABLESPACE metrics_tablespace;
-- Таблица для записи логов
CREATE TABLE metrics.logs (
	id SERIAL PRIMARY KEY,
	log_level VARCHAR(16),
	log_message TEXT,
	log_date TIMESTAMP,
	account_id INTEGER REFERENCES delivery.account(id)
	operation_type VARCHAR(256),
	operation_table VARCHAR(256)
) TABLESPACE metrics_tablespace;
```

### Result:
![image](https://user-images.githubusercontent.com/37443340/235297614-f7e9edb1-af7c-4e59-b80c-b9f98551b7cf.png)
![image](https://user-images.githubusercontent.com/37443340/235297459-11bb63ff-1a87-4fd0-a50d-45e9b963f839.png)