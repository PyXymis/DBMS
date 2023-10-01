# Homework XVII
* **[Homeworks](/README.md)** - *Все домашние задания*
# Assigment
## Домашнее задание
### Восстановить таблицу из бэкапа

**Цель:**<br>
* *В этом ДЗ осваиваем инструмент для резервного копирования и восстановления - xtrabackup. Задача восстановить конкретную таблицу из сжатого и шифрованного бэкапа.*

**Описание/Пошаговая инструкция выполнения домашнего задания:**

* В материалах приложен файл бэкапа backup_des.xbstream.gz.des3 и дамп структуры базы world-db.sql
Бэкап выполнен с помощью команды:
   ```bash
   sudo xtrabackup --backup --stream=xbstream --target-dir=/tmp/backups/xtrabackup/stream| gzip - | openssl des3 -salt -k "password" \ stream/backup_des.xbstream.gz.des3
   ```
* Требуется восстановить таблицу *world.city из бэкапа и выполнить оператор: select count(*) from city where countrycode = 'RUS'; Результат оператора написать в чат с преподавателем.

***Критерии оценки:***
* 9 баллов - задание выполнено, но есть недочеты
* 10 баллов - задание выполнено в полном объеме

[//]: # (# Assessment)
[//]: # (![image]&#40;https://user-images.githubusercontent.com/37443340/227890091-022abddf-40b5-4b30-9026-981c53cc046d.png&#41;)
# Solution
1. Для начала нам необходимо дешифровать и распаковать дамп:
    ```bash
    openssl des3 -d -salt -k "password" -in backup_des.xbstream.gz.des3 | gzip -d > backup.xbstream
    ```
2. После распаковки необходимо восстановить бекап:
    ```bash
    xbstream -x < backup.xbstream -C restore
    ```
3. Т.к. бекап был выполнен в режиме **'--backup'**, необходимо его подготовить:
    ```bash
    xtrabackup --prepare --target-dir=restore 
    ```
   * Результат [xtrabackup.log](/Homeworkds%20/Homework%20XVII/xtrabackup.log)
4. 
   