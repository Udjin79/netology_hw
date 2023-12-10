# Домашнее задание к занятию "`Отказоустойчивость в облаке`" - `Исаенков Евгений`

---

### Задание 1

Возьмите за основу решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке».

1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:
- создаст 2 идентичные виртуальные машины. Используйте аргумент count для создания таких ресурсов;
- создаст таргет-группу. Поместите в неё созданные на шаге 1 виртуальные машины;
- создаст сетевой балансировщик нагрузки, который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин.

Рекомендуем изучить документацию сетевого балансировщика нагрузки для того, чтобы было понятно, что вы сделали.

2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.
3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что:
- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.
4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

В качестве результата пришлите:
1. Terraform Playbook.
2. Скриншот статуса балансировщика и целевой группы.
3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.


```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "yandex_cloud_token" {
  type        = string
  description = "Input yandex_cloud_token"
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = "b1glclf9vqrlnq5vce1a"
  folder_id = "b1g66egctakfn2stnfi7"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "netology-network" {
  name = "netology-network"
}

resource "yandex_vpc_subnet" "netology-subnet" {
  name           = "subnet-netology"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "vm" {
  count = 2

  name = "vm${count.index + 1}"

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
    subnet_id = yandex_vpc_subnet.netology-subnet.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

resource "yandex_lb_target_group" "app_group" {
  name = "app-target-group"

  dynamic "target" {
    for_each = [for s in yandex_compute_instance.vm : {
      address   = s.network_interface.0.ip_address
      subnet_id = s.network_interface.0.subnet_id
    }]

    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }

}

resource "yandex_lb_network_load_balancer" "lb-app" {
  name = "loadbalancer"
  type = "external"

  listener {
    name        = "listener"
    port        = 80
    target_port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.app_group.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
```

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw4_1.png?raw=true)
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw4_2.png?raw=true)
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw4_3.png?raw=true)
![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/sflt26_hw4_4.png?raw=true)

---
## Дополнительные задания (со звездочкой*)

### Задание 2

1. Теперь вместо создания виртуальных машин создайте группу виртуальных машин с балансировщиком нагрузки.
2. Nginx нужно будет поставить тоже автоматизированно. Для этого вам нужно будет подложить файл установки Nginx в user-data-ключ метадаты виртуальной машины.
- Пример файла установки Nginx.
- Как подставлять файл в метадату виртуальной машины.
3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что:
- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.
4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

В качестве результата пришлите
1. Terraform Playbook.
2. Скриншот статуса балансировщика и целевой группы.
3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.


`Приведите ответ в свободной форме........`

1. `Заполните здесь этапы выполнения, если требуется ....`
2. `Заполните здесь этапы выполнения, если требуется ....`
3. `Заполните здесь этапы выполнения, если требуется ....`
4. `Заполните здесь этапы выполнения, если требуется ....`
5. `Заполните здесь этапы выполнения, если требуется ....`
6. 

`При необходимости прикрепитe сюда скриншоты
![Название скриншота](ссылка на скриншот)`
