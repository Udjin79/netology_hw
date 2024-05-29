### 1. Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Ответ

```terraform
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "yandex-cloud-token" {
  type        = string
  description = "Input yandex_cloud_token"
}

provider "yandex" {
  token     = var.yandex-cloud-token
  cloud_id  = "1234567890"
  folder_id = "1234567890"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "course-netology-network" {
  name = "course-netology-network"
}

resource "yandex_vpc_subnet" "course-netology-subnet-a" {
  name           = "course-subnet-netology-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.course-netology-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "course-netology-subnet-b" {
  name           = "course-subnet-netology-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.course-netology-network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_compute_instance" "course-vm1" {
  name                      = "course-vm1"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.course-netology-subnet-a.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "course-vm2" {
  name                      = "course-vm2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87e3vsemiab8q1tl0h"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.course-netology-subnet-b.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }

  zone = "ru-central1-b"
}

resource "yandex_alb_target_group" "course-app-group" {
  name = "course-app-target-group"

  target {
    subnet_id = yandex_compute_instance.course-vm1.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.course-vm1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_compute_instance.course-vm2.network_interface.0.subnet_id
    ip_address = yandex_compute_instance.course-vm2.network_interface.0.ip_address
  }
}

output "course-app-target-group-id" {
  value = yandex_alb_target_group.course-app-group.id
}

resource "yandex_alb_backend_group" "course-app-backend-group" {
  name = "course-app-backend-group"
  depends_on = [yandex_alb_target_group.course-app-group]

  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name                   = "course-http-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.course-app-group.id]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "course-app-http-router" {
  name = "course-app-http-router"
  labels = {
    environment = "dev"
  }
}

resource "yandex_alb_virtual_host" "course-app-virtual-host" {
  name           = "course-app-virtual-host"
  http_router_id = yandex_alb_http_router.course-app-http-router.id
  route {
    name = "course-default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.course-app-backend-group.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "course-lb-app" {
  name = "course-load-balancer"
  network_id  = yandex_vpc_network.course-netology-network.id
  security_group_ids = []

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.course-netology-subnet-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.course-netology-subnet-b.id
    }
  }

  listener {
    name = "listener"

    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.course-app-http-router.id
      }
    }
  }

  depends_on = [yandex_alb_http_router.course-app-http-router]
}
```

```powershell
yc application-load-balancer target-group list
+----------------------+-------------------------+--------------+
|          ID          |          NAME           | TARGET COUNT |
+----------------------+-------------------------+--------------+
| ds7el2nhdmhurprs6nnp | course-app-target-group |            2 |
+----------------------+-------------------------+--------------+

yc application-load-balancer backend-group list
+----------------------+--------------------------+---------------------+--------------+---------------+----------------------------+
|          ID          |           NAME           |       CREATED       | BACKEND TYPE | BACKEND COUNT |          AFFINITY          |
+----------------------+--------------------------+---------------------+--------------+---------------+----------------------------+
| ds7lvv59hfge69udnbfu | course-app-backend-group | 2024-05-29 18:53:47 | HTTP         |             1 | connection(source_ip=true) |
+----------------------+--------------------------+---------------------+--------------+---------------+----------------------------+

yc application-load-balancer http-router list
+----------------------+------------------------+-------------+-------------+
|          ID          |          NAME          | VHOST COUNT | ROUTE COUNT |
+----------------------+------------------------+-------------+-------------+
| ds73in5f06df0fmi4dv2 | course-app-http-router |           1 |           1 |
+----------------------+------------------------+-------------+-------------+

yc application-load-balancer load-balancer list
+----------------------+----------------------+-----------+----------------+--------+
|          ID          |         NAME         | REGION ID | LISTENER COUNT | STATUS |
+----------------------+----------------------+-----------+----------------+--------+
| ds7rrg29k0378tq4dt7j | course-load-balancer |           |              1 | ACTIVE |
+----------------------+----------------------+-----------+----------------+--------+
```

```bash
curl http://158.160.171.119/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

---

### 2. Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.

### Ответ

---

### 3. Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Ответ

---

### 4. Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Ответ

---

### 5. Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Ответ
![6](https://github.com/Udjin79/netology_hw/blob/main/img/course_6.png?raw=true)