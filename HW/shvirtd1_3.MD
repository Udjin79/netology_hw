# Домашнее задание к занятию "`Оркестрация группой Docker контейнеров на примере Docker Compose`" - `Исаенков Евгений`
   
### Задание 1

Сценарий выполнения задачи:
- Установите docker и docker compose plugin на свою linux рабочую станцию или ВМ.
- Если dockerhub недоступен создайте файл /etc/docker/daemon.json с содержимым: ```{"registry-mirrors": ["https://mirror.gcr.io", "https://daocloud.io", "https://c.163.com/", "https://registry.docker-cn.com"]}```
- Зарегистрируйтесь и создайте публичный репозиторий  с именем "custom-nginx" на https://hub.docker.com (ТОЛЬКО ЕСЛИ У ВАС ЕСТЬ ДОСТУП);
- скачайте образ nginx:1.21.1;
- Создайте Dockerfile и реализуйте в нем замену дефолтной индекс-страницы(/usr/share/nginx/html/index.html), на файл index.html с содержимым:
```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
```
- Соберите и отправьте созданный образ в свой dockerhub-репозитории c tag 1.0.0 (ТОЛЬКО ЕСЛИ ЕСТЬ ДОСТУП). 
- Предоставьте ответ в виде ссылки на https://hub.docker.com/<username_repo>/custom-nginx/general .

### Ответ

[[dockerhub] udjin79/nginx_custom image](https://hub.docker.com/repository/docker/udjin79/nginx_custom/general)

v.1 Копирование файла из каталога с Dockerfile
```yaml
FROM nginx:1.21.1

COPY index.html /usr/share/nginx/html/index.html
```


v.2 Прямое изменение index.html в контейнере
```yaml
FROM nginx:1.21.1

RUN echo '<html><head>Hey, Netology</head><body><h1>I will be DevOps Engineer!</h1></body></html>' > /usr/share/nginx/html/index.html
```

```bash
$ docker pull nginx:1.21.1
1.21.1: Pulling from library/nginx
Status: Downloaded newer image for nginx:1.21.1
docker.io/library/nginx:1.21.1
$ docker build -t udjin79/nginx_custom:1.0.0 .
[+] Building 1.6s (6/6) 
$ docker login
Authenticating with existing credentials...
Login Succeeded
$ docker push udjin79/nginx_custom:1.0.0
The push refers to repository [docker.io/udjin79/nginx_custom]
1.0.0: digest: sha256:340fe62c23fafa756e661d319706620f768821a860aef0c8b2787844cf4ef956 size: 1777
```

Проверка работы контейнера
```bash
$ docker run -d -p 8080:80 udjin79/nginx_custom:1.0.0
```

![1](https://github.com/Udjin79/netology_hw/blob/main/img/shvirtd1_3_1.png?raw=true)

---

### Задание 2

1. Запустите ваш образ custom-nginx:1.0.0 командой docker run в соответвии с требованиями:
- имя контейнера "ФИО-custom-nginx-t2"
- контейнер работает в фоне
- контейнер опубликован на порту хост системы 127.0.0.1:8080
2. Переименуйте контейнер в "custom-nginx-t2"
3. Выполните команду ```date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080  ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html```
4. Убедитесь с помощью curl или веб браузера, что индекс-страница доступна.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

### Ответ

```bash
$ docker run -d --name evgenii-isaenkov-custom-nginx-t2 -p 127.0.0.1:8080:80 udjin79/nginx_custom:1.0.0
5a87d0b478b6649a26dde49b2646cf2ff99fa7c8aba507382d7d3cd4f43d1390
$ docker ps -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED          STATUS                     PORTS                                                 NAMES
5a87d0b478b6   udjin79/nginx_custom:1.0.0    "/docker-entrypoint.…"   17 seconds ago   Up 16 seconds              127.0.0.1:8080->80/tcp                                evgenii-isaenkov-custom-nginx-t2
$ docker rename evgenii-isaenkov-custom-nginx-t2 custom-nginx-t2
$ docker ps -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED         STATUS                     PORTS                                                 NAMES
5a87d0b478b6   udjin79/nginx_custom:1.0.0    "/docker-entrypoint.…"   8 minutes ago   Up 8 minutes               127.0.0.1:8080->80/tcp                                custom-nginx-t2
$ date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080 ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html
24-06-2024 11:38:13.679720367 MSK
CONTAINER ID   IMAGE                         COMMAND                  CREATED         STATUS                 PORTS                                                 NAMES
5a87d0b478b6   udjin79/nginx_custom:1.0.0    "/docker-entrypoint.…"   9 minutes ago   Up 9 minutes           127.0.0.1:8080->80/tcp                                custom-nginx-t2
LISTEN 0      4096       127.0.0.1:8080       0.0.0.0:*
2024/06/24 08:29:01 [notice] 1#1: start worker process 36
PGh0bWw+PGhlYWQ+SGV5LCBOZXRvbG9neTwvaGVhZD48Ym9keT48aDE+SSB3aWxsIGJlIERldk9w
cyBFbmdpbmVlciE8L2gxPjwvYm9keT48L2h0bWw+Cg==
$ curl http://127.0.0.1:8080
<html><head>Hey, Netology</head><body><h1>I will be DevOps Engineer!</h1></body></html>
```

---

### Задание 3

1. Воспользуйтесь docker help или google, чтобы узнать как подключиться к стандартному потоку ввода/вывода/ошибок контейнера "custom-nginx-t2".
2. Подключитесь к контейнеру и нажмите комбинацию Ctrl-C.
3. Выполните ```docker ps -a``` и объясните своими словами почему контейнер остановился.
4. Перезапустите контейнер
5. Зайдите в интерактивный терминал контейнера "custom-nginx-t2" с оболочкой bash.
6. Установите любимый текстовый редактор(vim, nano итд) с помощью apt-get.
7. Отредактируйте файл "/etc/nginx/conf.d/default.conf", заменив порт "listen 80" на "listen 81".
8. Запомните(!) и выполните команду ```nginx -s reload```, а затем внутри контейнера ```curl http://127.0.0.1:80 ; curl http://127.0.0.1:81```.
9. Выйдите из контейнера, набрав в консоли  ```exit``` или Ctrl-D.
10. Проверьте вывод команд: ```ss -tlpn | grep 127.0.0.1:8080``` , ```docker port custom-nginx-t2```, ```curl http://127.0.0.1:8080```. Кратко объясните суть возникшей проблемы.
11. * Это дополнительное, необязательное задание. Попробуйте самостоятельно исправить конфигурацию контейнера, используя доступные источники в интернете. Не изменяйте конфигурацию nginx и не удаляйте контейнер. Останавливать контейнер можно. [пример источника](https://www.baeldung.com/linux/assign-port-docker-container)
12. Удалите запущенный контейнер "custom-nginx-t2", не останавливая его.(воспользуйтесь --help или google)

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

### Ответ

```bash
$ docker attach custom-nginx-t2
^C
2024/06/24 08:42:47 [notice] 1#1: signal 2 (SIGINT) received, exiting
2024/06/24 08:42:47 [notice] 1#1: exit
$ docker ps -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED          STATUS                      PORTS                                                 NAMES
5a87d0b478b6   udjin79/nginx_custom:1.0.0    "/docker-entrypoint.…"   13 minutes ago   Exited (0) 10 seconds ago                                                         custom-nginx-t2
$ docker start custom-nginx-t2
custom-nginx-t2
$ docker exec -it custom-nginx-t2 /bin/bash
root@5a87d0b478b6:/# apt-get update
root@5a87d0b478b6:/# apt-get install -y vim
root@5a87d0b478b6:/# vim /etc/nginx/conf.d/default.conf
root@5a87d0b478b6:/# cat /etc/nginx/conf.d/default.conf
server {
    listen       81;
    listen  [::]:81;
    server_name  localhost;
root@5a87d0b478b6:/# nginx -s reload
2024/06/24 08:48:16 [notice] 423#423: signal process started
root@5a87d0b478b6:/# curl http://127.0.0.1:80 ; curl http://127.0.0.1:81
curl: (7) Failed to connect to 127.0.0.1 port 80: Connection refused
<html><head>Hey, Netology</head><body><h1>I will be DevOps Engineer!</h1></body></html>
root@5a87d0b478b6:/# exit
exit
```

Когда был изменён порт в конфигурации nginx с 80 на 81, контейнер перестал слушать порт 80, который привязан к 127.0.0.1:8080. 
Поэтому запросы к http://127.0.0.1:8080 не обрабатываются nginx внутри контейнера.

```bash
$ ss -tlpn | grep 127.0.0.1:8080
LISTEN 0      4096       127.0.0.1:8080       0.0.0.0:*
$ docker port custom-nginx-t2
80/tcp -> 127.0.0.1:8080
$ curl http://127.0.0.1:8080
curl: (52) Empty reply from server
$ docker stop custom-nginx-t2
custom-nginx-t2
$ docker commit custom-nginx-t2 custom-nginx-t2:0.0.2
sha256:d421deb8394acce72db25236b0fbd4f7122ed30f36bc2a26d4d7f188881253bc
$ docker rm custom-nginx-t2
custom-nginx-t2
$ docker run -d --name custom-nginx-t2 -p 127.0.0.1:8080:81 custom-nginx-t2:0.0.2
575bcfe48390412ed0c8bc941332e09a140fbfc5241e6542038e5ab37ed9cae1
$ curl http://127.0.0.1:8080
<html><head>Hey, Netology</head><body><h1>I will be DevOps Engineer!</h1></body></html>
$ docker ps -a
CONTAINER ID   IMAGE                         COMMAND                  CREATED          STATUS                      PORTS                                                 NAMES
575bcfe48390   custom-nginx-t2:0.0.2      "/docker-entrypoint.…"   12 minutes ago   Up 5 seconds                80/tcp, 127.0.0.1:8080->81/tcp                        custom-nginx-t2
```

---

### Задание 4

- Запустите первый контейнер из образа ***centos*** c любым тегом в фоновом режиме, подключив папку  текущий рабочий каталог ```$(pwd)``` на хостовой машине в ```/data``` контейнера, используя ключ -v.
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив текущий рабочий каталог ```$(pwd)``` в ```/data``` контейнера. 
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```.
- Добавьте ещё один файл в текущий каталог ```$(pwd)``` на хостовой машине.
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.


В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод.

### Ответ

Команду ```sleep infinity``` использовал для того, чтобы контейнер продолжал работать в фоновом режиме. 
Без этой команды контейнер завершил бы свою работу сразу после запуска, так как в нем не запущено никаких процессов, удерживающих его активным

```bash
$ docker run -d --name centos-container -v $(pwd):/data centos:latest sleep infinity
c8bcc1eb419ed04f8c0c87116455eb9d650b70a27d24327bff8a74bdc0698950
$ docker run -d --name debian-container -v $(pwd):/data debian:latest sleep infinity
30ef6647df3d5a2eae771a5ee884a38c7fd616a2e140951c0497694de4ceff13
$ docker exec -it centos-container /bin/bash
[root@c8bcc1eb419e /]# echo "CentOS container test file" > /data/centos_file.txt
[root@c8bcc1eb419e /]# exit
exit
$ echo "HOST machine test file" > $(pwd)/host_file.txt
$ docker exec -it debian-container /bin/bash
root@30ef6647df3d:/# ls /data
Dockerfile  centos_file.txt  host_file.txt  index.html
root@30ef6647df3d:/# cat /data/centos_file.txt
CentOS container test file
root@30ef6647df3d:/# cat /data/host_file.txt
HOST machine test file
root@30ef6647df3d:/# exit
exit
```

---

### Задание 5

1. Создайте отдельную директорию(например /tmp/netology/docker/task5) и 2 файла внутри него.
"compose.yaml" с содержимым:
```yaml
version: "3"
services:
  portainer:
    image: portainer/portainer-ce:latest
    network_mode: host
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```
"docker-compose.yaml" с содержимым:
```yaml
version: "3"
services:
  registry:
    image: registry:2
    network_mode: host
    ports:
    - "5000:5000"
```

И выполните команду "docker compose up -d". Какой из файлов был запущен и почему? (подсказка: https://docs.docker.com/compose/compose-application-model/#the-compose-file )

2. Отредактируйте файл compose.yaml так, чтобы были запущенны оба файла. (подсказка: https://docs.docker.com/compose/compose-file/14-include/)

3. Выполните в консоли вашей хостовой ОС необходимые команды чтобы залить образ custom-nginx как custom-nginx:latest в запущенное вами, локальное registry. Дополнительная документация: https://distribution.github.io/distribution/about/deploying/
4. Откройте страницу "https://127.0.0.1:9000" и произведите начальную настройку portainer.(логин и пароль адмнистратора)
5. Откройте страницу "http://127.0.0.1:9000/#!/home", выберите ваше local  окружение. Перейдите на вкладку "stacks" и в "web editor" задеплойте следующий компоуз:

```yaml
version: '3'

services:
  nginx:
    image: 127.0.0.1:5000/custom-nginx
    ports:
      - "9090:80"
```
6. Перейдите на страницу "http://127.0.0.1:9000/#!/2/docker/containers", выберите контейнер с nginx и нажмите на кнопку "inspect". В представлении <> Tree разверните поле "Config" и сделайте скриншот от поля "AppArmorProfile" до "Driver".

7. Удалите любой из манифестов компоуза(например compose.yaml).  Выполните команду "docker compose up -d". Прочитайте warning, объясните суть предупреждения и выполните предложенное действие. Погасите compose-проект ОДНОЙ(обязательно!!) командой.

В качестве ответа приложите скриншоты консоли, где видно все введенные команды и их вывод, файл compose.yaml , скриншот portainer c задеплоенным компоузом.

### Ответ

#### Шаг 1

```bash
/task5$ echo 'version: "3"
services:
  portainer:
    image: portainer/portainer-ce:latest
    network_mode: bridge
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock' > compose.yaml

/task5$ echo 'version: "3"
services:
  registry:
    image: registry:2
    network_mode: bridge
    ports:
      - "5000:5000"' > docker-compose.yaml

/task5$ docker compose up -d
WARN[0000] Found multiple config files with supported names: /mnt/h/DevOps/Docker/task5/compose.yaml, /mnt/h/DevOps/Docker/task5/docker-compose.yaml
WARN[0000] Using /mnt/h/DevOps/Docker/task5/compose.yaml
WARN[0000] Found multiple config files with supported names: /mnt/h/DevOps/Docker/task5/compose.yaml, /mnt/h/DevOps/Docker/task5/docker-compose.yaml
WARN[0000] Using /mnt/h/DevOps/Docker/task5/compose.yaml
[+] Running 12/12
 ✔ portainer 11 layers [⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]      0B/0B      Pulled                                                                                                                                                                       61.8s
   ✔ 57654d40e0a5 Pull complete                                                                                                                                                                                                    1.6s
   ✔ 1f476acfabd6 Pull complete                                                                                                                                                                                                    1.4s
   ✔ 5171176db7f2 Pull complete                                                                                                                                                                                                    3.8s
   ✔ 52e9438966a5 Pull complete                                                                                                                                                                                                   11.9s
   ✔ 43d4775415ac Pull complete                                                                                                                                                                                                    6.2s
   ✔ c1cad9f5200f Pull complete                                                                                                                                                                                                    8.4s
   ✔ a5e2b359b78b Pull complete                                                                                                                                                                                                    7.6s
   ✔ eb172612bcbb Pull complete                                                                                                                                                                                                   13.2s
   ✔ 6be7b2acffb5 Pull complete                                                                                                                                                                                                   12.8s
   ✔ 391dff0fb880 Pull complete                                                                                                                                                                                                   13.6s
   ✔ 4f4fb700ef54 Pull complete                                                                                                                                                                                                   14.9s
[+] Building 0.0s (0/0)                                                                                                                                                                                                  docker:default
[+] Running 2/2
 ✔ Container task5-portainer-1                                          Started                                                                                                                                                    6.7s
```

Стандартный путь для файла Compose — это `compose.yaml` (предпочтительно) или `compose.yml`, который размещается в рабочем каталоге. Compose также поддерживает `docker-compose.yaml` и `docker-compose.yml` для обратной совместимости с более ранними версиями. Если оба файла существуют, будет выбран `compose.yaml`.

[Docker Documentation](https://docs.docker.com/compose/compose-application-model/#the-compose-file)

#### Шаг 2

```bash
/task5$ echo 'version: "3"
include:
  - ./docker-compose.yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    network_mode: bridge
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock' > compose.yaml

/task5$ docker compose -f compose.yaml up -d
[+] Running 6/6
 ✔ registry 5 layers [⣿⣿⣿⣿⣿]      0B/0B      Pulled                                                                                                                                                                               50.1s
   ✔ 73baa7ef167e Pull complete                                                                                                                                                                                                    2.7s
   ✔ d49090716641 Pull complete                                                                                                                                                                                                    1.8s
   ✔ bc8f2b8a18ff Pull complete                                                                                                                                                                                                    3.0s
   ✔ 9d41963883ad Pull complete                                                                                                                                                                                                    3.2s
   ✔ ad02dd2076d6 Pull complete                                                                                                                                                                                                    3.9s
[+] Building 0.0s (0/0)                                                                                                                                                                                                  docker:default
[+] Running 3/3
 ✔ Container task5-portainer-1                                         Running                                                                                                                                                     0.0s
 ✔ Container task5-registry-1                                          Started                                                                                                                                                     1.8s
```

#### Шаг 3
```bash
/task5$ docker tag udjin79/nginx_custom:1.0.0 localhost:5000/nginx_custom:latest

/task5$ docker push localhost:5000/nginx_custom:latest
The push refers to repository [localhost:5000/nginx_custom]
35362aa5e584: Pushed
d47e4d19ddec: Pushed
8e58314e4a4f: Pushed
ed94af62a494: Pushed
875b5b50454b: Pushed
63b5f2c0d071: Pushed
d000633a5681: Pushed
latest: digest: sha256:340fe62c23fafa756e661d319706620f768821a860aef0c8b2787844cf4ef956 size: 1777
```

#### Шаг 4

![2](https://github.com/Udjin79/netology_hw/blob/main/img/shvirtd1_3_2.png?raw=true)

#### Шаг 5

![3](https://github.com/Udjin79/netology_hw/blob/main/img/shvirtd1_3_3.png?raw=true)

#### Шаг 6

```json
{
    "AppArmorProfile": "",
    "Args": [
        "nginx",
        "-g",
        "daemon off;"
    ],
    "Config": {
        "AttachStderr": true,
        "AttachStdin": false,
        "AttachStdout": true,
        "Cmd": [
            "nginx",
            "-g",
            "daemon off;"
        ],
        "Domainname": "",
        "Entrypoint": [
            "/docker-entrypoint.sh"
        ],
        "Env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "NGINX_VERSION=1.21.1",
            "NJS_VERSION=0.6.1",
            "PKG_RELEASE=1~buster"
        ],
        "ExposedPorts": {
            "80/tcp": {}
        },
        "Hostname": "568d9fd34c96",
        "Image": "127.0.0.1:5000/nginx_custom",
        "Labels": {
            "com.docker.compose.config-hash": "3eb4ec2ef82efbaa3dd7c32843914238fc22f9e9fd7669f782547e472d79daad",
            "com.docker.compose.container-number": "1",
            "com.docker.compose.depends_on": "",
            "com.docker.compose.image": "sha256:c5d9b8c22efa5b76dec50168a59c8a2ebd2b1c35461b0c4704d0c5f898e7a6d9",
            "com.docker.compose.oneoff": "False",
            "com.docker.compose.project": "nginx_local_registry",
            "com.docker.compose.project.config_files": "/data/compose/5/docker-compose.yml",
            "com.docker.compose.project.working_dir": "/data/compose/5",
            "com.docker.compose.service": "nginx",
            "com.docker.compose.version": "2.20.2",
            "desktop.docker.io/wsl-distro": "Ubuntu",
            "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
        },
        "OnBuild": null,
        "OpenStdin": false,
        "StdinOnce": false,
        "StopSignal": "SIGQUIT",
        "Tty": false,
        "User": "",
        "Volumes": null,
        "WorkingDir": ""
    },
    "Created": "2024-06-24T11:41:25.614362568Z",
```

#### Шаг 7

```bash
/task5$ rm compose.yaml

/task5$ docker compose up -d
[+] Building 0.0s (0/0)                                                                                                                                                                                                  docker:default
WARN[0000] Found orphan containers ([task5-portainer-1]) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
[+] Running 1/0
 ✔ Container task5-registry-1  Running                                                                                                                                                                                             0.0s

/task5$ docker compose up -d --remove-orphans
[+] Building 0.0s (0/0)                                                                                                                                                                                                  docker:default
[+] Running 2/1
 ✔ Container task5-portainer-1  Removed                                                                                                                                                                                            0.4s
 ✔ Container task5-registry-1   Running                                                                                                                                                                                            0.0s

/task5$ docker compose down
[+] Running 1/1
 ✔ Container task5-registry-1  Removed                                                                                                                                                                                             0.3s
```

##### Объяснение предупреждения

Сообщение `Found orphan containers` указывает на то, что при запуске `docker-compose` были обнаружены контейнеры, которые были созданы предыдущей версией `compose` файла, но больше не существуют в текущей версии файла. Эти контейнеры называются "осиротевшими", так как они больше не управляются текущей конфигурацией.

##### Как это исправить

Чтобы очистить осиротевшие контейнеры, нужно использовать флаг `--remove-orphans`. Этот флаг удалит все контейнеры, которые больше не определены в `compose` файле.
