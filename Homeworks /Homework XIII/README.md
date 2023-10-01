# Homework XIII
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### DML: агрегация и сортировка

**Цель:**<br>
* *Научимся создавать ответную выборку*

**Описание/Пошаговая инструкция выполнения домашнего задания:**
1. Группировки с ипользованием CASE, HAVING, ROLLUP, GROUPING() 
2. Для магазина к предыдущему списку продуктов добавить максимальную и минимальную цену и кол-во предложений
3. Сделать выборку показывающую самый дорогой и самый дешевый товар в каждой категории
4. Сделать rollup с количеством товаров по категориям

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution

1. Группировки с ипользованием CASE, HAVING, ROLLUP, GROUPING() 
```sql
-- Comment Out Code
SELECT 
    CASE 
        WHEN price < 50 THEN 'Дешевый'
        WHEN price BETWEEN 50 AND 100 THEN 'Средний'
        ELSE 'Дорогой'
    END AS price_category,
    category_id,
    COUNT(*) as product_count
FROM product
GROUP BY 
    CASE 
        WHEN price < 50 THEN 'Дешевый'
        WHEN price BETWEEN 50 AND 200 THEN 'Средний'
        ELSE 'Дорогой'
    END,
    category_id 
WITH ROLLUP
HAVING product_count > 1 OR category_id IS NULL;
```
![image](https://github.com/PyXymis/DBMS/assets/37443340/1fd25055-871b-47bc-9f3b-5f21021735ae)
2. Для магазина к предыдущему списку продуктов добавить максимальную и минимальную цену и кол-во предложений
```sql
SELECT 
    category_id,
    MAX(price) as max_price,
    MIN(price) as min_price,
    COUNT(*) as product_count
FROM product
WHERE is_active = 1
GROUP BY category_id;
```
![image](https://github.com/PyXymis/DBMS/assets/37443340/ecad7eda-387f-41fb-990f-2cb80434a12f)
3. Сделать выборку показывающую самый дорогой и самый дешевый товар в каждой категории
```sql
WITH MinMaxPrices AS (
    SELECT 
        category_id,
        MAX(price) AS max_price,
        MIN(price) AS min_price
    FROM product
    GROUP BY category_id
)

SELECT 
    p.category_id,
    CASE 
        WHEN p.price = mmp.max_price THEN 'Самый дорогой'
        WHEN p.price = mmp.min_price THEN 'Самый дешевый'
    END AS price_category,
    p.title AS product_name,
    p.price
FROM product AS p
JOIN MinMaxPrices AS mmp ON p.category_id = mmp.category_id
WHERE p.price = mmp.max_price OR p.price = mmp.min_price
ORDER BY p.category_id, p.price DESC;
```
![image](https://github.com/PyXymis/DBMS/assets/37443340/184eb749-722e-42a3-9cf8-803c14801562)
4. Сделать rollup с количеством товаров по категориям
```sql
SELECT category_id, COUNT(*) as product_count
FROM product
GROUP BY category_id WITH ROLLUP;
```
![image](https://github.com/PyXymis/DBMS/assets/37443340/52c4f922-f48d-4824-91eb-5c6bd1da8ef1)