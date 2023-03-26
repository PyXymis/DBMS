# Homework V
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### DML в PostgreSQL

**Цель:**<br>
* *Написать запрос с конструкциями SELECT, JOIN*
* *Написать запрос с добавлением данных INSERT INTO*
* *Написать запрос с обновлением данных с UPDATE FROM*
* *Использовать using для оператора DELETE*

Описание/Пошаговая инструкция выполнения домашнего задания:
1. Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти.
2. Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?
3. Напишите запрос на добавление данных с выводом информации о добавленных строках.
4. Напишите запрос с обновлением данные используя UPDATE FROM.
5. Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using.

**Задание со * :**
* Приведите пример использования утилиты COPY

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 5 баллов за задание со *
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890540-eda943c2-e323-4d0f-8213-ec2afbfc40d9.png&#41;)
[//]: # (   )
# Solution
### 1. Запросы с использованием поиска по подстроке:
```sql
-- Like construction to find all gmail users
SELECT * FROM delivery.account
WHERE email LIKE '%gmail\.com';
-- Substring construction to extract logs by date
SELECT * FROM metrics.logs
WHERE substring(log_message FROM '2023-04-20') = '2023-04-20';
-- Regexp construction to find all orders with good feedback
SELECT * FROM delivery.contract
WHERE regexp_like(feedback, '(good|best|well)');
```
### 2. Запрос с использованием LEFT JOIN и INNER JOIN
```sql
-- Left Join
SELECT *
FROM delivery.account AS a
LEFT JOIN delivery.contract AS c ON a.id = c.account_id
INNER JOIN delivery.address AS addr ON c.address_id = addr.id;
-- Inner Join
SELECT *
FROM delivery.account AS a
INNER JOIN delivery.address AS addr ON c.address_id = addr.id
LEFT JOIN delivery.contract AS c ON a.id = c.account_id;
```
*В первом запросе (LEFT JOIN первым) мы получим все записи из таблицы account, даже если они не
имеют соответствующей записи в таблицах contract и address. Во втором запросе (INNER JOIN первым)
мы получим только записи, для которых есть соответствующие записи в таблице address, а записи без
связей с таблицами contract и address не будут отображаться.* 
### 3. Запрос на создание 5 пользователей в таблице account с выводом результатов:
```sql
INSERT INTO delivery.account (id, first_name, second_name, phone, email, gender, birthday, is_push_allow, is_superuser, is_staff)
VALUES ('Jane', 'Smith', '987-654-3210', 'jane.smith@example.com', 'F', '1995-03-15', TRUE, FALSE, FALSE),
       ('John', 'Doe', '123-456-7890', 'john.doe@example.com', 'M', '1990-01-01', TRUE, FALSE, TRUE),
       ('Alice', 'Johnson', '111-222-3333', 'alice.johnson@example.com', 'F', '1992-05-12', FALSE, FALSE, TRUE),
       ('Bob', 'Williams', '555-555-5555', 'bob.williams@example.com', 'M', '1985-12-31', FALSE, FALSE, FALSE),
       ('Emma', 'Davis', '444-444-4444', 'emma.davis@example.com', 'F', '1988-09-22', TRUE, FALSE, FALSE)
RETURNING *;
```

### 4. Запрос на обновление статуса активности продуктов, которые относятся к неактивным категориям:
```sql
UPDATE delivery.product
SET is_active = FALSE
FROM delivery.category
WHERE delivery.product.category_id = delivery.category.id
AND delivery.category.is_active = FALSE;
```

### 5.Запрос на удаление данных с оператором DELETE используя join с другой таблицей с помощью using.
```sql
DELETE FROM delivery.contract
USING delivery.account
WHERE delivery.contract.account_id = delivery.account.id
AND delivery.account.first_name = 'John';
```
### * Пример использования утилиты COPY
```sql
-- For backups
COPY delivery.product TO '/tmp/product_backup.csv' DELIMITER ',' CSV HEADER;
COPY delivery.product_copy FROM '/tmp/product_backup.csv' DELIMITER ',' CSV HEADER; 
-- For filling tables
COPY metrics.metrics (table_name, operation_type, operation_date, execution_time, rows_affected)
FROM (
    SELECT 'delivery.contract' AS table_name, status_id AS operation_type, NOW() AS operation_date, 0 AS execution_time, count(*) AS rows_affected
    FROM delivery.contract
) AS copy_data;
```





