# Homework VIII
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Репликация

**Цель:**<br>
* *Делаем физическую и логическую репликации*

**Описание/Пошаговая инструкция выполнения домашнего задания:**
* Физическая репликация:
  * *Настроить физическую репликации между двумя кластерами базы данных*
  * *Репликация должна работать использую "слот репликации"*
  * *Реплика должна отставать от мастера на 5 минут*
* Логическая репликация: 
  * *Создать на первом кластере базу данных, таблицу и наполнить ее данными (на ваше усмотрение)*
  * *На нем же создать публикацию этой таблицы*
  * *На новом кластере подписаться на эту публикацию*
  * *Убедиться что она среплицировалась. Добавить записи в эту таблицу на основном сервере и убедиться, что они видны на логической реплике*

***Критерии оценки:***
* Выполнение ДЗ: 10 баллов
* плюс 2 балла за красивое решение
* минус 2 балла за рабочее решение, и недостатки указанные преподавателем не устранены

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
## Физическая репликация
- Для выполнения ДЗ нам необходимо создать 2 кластера БД. Удалить содержимое кластера Slave и сделать в него базовый бекап master. 
Предварительно, нам необходимо на мастере создать пользователя с ролью **REPLICATION** и слот репликации: 
```sql
CREATE ROLE replicator WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT REPLICATION CONNECTION LIMIT -1 PASSWORD 'Qwerty123';
SELECT pg_create_physical_replication_slot('otus_slot');
```
- Так же на мастере нам необходимо включить **wal_level = replica** и **max_wal_senders = 3**.
- Далее переносим backup кластера master на slave и запускаем его 
```shell
pg_basebackup -h localhost -p 5433 -D otus-slave -U replicator --write-recovery-conf --progress --verbose
```
- После этого запуская slave,активируем слот-репликации и проверяем работоспособность репликации
```sql
ALTER SYSTEM SET primary_conninfo TO 'host=localhost port=5433 user=replicator password=1q2w3e4r';
SELECT pg_reload_conf();
```
### PoW
![image](https://github.com/PyXymis/DBMS/assets/37443340/9ba62ea3-692a-412c-bc28-a0e8bf407152)

## Логическая репликация
- Для логической репликации мы переключаем **wal_level = logical** на Master
- Далее нам необходимо создать БД, таблицу и наполнить ее данными прежде, чем делать basebackup. После этих шагов нам необходимо выполнить следующее:
```sql
CREATE PUBLICATION pub FOR TABLE somename;
```
- После чего для подписки на публикации мы выполняем команду на Logical Slave:
```sql
CREATE SUBSCRIPTION mysub CONNECTION 
'host=localhiost port=5433 user=replicator password=1q2w3e4r dbname=otus'
PUBLICATION pub;
```
### PoW
![image](https://github.com/PyXymis/DBMS/assets/37443340/64aec173-a5a8-447d-89d0-a7891b7b7130)