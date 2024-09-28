# Домашнее задание к занятию "`Средство визуализации Grafana`" - `Исаенков Евгений`

### Задание 1

1. Используя директорию [help](./help) внутри этого домашнего задания, запустите связку prometheus-grafana.
2. Зайдите в веб-интерфейс grafana, используя авторизационные данные, указанные в манифесте docker-compose.
3. Подключите поднятый вами prometheus, как источник данных.
4. Решение домашнего задания — скриншот веб-интерфейса grafana со списком подключенных Datasource.

## Задание 2

Изучите самостоятельно ресурсы:

1. [PromQL tutorial for beginners and humans](https://valyala.medium.com/promql-tutorial-for-beginners-9ab455142085).
2. [Understanding Machine CPU usage](https://www.robustperception.io/understanding-machine-cpu-usage).
3. [Introduction to PromQL, the Prometheus query language](https://grafana.com/blog/2020/02/04/introduction-to-promql-the-prometheus-query-language/).

Создайте Dashboard и в ней создайте Panels:

- утилизация CPU для nodeexporter (в процентах, 100-idle);
- CPULA 1/5/15;
- количество свободной оперативной памяти;
- количество места на файловой системе.

Для решения этого задания приведите promql-запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

## Задание 3

1. Создайте для каждой Dashboard подходящее правило alert — можно обратиться к первой лекции в блоке «Мониторинг».
2. В качестве решения задания приведите скриншот вашей итоговой Dashboard.

## Задание 4

1. Сохраните ваш Dashboard.Для этого перейдите в настройки Dashboard, выберите в боковом меню «JSON MODEL». Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.
2. В качестве решения задания приведите листинг этого файла.

---

## Ответ

### Задание 1

2. Зайдите в веб-интерфейс grafana, используя авторизационные данные, указанные в манифесте docker-compose.
3. Подключите поднятый вами prometheus, как источник данных.
4. Решение домашнего задания — скриншот веб-интерфейса grafana со списком подключенных Datasource.

```bash
$ docker compose up -d
WARN[0000] /mnt/h/DevOps/mnt-homeworks/10-monitoring-03-grafana/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
[+] Running 26/26
...
[+] Running 5/5
 ✔ Network 10-monitoring-03-grafana_monitor-net    Created                                                                                                                                                                        21.1s
 ✔ Volume "10-monitoring-03-grafana_grafana_data"  Created                                                                                                                                                                         0.1s
 ✔ Container nodeexporter                          Started                                                                                                                                                                         2.5s
 ✔ Container prometheus                            Started                                                                                                                                                                         2.9s
 ✔ Container grafana                               Started                                                                                                                                                                         3.6s
```

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/10shmon2_1.png?raw=true)
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/10shmon2_2.png?raw=true)

## Задание 2

Создайте Dashboard и в ней создайте Panels:

Утилизация CPU для nodeexporter (в процентах, 100-idle);
```bash
100 -(avg by (instance) (rate(node_cpu_seconds_total{job="nodeexporter",mode="idle"}[1m])) * 100)
```

CPULA 1/5/15
```bash
node_load1{instance="nodeexporter:9100", job="nodeexporter"}
node_load5{instance="nodeexporter:9100", job="nodeexporter"}
node_load15{instance="nodeexporter:9100", job="nodeexporter"}
```

Количество свободной оперативной памяти
```bash
node_memory_MemFree_bytes{instance="nodeexporter:9100", job="nodeexporter"} / 1024 / 1024 / 1024
```

Количество места на файловой системе.
```bash
node_filesystem_avail_bytes{fstype="ext4", mountpoint="/"} / 1024 / 1024 / 1024
```

![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/10shmon2_3.png?raw=true)

## Задание 3

1. Создайте для каждой Dashboard подходящее правило alert — можно обратиться к первой лекции в блоке «Мониторинг».
2. В качестве решения задания приведите скриншот вашей итоговой Dashboard.

![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/10shmon2_4.png?raw=true)

## Задание 4

1. Сохраните ваш Dashboard.Для этого перейдите в настройки Dashboard, выберите в боковом меню «JSON MODEL». Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.
2. В качестве решения задания приведите листинг этого файла.

https://github.com/Udjin79/netology_hw/blob/main/files/10shmon_2/netology_dashboard.json

