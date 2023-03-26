# Homework VI
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Индексы PostgreSQL

**Цель:**<br>
* *Знать и уметь применять основные виды индексов PostgreSQL*
* *Построить и анализировать план выполнения запроса*
* *Уметь оптимизировать запросы для с использованием индексов*

**Описание/Пошаговая инструкция выполнения домашнего задания:**

Создать индексы на БД, которые ускорят доступ к данным.<br>
В данном задании тренируются навыки:

* определения узких мест
* написания запросов для создания индекса
* оптимизации

**Необходимо:**

1. Создать индекс к какой-либо из таблиц вашей БД
2. Прислать текстом результат команды explain, в которой используется данный индекс
3. Реализовать индекс для полнотекстового поиска
4. Реализовать индекс на часть таблицы или индекс на поле с функцией
5. Создать индекс на несколько полей
6. Написать комментарии к каждому из индексов
7. Описать что и как делали и с какими проблемами столкнулись

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)

# Solution
### - Create simple index
```sql
-- Before Index
EXPLAIN SELECT * FROM delivery.product WHERE category_id = 1;

                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on product  (cost=0.00..10.62 rows=1 width=1367)
   Filter: (category_id = 1)
                            
-- Create Index
CREATE INDEX idx_product_category ON delivery.product(category_id);

-- With Index
EXPLAIN SELECT * FROM delivery.product WHERE category_id = 1;

                                      QUERY PLAN                                       
---------------------------------------------------------------------------------------
 Index Scan using idx_product_category on product  (cost=0.14..8.16 rows=1 width=1367)
   Index Cond: (category_id = 1)
```
*До создания индекса использовалась операция **Sec Scan**, после создания индекса операция была заменена на **Index Scan**. 
Этот индекс может быть полезен для улучшения производительности поиска по категории товара*

### - Create index for fulltext search
```sql
-- Without Index
EXPLAIN SELECT * FROM delivery.product
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'пицца');
                                    QUERY PLAN                                     
-----------------------------------------------------------------------------------
 Seq Scan on product  (cost=0.00..23.12 rows=1 width=1367)
   Filter: (to_tsvector('russian'::regconfig, description) @@ '''пицц'''::tsquery)

-- Create Index
CREATE INDEX idx_product_fulltext ON delivery.product USING GIN (to_tsvector('russian',description));

-- With Index
EXPLAIN SELECT * FROM delivery.product
WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'пицца');
                                         QUERY PLAN                                          
---------------------------------------------------------------------------------------------
 Bitmap Heap Scan on product  (cost=8.00..12.26 rows=1 width=1367)
   Recheck Cond: (to_tsvector('russian'::regconfig, description) @@ '''пицц'''::tsquery)
   ->  Bitmap Index Scan on product_description_idx  (cost=0.00..8.00 rows=1 width=0)
         Index Cond: (to_tsvector('russian'::regconfig, description) @@ '''пицц'''::tsquery)
```
*Результаты выполнения запросов с индексом будут использовать оператор Bitmap Index Scan и Bitmap Heap Scan. 
Этот индекс может быть полезен для улучшения производительности поиска по описанию товара*

### - Create partial index
```sql
-- Without Index
EXPLAIN SELECT title FROM delivery.product WHERE title ='pizza' AND is_active=TRUE;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on product  (cost=0.00..10.62 rows=1 width=516)
   Filter: (is_active AND ((title)::text = 'pizza'::text))
(2 строки)
                            
-- Create Index
CREATE INDEX idx_product_title_active ON delivery.product (title) WHERE is_active = true;

-- With Index
EXPLAIN SELECT title FROM delivery.product WHERE title ='pizza' AND is_active=TRUE;
                                          QUERY PLAN                                           
-----------------------------------------------------------------------------------------------
 Index Only Scan using idx_product_title_active on product  (cost=0.12..8.14 rows=1 width=516)
   Index Cond: (title = 'pizza'::text)
```
*Индекс позволяет оптимизировать поиск по полю title для активных продуктов, для использования индекса на часть таблицы
используется WHERE.*

### - Create Multicolumn Indexes
```sql
-- Without Index
EXPLAIN SELECT * FROM delivery.contract WHERE created BETWEEN '2023-01-01' AND '2023-04-30' AND payment_done = TRUE;
                                                                            QUERY PLAN                                                                            
------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Seq Scan on contract  (cost=0.00..11.20 rows=1 width=926)
   Filter: (payment_done AND (created >= '2023-01-01 00:00:00'::timestamp without time zone) AND (created <= '2023-04-30 00:00:00'::timestamp without time zone))

-- Create Index
CREATE INDEX idx_contract_created_payment_done_account_id ON delivery.contract (created, payment_done);

-- With Index
EXPLAIN SELECT * FROM delivery.contract WHERE created BETWEEN '2023-04-19' AND '2023-04-20' AND payment_done = TRUE;                                                                                
                                                                                  QUERY PLAN                                                                                   
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Index Scan using idx_contract_created_payment_done_account_id on contract  (cost=0.14..8.16 rows=1 width=926)
   Index Cond: ((created >= '2023-19-20 00:00:00'::timestamp without time zone) AND (created <= '2023-04-20 00:00:00'::timestamp without time zone) AND (payment_done = true))
```
*Данный индекс создан на полях created и payment_done таблицы delivery.contract. Такой индекс позволяет ускорить выборку данных из таблицы для запроса оплаченных заказов за определенный период*