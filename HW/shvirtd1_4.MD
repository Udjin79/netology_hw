# Домашнее задание к занятию "`Оркестрация группой Docker контейнеров на примере Docker Compose`" - `Исаенков Евгений`
   
### Задание 0

1. Убедитесь что у вас НЕ(!) установлен ```docker-compose```, для этого получите следующую ошибку от команды ```docker-compose --version```
```
Command 'docker-compose' not found, but can be installed with:

sudo snap install docker          # version 24.0.5, or
sudo apt  install docker-compose  # version 1.25.0-1

See 'snap info docker' for additional versions.
```
В случае наличия установленного в системе ```docker-compose``` - удалите его.  
2. Убедитесь что у вас УСТАНОВЛЕН ```docker compose```(без тире) версии не менее v2.24.X, для это выполните команду ```docker compose version```  

### Ответ

```bash
$ docker compose version
Docker Compose version v2.27.1-desktop.1
```

---

### Задание 1

1. Сделайте в своем github пространстве fork репозитория ```https://github.com/netology-code/shvirtd-example-python/blob/main/README.md```.   
2. Создайте файл с именем ```Dockerfile.python``` для сборки данного проекта(для 3 задания изучите https://docs.docker.com/compose/compose-file/build/ ). Используйте базовый образ ```python:3.9-slim```. Протестируйте корректность сборки. Не забудьте dockerignore. 
3. (Необязательная часть, *) Изучите инструкцию в проекте и запустите web-приложение без использования docker в venv. (Mysql БД можно запустить в docker run).
4. (Необязательная часть, *) По образцу предоставленного python кода внесите в него исправление для управления названием используемой таблицы через ENV переменную.

### Ответ

Устанавливаю и запускаю MySQL с необходимыми реквизитами доступа. Создаю общую сеть.

```bash
$ docker pull mysql:latest

$ docker network create my-network
1de9aa84e8fd0da665752f78c36b0b120132a3d447017ccffb2ff7c13f6464c8

$ docker run --name mysql-db --network my-network -e MYSQL_ROOT_PASSWORD=****** -e MYSQL_DATABASE=virtd -e MYSQL_USER=app -e MYSQL_PASSWORD==****** -p 3306:3306 -d mysql:8
912049e9ab909b5d468442771a2860ffdf863e0b2262df2830c4a346ab3d473d
```

Параметр DB_HOST задаю в виде переменной в Dockefile приложения, т.к. в настройках приложения видно, что параметры подключения к БД берутся из переменых окружения

```Dockerfile
FROM python:3.9-slim

# Set environment variables
ENV DB_HOST=mysql-db
ENV DB_USER=app
ENV DB_PASSWORD==******
ENV DB_NAME=virtd

WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "main.py"]
```

Создаю образ и запускаю приложение. 

```bash
$ docker build -f Dockerfile.python -t docker_practice .
[+] Building 20.7s (9/9) FINISHED                                                                                                                                                                                 

$ docker run --name my-app --network my-network -p 5000:5000 -d docker_practice
1214e8f577cbaaf724e2b2c039b0207f862a44e930dabab85842b4bc2ff40382
```

Список контейнеров

```bash
$ $ docker ps -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED          STATUS                        PORTS                                                 NAMES
e53429827745   docker_practice               "python main.py"         10 minutes ago   Up 10 minutes                 0.0.0.0:5000->5000/tcp                                my-app
912049e9ab90   mysql:latest                  "docker-entrypoint.s…"   19 minutes ago   Up 19 minutes                 0.0.0.0:3306->3306/tcp, 33060/tcp                     mysql-db
```

Проверяю, что оно успешно подключилось к DB и работает

```bash
$ curl localhost:5000
TIME: 2024-07-14 10:36:04, IP: None
```

Проверяю, что корректно работает файл .dockerignore

```bash
$ $ cat .dockerignore
.venv
venv
.git
```

Сравниваю локальную папку и папку в контейнере. Видим, что папки venv в контейнере нет, соответственно файл работает.
```bash
$ $ ls
Dockerfile.python  LICENSE  README.md  haproxy  main.py  nginx  proxy.yaml  requirements.txt  schema.pdf  venv
$ $ docker exec -it my-app bash
root@e53429827745:/app# ls
Dockerfile.python  LICENSE  README.md  haproxy  main.py  nginx  proxy.yaml  requirements.txt  schema.pdf
```

---

### Задание 2

1. Создайте в yandex cloud container registry с именем "test" с помощью "yc tool" . [Инструкция](https://cloud.yandex.ru/ru/docs/container-registry/quickstart/?from=int-console-help)
2. Настройте аутентификацию вашего локального docker в yandex container registry.
3. Соберите и залейте в него образ с python приложением из задания №1.
4. Просканируйте образ на уязвимости.
5. В качестве ответа приложите отчет сканирования.

### Ответ

1
```bash
$ yc container registry create --name netology
done (2s)
id: ******
folder_id: ******
name: netology
status: ACTIVE
created_at: "2024-07-14T10:53:56.581Z"
```

2
```bash
$ yc container registry configure-docker
docker configured to use yc --profile "default" for authenticating "cr.yandex" container registries
Credential helper is configured in 'C:\Users\******\.docker\config.json'
```

3
```bash
$ docker push cr.yandex/******/docker_practice:latest
The push refers to repository [cr.yandex/******/docker_practice]
3e632a989042: Pushed
d36514e3f793: Pushed
40b0149d0811: Pushed
a58d16c447ed: Pushed
b88d8bda5e53: Pushed
8cddf1d30fbd: Pushed
b9fc95825e61: Pushed
32148f9f6c5a: Pushed
latest: digest: sha256:a8f38faf19e237f30fce3600a85461c6ee0a75b1688a6e8a12ce2c5847ea0fa3 size: 1997

$ yc container image list
+----------------------+---------------------+--------------------------------------+--------+-----------------+
|          ID          |       CREATED       |                 NAME                 |  TAGS  | COMPRESSED SIZE |
+----------------------+---------------------+--------------------------------------+--------+-----------------+
| ******               | 2024-07-14 11:06:22 | ******/docker_practice               | latest | 67.7 MB         |
+----------------------+---------------------+--------------------------------------+--------+-----------------+

```

4
```bash
$ yc container image scan ******
done (1m2s)
id: ******
image_id: ******
scanned_at: "2024-07-14T11:11:02.131Z"
status: READY
vulnerabilities:
  critical: "1"
  high: "7"
  medium: "29"
  low: "67"
```

5
```bash
$ yc container image list-scan-results --repository-name=******/docker_practice
+----------------------+----------------------+---------------------+--------+--------------------------------+
|          ID          |        IMAGE         |     SCANNED AT      | STATUS |        VULNERABILITIES         |
+----------------------+----------------------+---------------------+--------+--------------------------------+
| ******               | ******               | 2024-07-14 11:11:02 | READY  | critical:1, high:7, medium:29, |
|                      |                      |                     |        | low:67                         |
| ******               | ******               | 2024-07-14 11:06:43 | READY  | critical:1, high:7, medium:29, |
|                      |                      |                     |        | low:67                         |
+----------------------+----------------------+---------------------+--------+--------------------------------+
```
---

### Задание 3

1. Изучите файл "proxy.yaml"
2. Создайте в репозитории с проектом файл ```compose.yaml```. С помощью директивы "include" подключите к нему файл "proxy.yaml".
3. Опишите в файле ```compose.yaml``` следующие сервисы: 

- ```web```. Образ приложения должен ИЛИ собираться при запуске compose из файла ```Dockerfile.python``` ИЛИ скачиваться из yandex cloud container registry(из задание №2 со *). Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.5```. Сервис должен всегда перезапускаться в случае ошибок.
Передайте необходимые ENV-переменные для подключения к Mysql базе данных по сетевому имени сервиса ```web``` 

- ```db```. image=mysql:8. Контейнер должен работать в bridge-сети с названием ```backend``` и иметь фиксированный ipv4-адрес ```172.20.0.10```. Явно перезапуск сервиса в случае ошибок. Передайте необходимые ENV-переменные для создания: пароля root пользователя, создания базы данных, пользователя и пароля для web-приложения.Обязательно используйте уже существующий .env file для назначения секретных ENV-переменных!

2. Запустите проект локально с помощью docker compose , добейтесь его стабильной работы: команда ```curl -L http://127.0.0.1:8090``` должна возвращать в качестве ответа время и локальный IP-адрес. Если сервисы не стартуют воспользуйтесь командами: ```docker ps -a ``` и ```docker logs <container_name>``` 

5. Подключитесь к БД mysql с помощью команды ```docker exec <имя_контейнера> mysql -uroot -p<пароль root-пользователя>```(обратите внимание что между ключем -u и логином root нет пробела. это важно!!! тоже самое с паролем) . Введите последовательно команды (не забываем в конце символ ; ): ```show databases; use <имя вашей базы данных(по-умолчанию example)>; show tables; SELECT * from requests LIMIT 10;```.

6. Остановите проект. В качестве ответа приложите скриншот sql-запроса.

### Ответ

Порт 8090 у меня занят, поэтому сделал доступ по порту 8091.

```yaml
version: '3.8'

include:
  - proxy.yaml

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.python
    networks:
      backend:
        ipv4_address: 172.20.0.5
    restart: always
    depends_on:
      mysql-db:
        condition: service_healthy
    environment:
      MYSQL_HOST: mysql-db
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}

  mysql-db:
    image: mysql:8
    networks:
      backend:
        ipv4_address: 172.20.0.10
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
```

```bash
C:\Windows\System32>curl http://127.0.0.1:8091/
TIME: 2024-07-14 12:11:04, IP: 172.20.0.2
```

Данные из DB
```bash
sh-5.1# mysql -uroot -p${MYSQL_ROOT_PASSWORD}

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| virtd              |
+--------------------+
5 rows in set (0.01 sec)

mysql> use virtd;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-----------------+
| Tables_in_virtd |
+-----------------+
| requests        |
+-----------------+
1 row in set (0.00 sec)

mysql> SELECT * from requests LIMIT 10;
+----+---------------------+------------+
| id | request_date        | request_ip |
+----+---------------------+------------+
|  1 | 2024-07-14 12:17:36 | 172.20.0.2 |
|  2 | 2024-07-14 12:17:37 | 172.20.0.2 |
|  3 | 2024-07-14 12:17:38 | 172.20.0.2 |
|  4 | 2024-07-14 12:17:38 | 172.20.0.2 |
+----+---------------------+------------+
4 rows in set (0.00 sec)
```

---

### Задание 4

1. Запустите в Yandex Cloud ВМ (вам хватит 2 Гб Ram).
2. Подключитесь к Вм по ssh и установите docker.
3. Напишите bash-скрипт, который скачает ваш fork-репозиторий в каталог /opt и запустит проект целиком.
4. Зайдите на сайт проверки http подключений, например(или аналогичный): ```https://check-host.net/check-http``` и запустите проверку вашего сервиса ```http://<внешний_IP-адрес_вашей_ВМ>:8090```. Таким образом трафик будет направлен в ingress-proxy.
5. (Необязательная часть) Дополнительно настройте remote ssh context к вашему серверу. Отобразите список контекстов и результат удаленного выполнения ```docker ps -a```
6. В качестве ответа повторите  sql-запрос и приложите скриншот с данного сервера, bash-скрипт и ссылку на fork-репозиторий.

### Ответ

```bash
#!/bin/bash

# Базовые переменные
REPO_URL="https://github.com/Udjin79/shvirtd-example-python.git"
INSTALL_DIR="/opt/shvirtd-example-python"

# Клонируем репозиторий
sudo git clone $REPO_URL $INSTALL_DIR

# Переходим в целевую директорию
cd $INSTALL_DIR

# Запускаем сборку образа и запуск контейнеров
sudo docker compose -f compose.yaml up -d

# Ждем запуска сервисов
sleep 60

# Проверяем подключение
curl -L http://127.0.0.1:8090

# Опциональная задача по проверке работы докера
sudo docker context ls
sudo docker ps -a
```

Этапы копирования и запуска
```bash
# Копируем bash скрипт для форка, сборки билдов и запуска сервисов
scp setup_project.sh ******@84.201.173.13:/home/******

# Переходим на ВМ. Запускаем скрипт и собираем сервисы
ssh ******@84.201.173.13
chmod +x /opt/setup_project.sh
sudo /opt/setup_project.sh
```

Результат работы скрипта
```bash
$ ******@fhmqkvcnj6kn1bbdhau5:/opt$ sudo /opt/setup_project.sh
[+] Running 4/4
 ✔ Container shvirtd-example-python-mysql-db-1       Healthy                                                                                                                                                                       0.0s
 ✔ Container shvirtd-example-python-web-1            Running                                                                                                                                                                       0.0s
 ✔ Container shvirtd-example-python-reverse-proxy-1  Running                                                                                                                                                                       0.0s
 ✔ Container shvirtd-example-python-ingress-proxy-1  Running                                                                                                                                                                       0.0s
TIME: 2024-07-14 13:27:20, IP: 172.20.0.2NAME        DESCRIPTION                               DOCKER ENDPOINT               ERROR
default *   Current DOCKER_HOST based configuration   unix:///var/run/docker.sock

CONTAINER ID   IMAGE                        COMMAND                  CREATED         STATUS                   PORTS                      NAMES
a8d9a66a05f1   shvirtd-example-python-web   "python main.py"         4 minutes ago   Up 3 minutes                                        shvirtd-example-python-web-1
d987887208dd   nginx:latest                 "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes                                        shvirtd-example-python-ingress-proxy-1
9a3ff0e2464d   mysql:8                      "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes (healthy)   3306/tcp, 33060/tcp        shvirtd-example-python-mysql-db-1
a46d38613583   haproxy:2.4                  "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes             127.0.0.1:8080->8080/tcp   shvirtd-example-python-reverse-proxy-1
```

Проверка записей в DB
```bash
root@fhmqkvcnj6kn1bbdhau5:/opt# docker exec -it a14d7c24ffb4 bash
bash-5.1# mysql -uroot -p${MYSQL_ROOT_PASSWORD}

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| virtd              |
+--------------------+
5 rows in set (0.06 sec)

mysql> use virtd;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-----------------+
| Tables_in_virtd |
+-----------------+
| requests        |
+-----------------+
1 row in set (0.00 sec)

mysql> SELECT * from requests LIMIT 10;
+----+---------------------+-----------------+
| id | request_date        | request_ip      |
+----+---------------------+-----------------+
|  1 | 2024-07-14 13:50:31 | NULL            |
|  2 | 2024-07-14 13:53:34 | 94.231.205.127  |
|  3 | 2024-07-14 13:53:37 | 94.231.205.127  |
|  4 | 2024-07-14 13:53:38 | 94.231.205.127  |
|  5 | 2024-07-14 13:54:09 | 127.0.0.1       |
|  6 | 2024-07-14 13:54:27 | 195.211.27.85   |
|  7 | 2024-07-14 13:54:27 | 167.235.135.184 |
|  8 | 2024-07-14 13:55:08 | 94.231.205.127  |
|  9 | 2024-07-14 13:55:19 | 94.231.205.127  |
| 10 | 2024-07-14 13:55:20 | 94.231.205.127  |
+----+---------------------+-----------------+
10 rows in set (0.00 sec)
```
---

### Задание 5

1. Напишите и задеплойте на вашу облачную ВМ bash скрипт, который произведет резервное копирование БД mysql в директорию "/opt/backup" с помощью запуска в сети "backend" контейнера из образа ```schnitzler/mysqldump``` при помощи ```docker run ...``` команды. Подсказка: "документация образа."
2. Протестируйте ручной запуск
3. Настройте выполнение скрипта раз в 1 минуту через cron, crontab или systemctl timer. Придумайте способ не светить логин/пароль в git!!
4. Предоставьте скрипт, cron-task и скриншот с несколькими резервными копиями в "/opt/backup"

### Ответ

Для запуска был сделан следующий скрипт. Переменные берутся из .env файла, для того, чтобы данные не хранились в GIT
```bash
#!/bin/bash

# Load environment variables from a .env file
source /opt/shvirtd-example-python/.env

# Set backup directory
BACKUP_DIR="/opt/backup"
mkdir -p $BACKUP_DIR

# Set the current timestamp
TIMESTAMP=$(date +"%F_%T")

# Run mysqldump in a Docker container. Example taken from shnitzler repository
docker run --rm --entrypoint "" \
    -v $BACKUP_DIR:/backup \
    --network=shvirtd-example-python_backend \
    schnitzler/mysqldump \
    mysqldump --opt --host mysql-db -u root -p "${MYSQL_ROOT_PASSWORD}" "--result-file=/backup/db_backup_$TIMESTAMP.sql" virtd
```

После добавления скрипта в крон, каждую минуту генерируется dump с выбранной базой
```bash
root@fhmqkvcnj6kn1bbdhau5:/opt# crontab -l
* * * * * /opt/backup.sh

root@fhmqkvcnj6kn1bbdhau5:/opt# ls /opt/backup
db_backup_2024-07-14_14:55:01.sql  db_backup_2024-07-14_14:57:01.sql  db_backup_2024-07-14_14:59:01.sql  db_backup_2024-07-14_15:01:01.sql
db_backup_2024-07-14_14:56:01.sql  db_backup_2024-07-14_14:58:01.sql  db_backup_2024-07-14_15:00:01.sql  db_backup_2024-07-14_15:02:01.sql
```

---

### Задание 6

#### Задача 6 (*)
Скачайте docker образ ```hashicorp/terraform:latest``` и скопируйте бинарный файл ```/bin/terraform``` на свою локальную машину, используя dive и docker save.
Предоставьте скриншоты  действий .

#### Задача 6.1
Добейтесь аналогичного результата, используя docker cp.  
Предоставьте скриншоты  действий .

#### Задача 6.2 (**)
Предложите способ извлечь файл из контейнера, используя только команду docker build и любой Dockerfile.  
Предоставьте скриншоты  действий .

### Ответ

6
```bash
$ docker save hashicorp/terraform:latest -o terraform_latest.tar

$ tar -xvf terraform_latest.tar -C terraform_image
blobs/
blobs/sha256/
blobs/sha256/109c1976f4b2f03aef5cf82bd525b03dd4356527b0bd8f22294354bae06aec9f
blobs/sha256/4dcbcdcfdb7ea3f99552522f11af8c3e79c9c6423d85e40ddc627ca379af9c3e
blobs/sha256/69b1bb89206d418e4064c38b31197e1127775ebad26ffae921e14e5140a6caf2
blobs/sha256/8f8ff1e8b2107e083a27e291078b1fa17c70951a5ae8ea384b0ff906b54e36d8
blobs/sha256/94e5f06ff8e3d4441dc3cd8b090ff38dc911bfa8ebdb0dc28395bc98f82f983f
blobs/sha256/af62ce8c3aedebc8aedfc28dc978ab63ceb66fba41726accc1576d7ebb82b1c9
blobs/sha256/b75760e318111d39a620f1cbdc99928cefaa5415f72837961dfd7497862ddaf6
blobs/sha256/bba9fe85f27b1954ea463c10f94b123e0b15429b95b154d263cd0727e8abece0
blobs/sha256/bbcba969e453de8d057b8a466e3bf93834f5cdb6ff5987da9b7ae82987c577e0
blobs/sha256/e8631d4ab792600429bfe2f1ef3cfd55515eda24732949df7aed86d269a30b18
index.json
manifest.json
oci-layout
repositories

$ tar -xvf terraform_image/blobs/sha256/4dcbcdcfdb7ea3f99552522f11af8c3e79c9c6423d85e40ddc627ca379af9c3e -C layer
bin/
bin/terraform

$ cp layer/bin/terraform ./terraform

$ ls ./terraform
terraform
```

6.1
```bash
$ docker run -d --name terraform-container hashicorp/terraform:latest tail -f /dev/null

$ docker cp terraform-container:/bin/terraform ./terraform
Successfully copied 89MB to /******/terraform

$ docker stop terraform-container
docker rm terraform-container
terraform-container
terraform-container

$ ls ./terraform
terraform
```

6.2
```Dockerfile
FROM hashicorp/terraform:latest
COPY --from=hashicorp/terraform:latest /bin/terraform /terraform
```

```bash
$ docker build -t extract-terraform .

$ docker create --name extract-container extract-terraform
docker cp extract-container:/terraform ./terraform
docker rm extract-container
97abe133f0a902849ba3d450013ae2c8f37e09a207dbdab9420b41ff703af2de
Successfully copied 89MB to /******/terraform
extract-container

$ ls ./terraform
terraform
```
