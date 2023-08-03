# Homework XI
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Транзацкции, MVCC, ACID

**Цель:**<br>
* *Заполнение своего проекта данными*

**Описание/Пошаговая инструкция выполнения домашнего задания:**
1. Описать пример транзакции из своего проекта с изменением данных в нескольких таблицах. Реализовать в виде хранимой процедуры.
2. Загрузить данные из приложенных в материалах csv. Реализовать следующими путями:
   * LOAD DATA
   * mysqlimport (Задание со *)

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 5 баллов за задание со __*__
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
1. Для выполнения первой части задания нам необходимо:
* Наполнить нашу базу данных данными
```sql
-- Заполнение таблицы профилей 
INSERT INTO profile (first_name, second_name, phone, email, gender, birthday, is_push_allow, is_superuser, is_staff) VALUES 
('Ivan', 'Ivanov', '+71234567890', 'ivanov@gmail.com', 'M', '1980-01-01 00:00:00', 1, 0, 0),
('Petr', 'Petrov', '+72345678901', 'petrov@gmail.com', 'M', '1985-01-01 00:00:00', 1, 0, 0),
('Anna', 'Petrova', '+73456789012', 'petrova@gmail.com', 'F', '1990-01-01 00:00:00', 1, 0, 0),
('Sergey', 'Sergeev', '+74567890123', 'sergeev@gmail.com', 'M', '1995-01-01 00:00:00', 1, 0, 0),
('Maria', 'Ivanova', '+75678901234', 'ivanova@gmail.com', 'F', '2000-01-01 00:00:00', 1, 0, 0);
-- Заполнение таблицы адресов
INSERT INTO address (profile_id, dist, street, house, liter, entrance, is_doorphone_exist, not_call_doorphone, latitude, longitude, geolocation) VALUES 
(1, 'Central', 'Street 1', '1', 1, 1, 1, 0, 10.12, 11.13, '{\"latitude\": 10.12, \"longitude\": 11.13}'),
(2, 'Central', 'Street 2', '2', 2, 2, 1, 0, 20.12, 21.13, '{\"latitude\": 20.12, \"longitude\": 21.13}'),
(3, 'Central', 'Street 3', '3', 3, 3, 1, 0, 30.12, 31.13, '{\"latitude\": 30.12, \"longitude\": 31.13}'),
(4, 'Central', 'Street 4', '4', 4, 4, 1, 0, 40.12, 41.13, '{\"latitude\": 40.12, \"longitude\": 41.13}'),
(5, 'Central', 'Street 5', '5', 5, 5, 1, 0, 50.12, 51.13, '{\"latitude\": 50.12, \"longitude\": 51.13}');
-- Заполнение таблицы категорий
INSERT INTO category (id, is_active, title, updated, created, slug, image) VALUES 
(1, 1, 'Electronics', NOW(), NOW(), 'electronics', 'image1.jpg'),
(2, 1, 'Books', NOW(), NOW(), 'books', 'image2.jpg'),
(3, 1, 'Furniture', NOW(), NOW(), 'furniture', 'image3.jpg'),
(4, 1, 'Clothing', NOW(), NOW(), 'clothing', 'image4.jpg'),
(5, 1, 'Footwear', NOW(), NOW(), 'footwear', 'image5.jpg');
-- Заполнение таблицы продуктов
INSERT INTO product (title, is_active, updated, created, slug, image, category_id, stock) VALUES 
('iPhone', 1, NOW(), NOW(), 'iphone', 'iphone.jpg', 1, 10),
('Samsung', 1, NOW(), NOW(), 'samsung', 'samsung.jpg', 1, 20),
('Table', 1, NOW(), NOW(), 'table', 'table.jpg', 3, 30),
('T-shirt', 1, NOW(), NOW(), 't-shirt', 't-shirt.jpg', 4, 40),
('Sneakers', 1, NOW(), NOW(), 'sneakers', 'sneakers.jpg', 5, 50);
```
* Создать хранимую процедуру, которая будет изменять данные в нескольких таблицах

```sql
DELIMITER //  -- Поехали...
CREATE PROCEDURE SimpleCreateNewOrder(IN profile_id INT, IN address_id INT, IN total DECIMAL(10, 2), IN product_id INT)
BEGIN
    DECLARE new_contract_id INT;
    DECLARE current_stock INT;
    -- Проверяем количество товара на складе
    SELECT stock INTO current_stock FROM product WHERE id = product_id;
    IF current_stock > 0 THEN
        -- Начинаем транзакцию
        START TRANSACTION;
        BEGIN
            -- Создаем новый заказ
            INSERT INTO contract(profile_id, address_id, total, payment_done)
            VALUES(profile_id, address_id, total, 0);
            -- Получаем ID только что созданного заказа
            SET new_contract_id = LAST_INSERT_ID();
            -- Добавляем запись в логи
            INSERT INTO logs(profile_id, log_level, log_message, log_date, operation_type, operation_table)
            VALUES(profile_id, 'INFO', CONCAT('Created new contract with id ', new_contract_id), NOW(), 'INSERT', 'contract');
            -- Уменьшаем количество товара на складе на 1
            UPDATE product SET stock = stock - 1 WHERE id = product_id;
            -- Добавляем запись в логи
            INSERT INTO logs(profile_id, log_level, log_message, log_date, operation_type, operation_table)
            VALUES(profile_id, 'INFO', CONCAT('Decreased stock of product with id ', product_id), NOW(), 'UPDATE', 'product');
        COMMIT;
        END;
    ELSE
        -- Если товара нет в наличии, добавляем запись об этом в логи
        INSERT INTO logs(profile_id, log_level, log_message, log_date, operation_type, operation_table)
        VALUES(profile_id, 'ERROR', CONCAT('Attempted to order product with id ', product_id, ' but it is out of stock'), NOW(), 'UPDATE', 'product');
    END IF;
END//
DELIMITER ;
```
## POW
![image](https://github.com/Futusio/secret-keeper/assets/76515078/aebfd98f-3b39-4959-92a5-42b15d1db566)

2. Для загрузки был выбран файл: **_Bicycles.csv_**. В первую очередь я реализова структуру таблицы в MySQL:
```sql
CREATE TABLE product_import(
    Handle VARCHAR(255),
    Title VARCHAR(255),
    BodyHTML TEXT,
    Vendor VARCHAR(255),
    Type VARCHAR(255),
    Tags TEXT,
    Published VARCHAR(255),
    Option1Name VARCHAR(255),
    Option1Value VARCHAR(255),
    Option2Name VARCHAR(255),
    Option2Value VARCHAR(255),
    Option3Name VARCHAR(255),
    Option3Value VARCHAR(255),
    VariantSKU VARCHAR(255),
    VariantGrams INT,
    VariantInventoryTracker VARCHAR(255),
    VariantInventoryQty INT,
    VariantInventoryPolicy VARCHAR(255),
    VariantFulfillmentService VARCHAR(255),
    VariantPrice DECIMAL(10,2),
    VariantCompareAtPrice DECIMAL(10,2),
    VariantRequiresShipping VARCHAR(255),
    VariantTaxable VARCHAR(255),
    VariantBarcode VARCHAR(255),
    ImageSrc TEXT,
    ImageAltText TEXT,
    GiftCard VARCHAR(255),
    SEOTitle VARCHAR(255),
    SEODescription TEXT,
    GoogleShoppingGoogleProductCategory VARCHAR(255),
    GoogleShoppingGender VARCHAR(255),
    GoogleShoppingAgeGroup VARCHAR(255),
    GoogleShoppingMPN VARCHAR(255),
    GoogleShoppingAdWordsGrouping VARCHAR(255),
    GoogleShoppingAdWordsLabels VARCHAR(255),
    GoogleShoppingCondition VARCHAR(255),
    GoogleShoppingCustomProduct VARCHAR(255),
    GoogleShoppingCustomLabel0 VARCHAR(255),
    GoogleShoppingCustomLabel1 VARCHAR(255),
    GoogleShoppingCustomLabel2 VARCHAR(255),
    GoogleShoppingCustomLabel3 VARCHAR(255),
    GoogleShoppingCustomLabel4 VARCHAR(255),
    VariantImage TEXT,
    VariantWeightUnit VARCHAR(255)
);
```
- После чего я подключился к кластеру и выполнил следующую команду:
```sql
LOAD DATA LOCAL INFILE '/tmp/Bicycles.csv' 
 INTO TABLE product_import 
 FIELDS TERMINATED BY ',' 
 ENCLOSED BY '"' 
 LINES TERMINATED BY '\n' 
 IGNORE 1 ROWS;
```
### POW
![image](https://github.com/Futusio/secret-keeper/assets/76515078/34f35861-a060-402b-b0a8-223998832e0a)
- Для загрузки с помощью **_mysqlimport_** используем следующую команду:
```bash
 mysqlimport \
  --ignore-lines=1 \ 
  --fields-terminated-by=, \
  --fields-enclosed-by='"' \
  --verbose \
  --local \
  -u root -p otus \
  /tmp/product_import.csv  # [!] Важно! Название файла должно совпадать с названием таблицы
```
### POW
![image](https://github.com/Futusio/secret-keeper/assets/76515078/e94cb82a-4cea-4cf8-ae4a-ec0651a94259)