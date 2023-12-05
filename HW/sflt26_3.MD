# Домашнее задание к занятию "`Резервное копирование`" - `Исаенков Евгений`

---

### Задание 1

- Составьте команду rsync, которая позволяет создавать зеркальную копию домашней директории пользователя в директорию /tmp/backup
- Необходимо исключить из синхронизации все директории, начинающиеся с точки (скрытые)
- Необходимо сделать так, чтобы rsync подсчитывал хэш-суммы для всех файлов, даже если их время модификации и размер идентичны в источнике и приемнике.
- На проверку направить скриншот с командой и результатом ее выполнения

```bash
rsync -av --delete --checksum --exclude '.*' ~/ /tmp/backup

-a - режим архива, включающий рекурсию и сохранение метаданных.
-v - подробный вывод для отслеживания процесса.
--delete - удаление лишних файлов в приемнике.
--checksum - вычисление хэш-сумм для всех файлов.
--exclude '.*' - исключение скрытых файлов и директорий.
~/ - исходная директория (домашняя директория пользователя).
/tmp/backup - целевая директория.
```

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_1.png?raw=true)
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_2.png?raw=true)

---
### Задание 2

- Написать скрипт и настроить задачу на регулярное резервное копирование домашней директории пользователя с помощью rsync и cron.
- Резервная копия должна быть полностью зеркальной
- Резервная копия должна создаваться раз в день, в системном логе должна появляться запись об успешном или неуспешном выполнении операции
- Резервная копия размещается локально, в директории /tmp/backup
- На проверку направить файл crontab и скриншот с результатом работы утилиты.


```bash
#!/bin/bash

# Путь к директории пользователя
SOURCE_DIR=~/ 

# Путь к директории для резервных копий
BACKUP_DIR=/tmp/backup

# Лог-файл
LOG_FILE=/var/log/backup.log

# Выполнение резервного копирования
rsync -av --delete --checksum $SOURCE_DIR $BACKUP_DIR >> $LOG_FILE 2>&1

# Проверка успешности выполнения
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $(date)" >> $LOG_FILE
else
  echo "Backup failed: $(date)" >> $LOG_FILE
fi
```

![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_3.png?raw=true)
![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_4.png?raw=true)

---
## Дополнительные задания (со звездочкой*)
---
Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

### Задание 3

- Настройте ограничение на используемую пропускную способность rsync до 1 Мбит/c
- Проверьте настройку, синхронизируя большой файл между двумя серверами
- На проверку направьте команду и результат ее выполнения в виде скриншота

```bash
rsync -av --delete --checksum --exclude '.*' --bwlimit=500 ~/ /tmp/backup


rsync -av --delete --checksum --exclude '.*' --bwlimit=1000 ~/ /tmp/backup
```

![Название скриншота 5](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_5.png?raw=true)
![Название скриншота 8](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_8.png?raw=true)

---
### Задание 4

- Напишите скрипт, который будет производить инкрементное резервное копирование домашней директории пользователя с помощью rsync на другой сервер
- Скрипт должен удалять старые резервные копии (сохранять только последние 5 штук)
- Напишите скрипт управления резервными копиями, в нем можно выбрать резервную копию и данные восстановятся к состоянию на момент создания данной резервной копии.
- На проверку направьте скрипт и скриншоты, демонстрирующие его работу в различных сценариях.


Backup data
```bash
#!/bin/bash

# Пути к директории пользователя и резервной директории
SOURCE_DIR=~/
BACKUP_DIR=/var/www/backup

# Сохраняем только последние 5 резервных копий
find $BACKUP_DIR -name "backup_*" -type d | sort -r | tail -n +5 | xargs rm -rf

# Создаем новую инкрементную резервную копию
TIMESTAMP=$(date +%Y%m%d%H%M%S)
rsync -av --delete --link-dest=$BACKUP_DIR/latest --exclude '.*' $SOURCE_DIR $BACKUP_DIR/backup_$TIMESTAMP

# Обновляем символическую ссылку "latest"
rm -f $BACKUP_DIR/latest
ln -s backup_$TIMESTAMP $BACKUP_DIR/latest
```

Restore the backup
```bash
BACKUP_DIR=/var/www/backup
LATEST_BACKUP=$(readlink $BACKUP_DIR/latest)

rsync -av $BACKUP_DIR/$LATEST_BACKUP/ ~/restore_destination
```

![Название скриншота 6](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_6.png?raw=true)
![Название скриншота 7](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw3_7.png?raw=true)
