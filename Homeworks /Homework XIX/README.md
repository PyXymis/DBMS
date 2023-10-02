# Homework XIX
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Строим модель данных

**Цель:**<br>
* *Научиться проектировать БД*

**Описание/Пошаговая инструкция выполнения домашнего задания:**

* **Задача:** Реализовать модель данных БД, определить сущности, построить связи, выполнить декомпозицию и нормализацию
* За основу берем практическую структуру данных с заказчиками интернет магазина (файл some_customers.csv.gz). 
* Текущая структура данных неоптимальна:
  * Нет типизации - почти все поля хранятся как строки
  * Данные не нормализованы - данные о адресе и человеке хранятся в одной таблице, на одного человека может приходится несколько адресов
  * Попытаться выделить следующие сущности:
    * Страны
    * Города
    * Улицы
    * Дома
    * И другие которые посчитаете нужными

* Описанные сущности не являются полным и конечным ТЗ (как это и бывает в жизни). Вы как архитектор должны предусмотреть необходимые атрибуты и дополнительные сущности по необходимости. И четко представлять бизнес-задачу которую будет решать эта структура данных.
делаем декомпозицию и нормализацию
* В качестве сделанной ДЗ принимается pdf с начальной и конечной моделью
* Решая данное ДЗ вы тренируете навык проектирования БД, выделения сущностей и их атрибутов, построения связей, нормализации данных

_Задание со *_
* плюс 10 баллов загрузить данные из CSV в вашу модель
* плюс 3 балла за развернутый кластер innodb с роутером и проверкой работоспособности

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены
* плюс 10 баллов данные из CSV загружены в БД
* плюс 3 балла за каждый развернутый кластер: innoDB, XtraDB, NDB

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
1. На основне представленных в CSV файле данных я выделяю несколько сущностей:
   * Сущности:
      * People: person_id (PK), title, first_name, last_name, birth_date, gender, marital_status, correspondence_language
      * Countries: country_id (PK), country_name
      * Cities: city_id (PK), country_id (FK), city_name, region
      * Streets: street_id (PK), city_id (FK), street_name
      * Houses: house_id (PK), street_id (FK), building_number, postal_code
     * Addresses: address_id (PK), house_id (FK), person_id (FK)
   * Связи:
     * People и Addresses: Один ко многим (один человек может иметь много адресов)
     * Countries и Cities: Один ко многим (одна страна может иметь много городов)
     * Cities и Streets: Один ко многим (один город может иметь много улиц)
     * Streets и Houses: Один ко многим (одна улица может иметь много домов)
     * Houses и Addresses: Один ко многим (один дом может иметь много адресов)
* Изначальная структура БД:
![image](https://github.com/PyXymis/DBMS/assets/37443340/57d28d8e-a25f-407a-9f8b-80a6f92653b5)
* Декомпозированная и нормализированная структура БД: (_Для визуалиации использовался **dbdiagram.io**_)
![image](https://github.com/PyXymis/DBMS/assets/37443340/9ae6c543-d5c1-4acb-b250-7ea0a2b70c61)
2. Для наполнения данными БД мы создадим временную таблицу с структурой изначальной БД, загрузим в нее CSV файл и уже оттуда будем вставлять данные в декомпозированные таблицы:
    ```sql
    CREATE TEMPORARY TABLE TempImport (
        title VARCHAR(50),
        first_name VARCHAR(255),
        last_name VARCHAR(255),
        correspondence_language VARCHAR(50),
        birth_date DATE,
        gender ENUM('Male', 'Female', 'Other', 'Unknown'),
        marital_status ENUM('Single', 'Married', 'Divorced', 'Widowed', ''),
        country_code VARCHAR(10),
        postal_code VARCHAR(10),
        region VARCHAR(255),
        city VARCHAR(255),
        street VARCHAR(255),
        building_number VARCHAR(255)
    );
    
    LOAD DATA LOCAL INFILE 'customers.csv'
    INTO TABLE TempImport
    FIELDS TERMINATED BY ',' 
    ENCLOSED BY '"' 
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    
    -- Вставка стран
    INSERT INTO Countries (country_name)
    SELECT DISTINCT country_code
    FROM TempImport
    WHERE country_code IS NOT NULL AND country_code != ''
    ON DUPLICATE KEY UPDATE country_name = country_name;
    
    -- Вставка городов
    INSERT INTO Cities (country_id, city_name, region)
    SELECT c.country_id, t.city, t.region
    FROM TempImport t
    JOIN Countries c ON t.country_code = c.country_name
    WHERE t.city IS NOT NULL AND t.city != ''
    ON DUPLICATE KEY UPDATE city_name = city_name;
    
    -- Вставка улиц
    INSERT INTO Streets (city_id, street_name)
    SELECT ci.city_id, t.street
    FROM TempImport t
    JOIN Cities ci ON t.city = ci.city_name
    WHERE t.street IS NOT NULL AND t.street != ''
    ON DUPLICATE KEY UPDATE street_name = street_name;
    
    -- Вставка домов
    INSERT INTO Houses (street_id, building_number, postal_code)
    SELECT s.street_id, t.building_number, t.postal_code
    FROM TempImport t
    JOIN Streets s ON t.street = s.street_name
    WHERE t.building_number IS NOT NULL AND t.building_number != ''
    ON DUPLICATE KEY UPDATE building_number = building_number;
    
    -- Вставка людей
    INSERT INTO People (title, first_name, last_name, birth_date, gender, marital_status, correspondence_language)
    SELECT title, first_name, last_name, birth_date, gender, marital_status, correspondence_language
    FROM TempImport;
    
    -- Вставка адресов
    INSERT INTO Addresses (house_id, person_id)
    SELECT h.house_id, p.person_id
    FROM TempImport t
    JOIN People p ON t.first_name = p.first_name AND t.last_name = p.last_name
    JOIN Streets s ON t.street = s.street_name
    JOIN Houses h ON t.building_number = h.building_number AND h.street_id = s.street_id;
    
    -- Удаление временной таблицы
    DROP TABLE TempImport;
    ```
* После чего выполним запрос для получения кол-ва строк в каждой таблице:
  ```sql
  MariaDB [mydb]> SELECT table_name AS `Table`, table_rows AS `Number of Rows` FROM information_schema.TABLES WHERE table_schema = 'otus';
  +-----------+----------------+
  | Table     | Number of Rows |
  +-----------+----------------+
  | People    |            835 |
  | Cities    |           1084 |
  | Streets   |           2542 |
  | Houses    |           1481 |
  | Addresses |            941 |
  | Countries |             21 |
  +-----------+----------------+
  6 rows in set (0,000 sec)
  
  MariaDB [mydb]> 
  ```