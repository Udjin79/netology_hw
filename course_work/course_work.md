### Структурирование и подготовка материалов:

Перед выполнением задания все необходимые материалы (плейбуки, дистрибутивы, конфигурационные файлы) были собраны в локальную директорию и структурированы по назначению.

### Структура каталога:

```
Основной каталог/
├── main.tf
├── плейбуки
├── Configs/
│ ├── Filebeat/
│ ├── Nginx/
│ ├── Elastic/
│ ├── Kibana/
│ └── ....
└── Distrib/
```

Список ВМ сгруппирован по сервисам в файле inventory.ini

```
[web_servers_hosts]
course-vm1 ansible_host=xxx.xxx.x.x ansible_user=username
course-vm2 ansible_host=xx.xxx.xx.xxx ansible_user=username

[prometheus_hosts]
prometheus ansible_host=xxx.xxx.xx.xx ansible_user=username

[grafana_hosts]
grafana ansible_host=xxx.xxx.xxx.xx ansible_user=username

[elasticsearch_hosts]
elasticsearch ansible_host=xx.xxx.xxx.xx ansible_user=username

[kibana_hosts]
kibana ansible_host=xxx.xxx.xxx.xx ansible_user=username
```

### 1. Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

## Ответ

### Выполненные работы

1. **Развертывание инфраструктуры с помощью Terraform:**
   - Основная инфраструктура развернута с использованием Terraform.

2. **Создание виртуальных машин (ВМ):**
   - ВМ созданы с внешним доступом для первоначальной настройки и отладки.

3. **Сетевые настройки:**
   - Создана сеть и две подсети: внешняя и внутренняя.
   - ВМ привязаны к соответствующим подсетям.

4. **Настройка балансировки нагрузки:**
   - Создан Application Load Balancer (ALB) для балансировки HTTP-запросов на веб-сервера.

5. **Оптимизация внешнего доступа:**
   - После проведенных работ по настройке удалены внешние IP-адреса у ВМ, к которым не предполагается внешний доступ.

6. **Настройка серверов с помощью Ansible:**
   - Применены плейбуки Ansible `docker.yml` для установки Docker на все ВМ (потребуется в дальнейшем).
   - Применены плейбуки Ansible `web_servers.yml` для настройки web серверов:
     - Установлены Nginx, Node Exporter, Prometheus Nginx Log Exporter, Filebeat на web сервера.
     - В связи с тем, что некоторые репозитории заблокированы для доступа из РФ и штатная установка с загрузкой из репозиториев вендора невозможна, было применено альтернативное решение, с загрузкой пакетов на локальный ПК, в категорию distrib, и пакеты загружались из локальной директории напрямую на целевые ВМ с помощью Ansible. В частности это касалось продуктов ELK стека.

![1](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_1.png?raw=true)
![2](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_2.png?raw=true)
![3](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_3.png?raw=true)

[Приложенный Terraform конфигурационный файл](https://github.com/Udjin79/netology_hw/blob/main/files/course/main.tf?raw=true)

[Приложенный плейбук для установки docker](https://github.com/Udjin79/netology_hw/blob/main/files/course/docker.yml?raw=true)

[Приложенный плейбук для установки ПО на web сервера](https://github.com/Udjin79/netology_hw/blob/main/files/course/web_servers.yml?raw=true)

Результат проверки балансировки ВМ:
```bash
curl http://158.160.155.1
<html>
<head><title>course-vm1</title></head>
<body>
<h1>course-vm1</h1>
<p>This is a web server hosted on course-vm1.</p>
</body>
</html>

curl http://158.160.155.1
<html>
<head><title>course-vm2</title></head>
<body>
<h1>course-vm2</h1>
<p>This is a web server hosted on course-vm2.</p>
</body>
</html>
```

---

### 2. Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.

## Ответ

### Установка Prometheus и Grafana

- **Использование Ansible:** 
  - Установка Prometheus и Grafana производилась с помощью плейбуков Ansible.

- **Настройка агентов:**
  - Агенты на web серверах были настроены для взаимодействия с сервисом Prometheus по внутренним IP адресам на этапе настройки web серверов, общим плейбуком.

![4](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_4.png?raw=true)
![5](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_5.png?raw=true)
![6](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_6.png?raw=true)
![7](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_7.png?raw=true)
![8](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_8.png?raw=true)
![9](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_9.png?raw=true)


[Приложенный плейбук для установки Prometheus](https://github.com/Udjin79/netology_hw/blob/main/files/course/prometheus.yml?raw=true)

[Приложенный плейбук для установки Grafana](https://github.com/Udjin79/netology_hw/blob/main/files/course/grafana.yml?raw=true)


---

### 3. Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

## Ответ

### Установка Kibana и Elasticsearch

- **Использование Docker контейнеризации:**
  - В связи с недоступностью официальных ресурсов, Kibana и Elasticsearch настраивались с помощью Docker контейнеризации.
  - Конфигурационные файлы копировались на целевые ВМ и подгружались в контейнеры при старте.
  - Была выбрана версия 7.14.0 как наиболее стабильная, и где нет проблем с запуском сервисов без токена.

- **Настройка агентов Filebeat:**
  - Агенты Filebeat на web серверах были настроены для взаимодействия с сервисом Elasticsearch по внутренним IP адресам на этапе настройки web серверов, общим плейбуком.

### Команды для запуска Docker контейнеров:

```bash
docker pull elasticsearch:7.14.0

docker run -d \
  --name elasticsearch \
  -v ./config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro \
  -e ES_JAVA_OPTS="-Xmx512m -Xms512m" \
  -e ELASTIC_USERNAME="******************" \
  -e ELASTIC_PASSWORD="******************" \
  -e discovery.type="single-node" \
  -p 9200:9200 \
  -p 9300:9300 \
  elasticsearch:7.14.0

docker pull kibana:7.14.0

docker run -d \
  --name kibana \
  -v ./configs/kibana.yml:/usr/share/kibana/config/kibana.yml:ro \
  -p 5601:5601 \
  kibana:7.14.0
```

[Приложенный плейбук для установки Elasticsearch](https://github.com/Udjin79/netology_hw/blob/main/files/course/elasticsearch.yml?raw=true)

[Приложенный плейбук для установки Kibana](https://github.com/Udjin79/netology_hw/blob/main/files/course/kibana.yml?raw=true)

![16](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_16.png?raw=true)
![17](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_17.png?raw=true)
![18](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_18.png?raw=true)

---

### 4. Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

## Ответ

- **Базовые настройки:**
  - Настройки по размещению сервисов в подсети выполнялись на этапе создания инфраструктуры с помощью Terraform конфигурационного файла.
  - Сервис bastion-host, а именно создание подсети, резервирование ВМ, создание и конфигурирование ВМ настраивался через web интерфейс.

- **Группы безопасности:**
  - Организован доступ только к требуемым портам с помощью групп безопасности.
  - Если взаимодействие по порту идет только через внутреннюю сеть, то доступ к порту открывался только в рамках группы безопасности.
  - Доступ через 22 порт возможен только через bastion-host

![20](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_20.png?raw=true)
![13](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_13.png?raw=true)
![12](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_12.png?raw=true)
![19](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_19.png?raw=true)
![20](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_20.png?raw=true)
---

### 5. Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

## Ответ

### Резервное копирование
- Настройка резервного копирования дисков проводилась через пользовательский интерфейс.
- Было создано расписание с частотой сохранения и глубиной хранения согласно задаче — 7 дней.

![14](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_14.png?raw=true)
![15](https://github.com/Udjin79/netology_hw/blob/main/img/course/course_15.png?raw=true)
