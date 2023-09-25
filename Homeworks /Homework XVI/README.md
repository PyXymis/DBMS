# Homework XVI
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Анализ и профилирование запроса

**Цель:**<br>
* *Проанализировать план выполнения запроса, заценить на чем теряется время*

**Описание/Пошаговая инструкция выполнения домашнего задания:**

* Возьмите сложную выборку из предыдущих ДЗ с несколькими join и подзапросами
* постройте EXPLAIN в 3 формата
* оцените план прохождения запроса, найдите самые тяжелые места
 
**Задание со * :**
* попробуйте оптимизировать запрос (можно использовать индексы, хинты, сбор статистики, гистограммы)
все действия и результаты опишите в __README.md__

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 5 баллов за задание со *
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
1. Для выполнения задания используется запрос из второго пункта задания _№ 13_: 
    * **[Homework XIII](/Homeworks%20/Homework%20XIII/README.md)** - *DML: агрегация и сортировка*
   ```sql
      -- 3. Сделать выборку показывающую самый дорогой и самый дешевый товар в каждой категории
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
* Результат *__explain__* для этого запроса:
    ```sql
    +------+-------------+------------+------+---------------+------+---------+------------------------+------+---------------------------------+
    | id   | select_type | table      | type | possible_keys | key  | key_len | ref                    | rows | Extra                           |
    +------+-------------+------------+------+---------------+------+---------+------------------------+------+---------------------------------+
    |    1 | PRIMARY     | p          | ALL  | category_id   | NULL | NULL    | NULL                   | 20   | Using where; Using filesort     |
    |    1 | PRIMARY     | <derived2> | ref  | key0          | key0 | 5       | delivery.p.category_id | 2    | Using where                     |
    |    2 | DERIVED     | product    | ALL  | category_id   | NULL | NULL    | NULL                   | 20   | Using temporary; Using filesort |
    +------+-------------+------------+------+---------------+------+---------+------------------------+------+---------------------------------+
    3 rows in set (0,001 sec)
    ```
* Результат [Explain JSON](/Homeworkds%20/Homework%20XVI/explain.json)
* Результат в формате XML сгенерировать не получилось из-за использования **mariaDB**
---

* type: ALL для таблицы product (в обоих случаях) указывает на полный скан таблицы. Это дорогостоящая операция, особенно если у вас будет много данных.
* Using temporary - Using filesort в DERIVED запросе говорит о том, что MySQL создает временную таблицу для хранения промежуточных результатов и затем сортирует её. Это также может замедлить выполнение запроса.
* Для решения этой проблемы можно разбить запрос на два подзапроса и использовать их без CTE
    ```sql
    -- Сначала найдем товары с минимальной ценой в каждой категории
    (SELECT 
        p.category_id,
        'Самый дешевый' AS price_category,
        p.title AS product_name,
        p.price
    FROM product AS p
    JOIN (
         SELECT 
             category_id,
             MIN(price) AS min_price
         FROM product
         GROUP BY category_id
    ) AS mp ON p.category_id = mp.category_id
    WHERE p.price = mp.min_price)
    
    UNION ALL
    
    -- Затем найдем товары с максимальной ценой в каждой категории
    (SELECT 
        p.category_id,
        'Самый дорогой' AS price_category,
        p.title AS product_name,
        p.price
    FROM product AS p
    JOIN (
         SELECT 
             category_id,
             MAX(price) AS max_price
         FROM product
         GROUP BY category_id
    ) AS mp ON p.category_id = mp.category_id
    WHERE p.price = mp.max_price)
    
    ORDER BY category_id, price DESC;
    ```
* И Добавим индекс:

    ```sql
      ALTER TABLE product ADD INDEX idx_category_id (category_id);
  ````
* Explain: 
    ```sql
    +------+--------------+------------+-------+------------------------------------+--------------------+---------+-----------------------------------------+------+-----------------------------------------------------------+
    | id   | select_type  | table      | type  | possible_keys                      | key                | key_len | ref                                     | rows | Extra                                                     |
    +------+--------------+------------+-------+------------------------------------+--------------------+---------+-----------------------------------------+------+-----------------------------------------------------------+
    |    1 | PRIMARY      | p          | ALL   | idx_category_price,idx_category_id | NULL               | NULL    | NULL                                    | 20   | Using where                                               |
    |    1 | PRIMARY      | <derived2> | ref   | key0                               | key0               | 11      | delivery.p.category_id,delivery.p.price | 1    |                                                           |
    |    2 | DERIVED      | product    | range | idx_category_price,idx_category_id | idx_category_price | 11      | NULL                                    | 6    | Using index for group-by; Using temporary; Using filesort |
    |    3 | UNION        | p          | ALL   | idx_category_price,idx_category_id | NULL               | NULL    | NULL                                    | 20   | Using where                                               |
    |    3 | UNION        | <derived4> | ref   | key0                               | key0               | 11      | delivery.p.category_id,delivery.p.price | 1    |                                                           |
    |    4 | DERIVED      | product    | range | idx_category_price,idx_category_id | idx_category_price | 5       | NULL                                    | 6    | Using index for group-by; Using temporary; Using filesort |
    | NULL | UNION RESULT | <union1,3> | ALL   | NULL                               | NULL               | NULL    | NULL                                    | NULL | Using filesort                                            |
    +------+--------------+------------+-------+------------------------------------+--------------------+---------+-----------------------------------------+------+-----------------------------------------------------------+
    7 rows in set (0,001 sec)
    ```
* id = 1 и 3: Это основные запросы, где происходит выборка из таблицы product с псевдонимом p. Они выполняют полный скан (type: ALL), что может быть неэффективным для больших таблиц, но в вашем случае это 20 строк, поэтому это не так критично. 
* id = 2 и 4: Это подзапросы, где вычисляются минимальная и максимальная цена для каждой категории. Здесь используется type: range с индексом idx_category_price. MySQL эффективно группирует данные по category_id с помощью этого индекса. Тем не менее, здесь по-прежнему есть временные таблицы и сортировка (Using temporary; Using filesort), что может замедлить выполнение на больших наборах данных. 
* UNION RESULT: Это результат объединения двух запросов. MySQL использует файловую сортировку для объединения результатов.



