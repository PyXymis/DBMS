# Homework IX
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Создаем базу данных MySQL в докере

**Цель:**<br>
* *Упаковка скриптов создания БД в контейнер*

**Описание/Пошаговая инструкция выполнения домашнего задания:**
1. *забрать стартовый репозиторий https://github.com/aeuge/otus-mysql-docker*
2. *прописать sql скрипт для создания своей БД в init.sql*
3. *проверить запуск и работу контейнера следую описанию в репозитории*

**Задание со * :**
* *Прописать кастомный конфиг - настроить innodb_buffer_pool и другие параметры по желанию*
* *Протестить сисбенчем - результат теста приложить в README*

***Критерии оценки:***
* 10 - контейнер с базой запускается, база создается
* плюс 2 балла - также реализован кастомный конфиг
* плюс 3 балла - приложены результаты сисбенча

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
[//]: (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# PoW
![image](https://github.com/PyXymis/DBMS/assets/37443340/e93a6ffc-d401-4df3-9f2a-d4a79d8e7c1f)
# Solution
- *Внутри папки домашнего задания так же есть все файлы, используемые для выполнения задания*
1. Для решения задачи был составлен файл со следующим содержимым **init.sql**:
```sql
CREATE DATABASE IF NOT EXISTS delivery;
USE delivery;

CREATE TABLE  IF NOT EXISTS profile (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(256),
    second_name VARCHAR(256),
    phone VARCHAR(16),
    email VARCHAR(256),
    gender VARCHAR(2),
    birthday TIMESTAMP,
    is_push_allow TINYINT(1),
    is_superuser TINYINT(1),
    is_staff TINYINT(1)
);

CREATE TABLE  IF NOT EXISTS category (
    id INTEGER PRIMARY KEY,
    is_active boolean,
    title VARCHAR(255) NOT NULL,
    updated TIMESTAMP NOT NULL,
    created TIMESTAMP NOT NULL,
    slug VARCHAR(500) UNIQUE,
    image VARCHAR(128) UNIQUE,
    description TEXT,
    parent_id INTEGER
);

-- Иначе не получалось сразу указать FOREIGN KEY на себя 
ALTER TABLE category
ADD FOREIGN KEY (parent_id) REFERENCES category(id);

CREATE TABLE  IF NOT EXISTS product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(256),
    is_active TINYINT(1),
    updated TIMESTAMP,
    created TIMESTAMP,
    slug VARCHAR(1024),
    description TEXT,
    image VARCHAR(128),
    category_id INT,
    stock INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES category(id)
);

CREATE TABLE  IF NOT EXISTS address (
	id INT AUTO_INCREMENT PRIMARY KEY,
	profile_id INT,
	dist VARCHAR(256),
	street VARCHAR(256),
	house VARCHAR(32),
	liter INT,
	entrance INT,
	is_doorphone_exist TINYINT(1),
	not_call_doorphone TINYINT(1),
	latitude DECIMAL(10, 2),
	longitude DECIMAL(10, 2),
	geolocation JSON,
    FOREIGN KEY (profile_id) REFERENCES profile(id)
);

CREATE TABLE contract (
    id INT AUTO_INCREMENT PRIMARY KEY,
    extra_code VARCHAR(256),
    addtext TEXT,
    total DECIMAL(10, 2),
    updated TIMESTAMP,
    created TIMESTAMP,
    payment_done TINYINT(1),
    payment_date TIMESTAMP,
    phone VARCHAR(16),
    email VARCHAR(128),
    address_id INT,
    profile_id INT,
    bonuses_used INT,
    bonuses_apply TINYINT(1),
    FOREIGN KEY (address_id) REFERENCES address(id),
    FOREIGN KEY (profile_id) REFERENCES profile(id)
);

CREATE TABLE  IF NOT EXISTS metrics (
	id INT AUTO_INCREMENT PRIMARY KEY,
	table_name VARCHAR(256),
	operation_type VARCHAR(256),
	operation_date TIMESTAMP,
	execution_time DECIMAL(10,2),
	rows_affected INT
);

CREATE TABLE  IF NOT EXISTS logs (
	id INT AUTO_INCREMENT PRIMARY KEY,
	log_level VARCHAR(16),
	log_message TEXT,
	log_date TIMESTAMP,
	profile_id INT,
	operation_type VARCHAR(256),
	operation_table VARCHAR(256),
    FOREIGN KEY (profile_id) REFERENCES profile(id)
);
```
2. Содержимое файла **my.cnf**:
```cnf
[mysqld]
default-authentication-plugin=mysql_native_password
innodb_buffer_pool_size = 1G
max_connections = 200
innodb_log_file_size = 524288000
innodb_flush_log_at_trx_commit = 2
bind-address=0.0.0.0
```
3. Для составления отчета **sysbench** использовал следующую строку запуска:
```shell
sysbench \
    --db-driver=mysql \
    --mysql-user=root \
    --mysql_password=12345 \
    --mysql-db=delivery \
    --mysql-host=127.0.0.1 \
    --mysql-port=3307 \
    --tables=16 \
    --table-size=10000 \
      /usr/share/sysbench/oltp_read_write.lua prepare
```
4. Результаты тестирования:
```shell
Inserting 10000 records into 'sbtest2'
Creating a secondary index on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 10000 records into 'sbtest3'
Creating a secondary index on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 10000 records into 'sbtest4'
Creating a secondary index on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 10000 records into 'sbtest5'
Creating a secondary index on 'sbtest5'...
Creating table 'sbtest6'...
Inserting 10000 records into 'sbtest6'
Creating a secondary index on 'sbtest6'...
Creating table 'sbtest7'...
Inserting 10000 records into 'sbtest7'
Creating a secondary index on 'sbtest7'...
Creating table 'sbtest8'...
Inserting 10000 records into 'sbtest8'
Creating a secondary index on 'sbtest8'...
Creating table 'sbtest9'...
Inserting 10000 records into 'sbtest9'
Creating a secondary index on 'sbtest9'...
Creating table 'sbtest10'...
Inserting 10000 records into 'sbtest10'
Creating a secondary index on 'sbtest10'...
Creating table 'sbtest11'...
Inserting 10000 records into 'sbtest11'
Creating a secondary index on 'sbtest11'...
Creating table 'sbtest12'...
Inserting 10000 records into 'sbtest12'
Creating a secondary index on 'sbtest12'...
Creating table 'sbtest13'...
Inserting 10000 records into 'sbtest13'
Creating a secondary index on 'sbtest13'...
Creating table 'sbtest14'...
Inserting 10000 records into 'sbtest14'
Creating a secondary index on 'sbtest14'...
Creating table 'sbtest15'...
Inserting 10000 records into 'sbtest15'
Creating a secondary index on 'sbtest15'...
Creating table 'sbtest16'...
Inserting 10000 records into 'sbtest16'
Creating a secondary index on 'sbtest16'...
```