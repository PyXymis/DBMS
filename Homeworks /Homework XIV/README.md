# Homework XIV
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Индексы в MySQL

**Цель:**<br>
* *Научимся использовать индексы в MySQL*

**Описание/Пошаговая инструкция выполнения домашнего задания:**
1. Пересматриваем индексы на своем проекте. По необходимости меняем 
2. Сделать полнотекстовый индекс, который ищет по свойствам, названию товара и описанию. 
Если нет аналогичной задачи в проекте - имитируем.
3. explain и результаты выборки без индекса и с индексом.

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
1. При пересмотре индексов невыявленно недостатков, поэтому я реализовал все те же индексы, что использовал в
[PostgreSQL](/Homeworks%20/Homework%20VI/README.md)
```sql
-- Простой индекс
ALTER TABLE delivery.product ADD INDEX idx_product_category(category_id);
-- Частичный индекс ( Where не используется в индексах MySQL )
ALTER TABLE delivery.product ADD INDEX idx_product_title_active(title) WHERE is_active = true;
-- В MySQL необходимо сначала добавить генерируемый столбец
ALTER TABLE delivery.product ADD COLUMN title_active VARCHAR(255) GENERATED ALWAYS AS (CASE WHEN is_active THEN title ELSE NULL END) VIRTUAL;
ALTER TABLE delivery.product ADD INDEX idx_product_title_active(title_active);
-- Многоколоночный индекс
ALTER TABLE delivery.contract ADD INDEX idx_contract_created_payment_done_account_id(created, payment_done);
```
2. Полнотекстовый индекс, который ищет по свойствам, названию товара и описанию:
```sql
ALTER TABLE delivery.product ADD FULLTEXT idx_product_fulltext_complex(title, properties, description);
```
3. Результаты и explaint:
```sql
-- Без использования полнотекстового индекса
MariaDB [delivery]> EXPLAIN SELECT * FROM delivery.product
    -> WHERE title LIKE '%пицца%' OR properties LIKE '%пицца%' OR description LIKE '%пицца%';
+------+-------------+---------+------+---------------+------+---------+------+------+-------------+
| id   | select_type | table   | type | possible_keys | key  | key_len | ref  | rows | Extra       |
+------+-------------+---------+------+---------------+------+---------+------+------+-------------+
|    1 | SIMPLE      | product | ALL  | NULL          | NULL | NULL    | NULL | 20   | Using where |
+------+-------------+---------+------+---------------+------+---------+------+------+-------------+
1 row in set (0,001 sec)
    
-- С использованием полнотекстового индекса
MariaDB [delivery]> EXPLAIN SELECT * FROM delivery.product WHERE MATCH(title, properties, description) AGAINST('пицца');
+------+-------------+---------+----------+------------------------------+------------------------------+---------+------+------+-------------+
| id   | select_type | table   | type     | possible_keys                | key                          | key_len | ref  | rows | Extra       |
+------+-------------+---------+----------+------------------------------+------------------------------+---------+------+------+-------------+
|    1 | SIMPLE      | product | fulltext | idx_product_fulltext_complex | idx_product_fulltext_complex | 0       |      | 1    | Using where |
+------+-------------+---------+----------+------------------------------+------------------------------+---------+------+------+-------------+
1 row in set (0,000 sec)
```