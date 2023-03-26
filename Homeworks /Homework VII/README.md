# Homework VI
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Индексы PostgreSQL

**Цель:**<br>
* *Научиться использовать функцию LAG и CTE*

**Описание/Пошаговая инструкция выполнения домашнего задания:**
1. *Создайте таблицу и наполните ее данными*
2. *Заполните таблицу данными*
3. *Написать запрос суммы очков с группировкой и сортировкой по годам*
4. *Написать cte показывающее тоже самое*
5. *Используя функцию LAG вывести кол-во очков по всем игрокам за текущий код и за предыдущий*

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)

# Solution
### - SQL Запрос суммы очков с группировкой и сортировкой по годам
```sql
SELECT year_game, SUM(points) AS total_points FROM statistic
GROUP BY year_game ORDER BY year_game ASC;

 year_game | total_points 
-----------+--------------
      2018 |        92.00
      2019 |        98.00
      2020 |       110.00
(3 rows)
```

### - SQL запрос уммы очков с группировкой и сортировкой по годам с использованием CTE
```sql
WITH year_totals AS (
  SELECT year_game, SUM(points) AS total_points
  FROM statistic
  GROUP BY year_game
)
SELECT * FROM year_totals ORDER BY year_game;

 year_game | total_points 
-----------+--------------
      2018 |        92.00
      2019 |        98.00
      2020 |       110.00
(3 rows)
```

### - SQL Запрос кол-во очков по всем игрокам за текущий код и за предыдущий используя функцию LAG
```sql
WITH player_points AS (
  SELECT player_name, year_game, points, LAG(points) OVER (PARTITION BY player_name ORDER BY year_game) AS previous_points
  FROM statistic
)
SELECT player_name, year_game, points, previous_points
FROM player_points;

 player_name | year_game | points | previous_points 
-------------+-----------+--------+-----------------
 Jack        |      2018 |  14.00 |                
 Jack        |      2019 |  15.00 |           14.00
 Jack        |      2020 |  18.00 |           15.00
 Jackie      |      2018 |  30.00 |                
 Jackie      |      2019 |  28.00 |           30.00
 Jackie      |      2020 |  29.00 |           28.00
 Jet         |      2018 |  30.00 |                
 Jet         |      2019 |  25.00 |           30.00
 Jet         |      2020 |  27.00 |           25.00
 Luke        |      2019 |  16.00 |                
 Luke        |      2020 |  19.00 |           16.00
 Mike        |      2018 |  18.00 |                
 Mike        |      2019 |  14.00 |           18.00
 Mike        |      2020 |  17.00 |           14.00
(14 rows)
```