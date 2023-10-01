# Homework XV
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Хранимые процедуры и триггеры

**Цель:**<br>
* *Научиться создавать пользователей, процедуры и триггеры*

**Описание/Пошаговая инструкция выполнения домашнего задания:**

1. Создать пользователей client, manager.
2. Создать процедуру выборки товаров с использованием различных фильтров: категория, цена, производитель, различные дополнительные параметры. 
Также в качестве параметров передавать по какому полю сортировать выборку, и параметры постраничной выдачи
   * Права дать пользователю client
3. Создать процедуру **get_orders** - которая позволяет просматривать отчет по продажам за определенный период (час, день, неделя)
с различными уровнями группировки (по товару, по категории, по производителю)
   * Права дать пользователю manager

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
1. Создадим пользователей client, manager:
```sql
CREATE USER 'client'@'localhost' IDENTIFIED BY '12345678';
CREATE USER 'manager'@'localhost' IDENTIFIED BY '87654321';
```
2. Создадим процедуру выборки товаров с использованием различных фильтров:
```sql
DELIMITER //

CREATE PROCEDURE filter_products(
    IN category_id INT, 
    IN min_price DECIMAL(10, 2), 
    IN max_price DECIMAL(10, 2), 
    IN properties VARCHAR(256), 
    IN sortByField VARCHAR(256), 
    IN sortOrder VARCHAR(4), 
    IN startOffset INT, 
    IN rowCount INT
)
BEGIN
    SET @query = CONCAT("SELECT * FROM product WHERE 1 = 1 ",
                        IF(category_id IS NOT NULL, CONCAT("AND category_id = ", category_id, " "), ""),
                        IF(min_price IS NOT NULL, CONCAT("AND price >= ", min_price, " "), ""),
                        IF(max_price IS NOT NULL, CONCAT("AND price <= ", max_price, " "), ""),
                        IF(properties IS NOT NULL, CONCAT("AND properties LIKE '%", properties, "%' "), ""),
                        "ORDER BY ", sortByField, " ", sortOrder, 
                        " LIMIT ", startOffset, ", ", rowCount);

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER
-- Дадим права пользователю client
 GRANT EXECUTE ON PROCEDURE delivery.filter_products TO 'client'@'localhost';
```
* Протестируем нашу процедуру:
```sql
-- Выборка всех электронных товаров, отсортированных по цене в порядке возрастания с ограничением в 5 записей:
MariaDB [delivery]> CALL filter_products(1, NULL, NULL, NULL, 'price', 'ASC', 0, 5);
+----+-----------+-----------+---------------------+---------------------+-----------+-------------+--------------+-------------+-------+---------+------------+
| id | title     | is_active | updated             | created             | slug      | description | image        | category_id | stock | price   | properties |
+----+-----------+-----------+---------------------+---------------------+-----------+-------------+--------------+-------------+-------+---------+------------+
|  1 | iPad      |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | ipad      | NULL        | ipad.jpg     |           1 |    15 |  499.99 | NULL       |
|  3 | Sony TV   |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | sony-tv   | NULL        | sonytv.jpg   |           1 |    12 |  699.99 | NULL       |
|  4 | HP Laptop |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | hp-laptop | NULL        | hplaptop.jpg |           1 |     8 |  899.99 | NULL       |
|  2 | Macbook   |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | macbook   | NULL        | macbook.jpg  |           1 |    10 | 1299.99 | NULL       |
+----+-----------+-----------+---------------------+---------------------+-----------+-------------+--------------+-------------+-------+---------+------------+
4 rows in set (0,001 sec)
    
Query OK, 0 rows affected (0,002 sec)
    
-- Выборка всех книг с ценой ниже 20, отсортированных по цене в порядке убывания с ограничением в 3 записи:
MariaDB [delivery]> CALL filter_products(2, NULL, 20, NULL, 'price', 'DESC', 0, 3);
+----+-----------------+-----------+---------------------+---------------------+------------+-------------+----------------+-------------+-------+-------+------------+
| id | title           | is_active | updated             | created             | slug       | description | image          | category_id | stock | price | properties |
+----+-----------------+-----------+---------------------+---------------------+------------+-------------+----------------+-------------+-------+-------+------------+
|  7 | Historical Book |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | historical | NULL        | historical.jpg |           2 |    40 | 19.99 | NULL       |
|  6 | Sci-Fi Book     |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | sci-fi     | NULL        | scifi.jpg      |           2 |    50 | 15.99 | NULL       |
|  8 | Romance Book    |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | romance    | NULL        | romance.jpg    |           2 |    45 |  9.99 | NULL       |
+----+-----------------+-----------+---------------------+---------------------+------------+-------------+----------------+-------------+-------+-------+------------+
3 rows in set (0,001 sec)
    
Query OK, 0 rows affected (0,001 sec)
    
-- Выборка всех товаров для дома, начиная со второго по порядку и дальше, ограничено 3 записями, отсортированных по названию товара в алфавитном порядке:
MariaDB [delivery]> CALL filter_products(3, NULL, NULL, NULL, 'title', 'ASC', 1, 3);
+----+-------+-----------+---------------------+---------------------+------+-------------+----------+-------------+-------+--------+------------+
| id | title | is_active | updated             | created             | slug | description | image    | category_id | stock | price  | properties |
+----+-------+-----------+---------------------+---------------------+------+-------------+----------+-------------+-------+--------+------------+
|  9 | Sofa  |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | sofa | NULL        | sofa.jpg |           3 |    20 | 399.99 | NULL       |
+----+-------+-----------+---------------------+---------------------+------+-------------+----------+-------------+-------+--------+------------+
1 row in set (0,001 sec)
    
Query OK, 0 rows affected (0,001 sec)

-- Выборка всех одежды в диапазоне цен от 40 до 80, отсортированных по названию в обратном алфавитном порядке с ограничением в 4 записи:
MariaDB [delivery]> CALL filter_products(4, 40, 80, NULL, 'title', 'DESC', 0, 4);
+----+--------+-----------+---------------------+---------------------+--------+-------------+------------+-------------+-------+-------+------------+
| id | title  | is_active | updated             | created             | slug   | description | image      | category_id | stock | price | properties |
+----+--------+-----------+---------------------+---------------------+--------+-------------+------------+-------------+-------+-------+------------+
| 11 | Jeans  |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | jeans  | NULL        | jeans.jpg  |           4 |    60 | 59.99 | NULL       |
| 14 | Jacket |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | jacket | NULL        | jacket.jpg |           4 |    30 | 79.99 | NULL       |
+----+--------+-----------+---------------------+---------------------+--------+-------------+------------+-------------+-------+-------+------------+
2 rows in set (0,001 sec)

Query OK, 0 rows affected (0,001 sec)
    
-- Выборка всех обуви с ограничением на первые 2 записи, отсортированных по цене в порядке убывания:
MariaDB [delivery]> CALL filter_products(5, NULL, NULL, NULL, 'price', 'DESC', 0, 2);
+----+------------+-----------+---------------------+---------------------+------------+-------------+---------------+-------------+-------+-------+------------+
| id | title      | is_active | updated             | created             | slug       | description | image         | category_id | stock | price | properties |
+----+------------+-----------+---------------------+---------------------+------------+-------------+---------------+-------------+-------+-------+------------+
| 15 | Boots      |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | boots      | NULL        | boots.jpg     |           5 |    20 | 99.99 | NULL       |
| 19 | High Heels |         1 | 2023-08-12 17:53:15 | 2023-08-12 17:53:15 | high-heels | NULL        | highheels.jpg |           5 |    25 | 89.99 | NULL       |
+----+------------+-----------+---------------------+---------------------+------------+-------------+---------------+-------------+-------+-------+------------+
2 rows in set (0,001 sec)

Query OK, 0 rows affected (0,001 sec)
```
3. Создание процедуры **get_orders** - которая позволяет просматривать отчет по продажам за определенный период
```sql
DELIMITER //

CREATE PROCEDURE get_orders(IN start_date TIMESTAMP, IN end_date TIMESTAMP, IN grouping_level VARCHAR(20))
BEGIN
    IF grouping_level = 'product' THEN
        SELECT
            p.title AS 'Product',
            SUM(cp.quantity) AS 'Total Quantity Sold',
            SUM(cp.price * cp.quantity) AS 'Total Sales'
        FROM contract c
        JOIN contract_products cp ON c.id = cp.contract_id
        JOIN product p ON cp.product_id = p.id
        WHERE c.created BETWEEN start_date AND end_date
        GROUP BY p.title
        ORDER BY 'Total Sales' DESC;

    ELSEIF grouping_level = 'category' THEN
        SELECT
            cat.title AS 'Category',
            SUM(cp.quantity) AS 'Total Quantity Sold',
            SUM(cp.price * cp.quantity) AS 'Total Sales'
        FROM contract c
        JOIN contract_products cp ON c.id = cp.contract_id
        JOIN product p ON cp.product_id = p.id
        JOIN category cat ON p.category_id = cat.id
        WHERE c.created BETWEEN start_date AND end_date
        GROUP BY cat.title
        ORDER BY 'Total Sales' DESC;

    ELSE
        SELECT 'Error' AS Error;
    END IF;
END //

DELIMITER ;
```
* Протестируем процедуру:
```sql
-- Отчет по продажам за определенный период с группировкой по продукту:
MariaDB [delivery]> CALL get_orders('2023-09-01 00:00:00', '2023-09-07 23:59:59', 'product');
+-----------------+---------------------+-------------+
| Product         | Total Quantity Sold | Total Sales |
+-----------------+---------------------+-------------+
| Macbook         |                   1 |       95.22 |
| Slippers        |                  14 |     1266.26 |
| Historical Book |                   4 |      313.80 |
| iPad            |                  11 |      867.16 |
| Chair           |                   1 |       95.34 |
| Skirt           |                  10 |      710.90 |
| High Heels      |                  18 |     1100.28 |
| Sandals         |                  17 |     1256.90 |
| Sci-Fi Book     |                   2 |      134.88 |
| Running Shoes   |                  23 |      946.16 |
| Sony TV         |                   2 |       95.28 |
+-----------------+---------------------+-------------+
11 rows in set (0,002 sec)

Query OK, 0 rows affected (0,002 sec)
-- Для просмотра отчета с группировкой по категории:
MariaDB [delivery]> CALL get_orders('2023-09-01 00:00:00', '2023-09-07 23:59:59', 'category');
+-------------+---------------------+-------------+
| Category    | Total Quantity Sold | Total Sales |
+-------------+---------------------+-------------+
| Electronics |                  14 |     1057.66 |
| Footwear    |                  72 |     4569.60 |
| Books       |                   6 |      448.68 |
| Furniture   |                   1 |       95.34 |
| Clothing    |                  10 |      710.90 |
+-------------+---------------------+-------------+
5 rows in set (0,001 sec)

Query OK, 0 rows affected (0,001 sec)

```