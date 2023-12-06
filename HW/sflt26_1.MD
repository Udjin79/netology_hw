# Домашнее задание к занятию "`Disaster recovery и Keepalived`" - `Исаенков Евгений`

---

### Задание 1

- Дана схема для Cisco Packet Tracer, рассматриваемая в лекции.
- На данной схеме уже настроено отслеживание интерфейсов маршрутизаторов Gi0/1 (для нулевой группы)
- Необходимо аналогично настроить отслеживание состояния интерфейсов Gi0/0 (для первой группы).
- Для проверки корректности настройки, разорвите один из кабелей между одним из маршрутизаторов и Switch0 и запустите ping между PC0 и Server0.
- На проверку отправьте получившуюся схему в формате pkt и скриншот, где виден процесс настройки маршрутизатора.


Router1 Configuration:
```
enable
configure terminal

interface GigabitEthernet0/0
ip address 192.168.0.2 255.255.255.0
standby 0 ip 192.168.0.1
standby 0 priority 105
standby 0 preempt
standby 0 track GigabitEthernet0/1


interface GigabitEthernet0/1
ip address 192.168.1.2 255.255.255.0
standby 1 ip 192.168.1.1
standby 1 priority 105
standby 1 preempt
standby 1 track GigabitEthernet0/0

end
write memory
```

Router2 Configuration:
```
enable
configure terminal

interface GigabitEthernet0/0
ip address 192.168.0.3 255.255.255.0
standby 0 ip 192.168.0.1
standby 0 priority 105
standby 0 preempt
standby 0 track GigabitEthernet0/1


interface GigabitEthernet0/1
ip address 192.168.1.3 255.255.255.0
standby 1 ip 192.168.1.1
standby 1 priority 105
standby 1 preempt
standby 1 track GigabitEthernet0/0

end
write memory
```
PKT файл:
**https://github.com/Udjin79/netology_hw/blob/be13636545a6677f3b590310781a02cc080d67e9/files/sflt26_hw1_hsrp_advanced.pkt**

Скриншоты проверки:
![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_1.png?raw=true)
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_2.png?raw=true)
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_3.png?raw=true)
![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_4.png?raw=true)
![Название скриншота 5](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_5.png?raw=true)
![Название скриншота 6](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_6.png?raw=true)


---

### Задание 2

- Запустите две виртуальные машины Linux, установите и настройте сервис Keepalived как в лекции, используя пример конфигурационного файла.
- Настройте любой веб-сервер (например, nginx или simple python server) на двух виртуальных машинах
- Напишите Bash-скрипт, который будет проверять доступность порта данного веб-сервера и существование файла index.html в root-директории данного веб-сервера.
- Настройте Keepalived так, чтобы он запускал данный скрипт каждые 3 секунды и переносил виртуальный IP на другой сервер, если bash-скрипт завершался с кодом, отличным от нуля (то есть порт веб-сервера был недоступен или отсутствовал index.html). Используйте для этого секцию vrrp_script
- На проверку отправьте получившейся bash-скрипт и конфигурационный файл keepalived, а также скриншот с демонстрацией переезда плавающего ip на другой сервер в случае недоступности порта или файла index.html

check_web_server.sh
```bash
#!/bin/bash

# Переменные
WEB_SERVER="localhost"
WEB_PORT=80
INDEX_FILE="/var/www/html/index.html"

# Проверка доступности порта веб-сервера
nc -zv -w 1 $WEB_SERVER $WEB_PORT > /dev/null 2>&1
PORT_STATUS=$?

# Проверка существования файла index.html
if [ -f $INDEX_FILE ]; then
    FILE_STATUS=0
else
    FILE_STATUS=1
fi

# Вернуть код в зависимости от результата проверок
if [ $PORT_STATUS -eq 0 ] && [ $FILE_STATUS -eq 0 ]; then
    exit 0
else
    exit 1
fi
```

keepalived.conf
```
global_defs {
    script_user root
}

vrrp_script check_web {
    script "/var/check_web_server.sh"
    interval 3
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface enp0s3
    virtual_router_id 15
    priority 255
    advert_int 1
    virtual_ipaddress {
        192.168.1.250/24
    }
    track_script {
        check_web
    }
}
```

![Название скриншота 7](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_7.png?raw=true)
![Название скриншота 8](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw1_8.png?raw=true)

---
## Дополнительные задания (со звездочкой*)

Эти задания дополнительные (не обязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. Вы можете их выполнить, если хотите глубже и/или шире разобраться в материале.

### Задание 3

- Изучите дополнительно возможность Keepalived, которая называется vrrp_track_file
- Напишите bash-скрипт, который будет менять приоритет внутри файла в зависимости от нагрузки на виртуальную машину (можно разместить данный скрипт в cron и запускать каждую минуту). Рассчитывать приоритет можно, например, на основании Load average.
- Настройте Keepalived на отслеживание данного файла.
- Нагрузите одну из виртуальных машин, которая находится в состоянии MASTER и имеет активный виртуальный IP и проверьте, чтобы через некоторое время она перешла в состояние SLAVE из-за высокой нагрузки и виртуальный IP переехал на другой, менее нагруженный сервер.
- Попробуйте выполнить настройку keepalived на третьем сервере и скорректировать при необходимости формулу так, чтобы плавающий ip адрес всегда был прикреплен к серверу, имеющему наименьшую нагрузку.
- На проверку отправьте получившийся bash-скрипт и конфигурационный файл keepalived, а также скриншоты логов keepalived с серверов при разных нагрузках

`Приведите ответ в свободной форме........`

1. `Заполните здесь этапы выполнения, если требуется ....`
2. `Заполните здесь этапы выполнения, если требуется ....`
3. `Заполните здесь этапы выполнения, если требуется ....`
4. `Заполните здесь этапы выполнения, если требуется ....`
5. `Заполните здесь этапы выполнения, если требуется ....`
6. 

`При необходимости прикрепитe сюда скриншоты
![Название скриншота](ссылка на скриншот)`
