# Homework XI
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### SQL выборка

**Цель:**<br>
* *Научиться джойнить таблицы и использовать условия в SQL выборке*

**Описание/Пошаговая инструкция выполнения домашнего задания:**
1. *Напишите запрос по своей базе с inner join*
2. *Напишите запрос по своей базе с left join*
3. *Напишите 5 запросов с WHERE с использованием разных операторов, опишите для чего вам в проекте нужна такая выборка данных*

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
- Используя структуру таблицы созданной в [Homework IX](/Homework%20IX/README.md) напишем запросы с использованием различных видов джойнов и условий
1. *Напишите запрос по своей базе с **_INNER JOIN_**:*
```sql
-- Запрос для получения информации о контрактах и соответствующих профилях пользователей
SELECT 
    contract.id as contract_id,
    contract.total as total_price,
    profile.first_name,
    profile.second_name
FROM
    contract
INNER JOIN
    profile
ON
    contract.profile_id = profile.id;
```
2. *Напишите запрос по своей базе с **_LEFT JOIN_**:*
```sql
-- Запрос для получения всех профилей пользователей и соответствующие им адреса, если они существуют.
SELECT 
    profile.first_name,
    profile.second_name,
    address.street
FROM
    profile
LEFT JOIN
    address
ON
    profile.id = address.profile_id;
```
3. *Напишите 5 запросов с **_WHERE_** с использованием разных операторов, опишите для чего вам в проекте нужна такая выборка данных:*
```sql
-- Получим все активные продукты с кол-вом нуль
SELECT * FROM product
WHERE stock = 0 AND is_active = 1;

-- Все имена начинающиеся на A
SELECT * FROM profile
WHERE first_name LIKE 'A%';

-- Получим всех пользователей, которые родились в 90-ые
SELECT * FROM profile
WHERE birthday BETWEEN '1990-01-01' AND '1999-12-31';

-- Получим всех пользователей, котоыре пользуются Gm@il
SELECT * FROM profile
WHERE email REGEXP 'gmail';

-- Получим все продукты из категорий 1, 5, 7, 9
SELECT * FROM product
WHERE category_id IN (1, 5, 7, 9);
```