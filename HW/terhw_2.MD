# Домашнее задание к занятию "`Основы Terraform. Yandex Cloud`" - `Исаенков Евгений`

### Чек-лист готовности к домашнему заданию

1. Зарегистрирован аккаунт в Yandex Cloud. Использован промокод на грант.
2. Установлен инструмент Yandex CLI.
3. Исходный код для выполнения задания расположен в директории [**02/src**](https://github.com/netology-code/ter-homeworks/tree/main/02/src).

В качестве ответа всегда полностью прикладывайте ваш terraform-код в git.
Убедитесь что ваша версия **Terraform** ~>1.8.4

### Ответ

```bash
$ yc --version
Yandex Cloud CLI 0.130.0 linux/amd64

$ ls
console.tf  locals.tf  main.tf  outputs.tf  providers.tf  variables.tf

$ terraform --version
Terraform v1.9.2
on linux_amd64
```

---

### Задание 1

1. Изучите проект. В файле variables.tf объявлены переменные для Yandex provider.
2. Создайте сервисный аккаунт и ключ. [service_account_key_file](https://terraform-provider.yandexcloud.net).
4. Сгенерируйте новый или используйте свой текущий ssh-ключ. Запишите его открытую(public) часть в переменную **vms_ssh_public_root_key**.
5. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.
6. Подключитесь к консоли ВМ через ssh и выполните команду ``` curl ifconfig.me```.
Примечание: К OS ubuntu "out of a box, те из коробки" необходимо подключаться под пользователем ubuntu: ```"ssh ubuntu@vm_ip_address"```. Предварительно убедитесь, что ваш ключ добавлен в ssh-агент: ```eval $(ssh-agent) && ssh-add``` Вы познакомитесь с тем как при создании ВМ создать своего пользователя в блоке metadata в следующей лекции.;
8. Ответьте, как в процессе обучения могут пригодиться параметры ```preemptible = true``` и ```core_fraction=5``` в параметрах ВМ.

В качестве решения приложите:

- скриншот ЛК Yandex Cloud с созданной ВМ, где видно внешний ip-адрес;
- скриншот консоли, curl должен отобразить тот же внешний ip-адрес;
- ответы на вопросы.

### Ответ

```bash
$ yc iam key create --service-account-name netology --output key.json
id: ******************
service_account_id: ******************
created_at: "2024-08-04T15:48:32.489001122Z"
key_algorithm: RSA_2048

$ yc config profile create netology-profile
Profile 'netology-profile' created and activated

$ yc config set service-account-key key.json

$ yc iam create-token
******************************

$ terraform init
Initializing the backend...
...
...
...
Terraform has been successfully initialized!

$ terraform validate
Success! The configuration is valid.
```

```bash
terraform apply
data.yandex_compute_image.ubuntu: Reading...
...
...
...
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_compute_instance.platform: Creating...
yandex_compute_instance.platform: Still creating... [10s elapsed]
yandex_compute_instance.platform: Still creating... [20s elapsed]
yandex_compute_instance.platform: Still creating... [30s elapsed]
yandex_compute_instance.platform: Creation complete after 38s [id=************]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

```bash
$ yc compute instance list
+----------------------+-------------------------------+---------------+---------+---------------+-------------+
|          ID          |             NAME              |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+-------------------------------+---------------+---------+---------------+-------------+
| ******************** | netology-develop-platform-web | ru-central1-a | RUNNING | 51.250.86.185 | 10.0.1.26   |
+----------------------+-------------------------------+---------------+---------+---------------+-------------+

$ ssh ubuntu@51.250.86.185

$ curl ifconfig.me
51.250.86.185
```

Ответы на вопросы:

1. 
preemptible = true. Что мы получаем:
- Экономия средств. Preemptible ВМ значительно дешевле обычных, и в учебных целях, где не требуется постоянная доступность ВМ, это допустимо.
- Подходят для тестов и экспериментов т.к. можем запускать временные задания, тесты и не бояться потери ВМ.

core_fraction = 5. Что мы получаем:
- Оптимизация использования ресурсов, т.к. позволяет использовать часть ядра процессора, что снижает затраты на вычислительные ресурсы.
- Подходит для задач, не требующих полного использования процессорного ядра, таких как сбор данных, лёгкие веб-приложения

Описание ошибок в конфигах:

- platform_id = "standart-v4"  # Неверно
- platform_id = "standard-v1"  # Верно

Причины ошибок:
- В Yandex Cloud нет платформы с именем "standart-v4". Мной была выбрана платформа "standard-v1".
- Синтаксическая ошибка в слове "standard":
- Изменил количества ядер, на 2, т.к. ни одна из предоставленных платформ не поддерживает 1 ядро.
[Ссылка на документацию](https://yandex.cloud/en/docs/compute/concepts/vm-platforms)

---

### Задание 2

1. Замените все хардкод-**значения** для ресурсов **yandex_compute_image** и **yandex_compute_instance** на **отдельные** переменные. К названиям переменных ВМ добавьте в начало префикс **vm_web_** .  Пример: **vm_web_name**.
2. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их **default** прежними значениями из main.tf. 
3. Проверьте terraform plan. Изменений быть не должно. 

### Ответ

main.tf
```bash
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id

  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
```

variables.tf
```bash
...
...
...
variable "vm_web_name" {
  description = "vm_web_name"
  type        = string
  default     = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  description = "vm_web_platform_id"
  type        = string
  default     = "standard-v1"
}

variable "vm_web_cores" {
  description = "vm_web_cores"
  type        = number
  default     = 2
}

variable "vm_web_memory" {
  description = "vm_web_memory"
  type        = number
  default     = 1
}

variable "vm_web_core_fraction" {
  description = "vm_web_core_fraction"
  type        = number
  default     = 5
}

variable "vm_web_preemptible" {
  description = "vm_web_preemptible"
  type        = bool
  default     = true
}
```

```bash
$ terraform plan
data.yandex_compute_image.ubuntu: Reading...
yandex_vpc_network.develop: Refreshing state... [id=****************]
data.yandex_compute_image.ubuntu: Read complete after 1s [id==****************]]
yandex_vpc_subnet.develop: Refreshing state... [id==****************]]
yandex_compute_instance.platform: Refreshing state... [id==****************]]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
---

### Задание 3

1. Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: **"netology-develop-platform-db"** ,  ```cores  = 2, memory = 2, core_fraction = 20```. Объявите её переменные с префиксом **vm_db_** в том же файле ('vms_platform.tf').  ВМ должна работать в зоне "ru-central1-b"
3. Примените изменения.

### Ответ

vms_platform.tf
```bash
variable "vm_web_name" {
  type    = string
  default = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_web_cores" {
  type    = number
  default = 2
}

variable "vm_web_memory" {
  type    = number
  default = 1
}

variable "vm_web_core_fraction" {
  type    = number
  default = 5
}

variable "vm_web_preemptible" {
  type    = bool
  default = true
}

variable "vm_db_name" {
  type    = string
  default = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_db_cores" {
  type    = number
  default = 2
}

variable "vm_db_memory" {
  type    = number
  default = 2
}

variable "vm_db_core_fraction" {
  type    = number
  default = 20
}

variable "vm_db_preemptible" {
  type    = bool
  default = true
}
```

main.tf
```bash
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "${var.vpc_name}-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.cidr_block_a
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "${var.vpc_name}-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.cidr_block_b
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id

  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}

resource "yandex_compute_instance" "db" {
  name        = var.vm_db_name
  platform_id = var.vm_db_platform_id
  zone        = "ru-central1-b"

  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = var.vm_db_preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }
}
```

```bash
$ yc compute instance list
+----------------------+-------------------------------+---------------+---------+--------------+-------------+
|          ID          |             NAME              |    ZONE ID    | STATUS  | EXTERNAL IP  | INTERNAL IP |
+----------------------+-------------------------------+---------------+---------+--------------+-------------+
| ******************** | netology-develop-platform-db  | ru-central1-b | RUNNING | 51.250.27.44 | 10.0.3.13   |
| ******************** | netology-develop-platform-web | ru-central1-a | RUNNING | 51.250.0.147 | 10.0.2.11   |
+----------------------+-------------------------------+---------------+---------+--------------+-------------+
```

---

### Задание 4

1. Объявите в файле outputs.tf **один** output , содержащий: instance_name, external_ip, fqdn для каждой из ВМ в удобном лично для вас формате.(без хардкода!!!)
2. Примените изменения.

В качестве решения приложите вывод значений ip-адресов команды ```terraform output```.

### Ответ

Я решил  вывести информацию о виртуальных машинах, включая их имена, внешние IP-адреса и FQDN.

outputs.tf
```bash
output "vm_info" {
  value = {
    vm_web = {
      instance_name = yandex_compute_instance.platform.name
      external_ip   = yandex_compute_instance.platform.network_interface.0.nat_ip_address
      fqdn          = yandex_compute_instance.platform.fqdn
    }
    vm_db = {
      instance_name = yandex_compute_instance.db.name
      external_ip   = yandex_compute_instance.db.network_interface.0.nat_ip_address
      fqdn          = yandex_compute_instance.db.fqdn
    }
  }
}
```

```bash
$ terraform apply
data.yandex_compute_image.ubuntu: Reading...
yandex_vpc_network.develop: Refreshing state... [id=********************]
data.yandex_compute_image.ubuntu: Read complete after 2s [id=********************]
yandex_vpc_subnet.develop_b: Refreshing state... [id=********************]
yandex_vpc_subnet.develop_a: Refreshing state... [id=********************]
yandex_compute_instance.db: Refreshing state... [id=********************]
yandex_compute_instance.platform: Refreshing state... [id=********************]

Changes to Outputs:
  + vm_info = {
      + vm_db  = {
          + external_ip   = "51.250.27.44"
          + fqdn          = "epdab7mp500nc7t4s7lo.auto.internal"
          + instance_name = "netology-develop-platform-db"
        }
      + vm_web = {
          + external_ip   = "51.250.0.147"
          + fqdn          = "fhmurgv6ai0o65vk5aas.auto.internal"
          + instance_name = "netology-develop-platform-web"
        }
    }

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

vm_info = {
  "vm_db" = {
    "external_ip" = "51.250.27.44"
    "fqdn" = "epdab7mp500nc7t4s7lo.auto.internal"
    "instance_name" = "netology-develop-platform-db"
  }
  "vm_web" = {
    "external_ip" = "51.250.0.147"
    "fqdn" = "fhmurgv6ai0o65vk5aas.auto.internal"
    "instance_name" = "netology-develop-platform-web"
  }
}
$ terraform output
vm_info = {
  "vm_db" = {
    "external_ip" = "51.250.27.44"
    "fqdn" = "epdab7mp500nc7t4s7lo.auto.internal"
    "instance_name" = "netology-develop-platform-db"
  }
  "vm_web" = {
    "external_ip" = "51.250.0.147"
    "fqdn" = "fhmurgv6ai0o65vk5aas.auto.internal"
    "instance_name" = "netology-develop-platform-web"
  }
}
```

---

### Задание 5

1. В файле locals.tf опишите в **одном** local-блоке имя каждой ВМ, используйте интерполяцию ${..} с НЕСКОЛЬКИМИ переменными по примеру из лекции.
2. Замените переменные внутри ресурса ВМ на созданные вами local-переменные.
3. Примените изменения.

### Ответ

В locals.tf я создал переменные vm_web_name и vm_db_name, которые содержат имя каждой ВМ. В main.tf я заменил переменные vm_web_name и vm_db_name на созданные local-переменные.

locals.tf
```bash
variable "env" {
  type    = string
  default = "develop"
}

variable "project" {
  type    = string
  default = "platform"
}

variable "role_web" {
  type    = string
  default = "web"
}

variable "role_db" {
  type    = string
  default = "db"
}

locals {
  vm_web_name = "netology-${var.env}-${var.project}-${var.role_web}"
  vm_db_name  = "netology-${var.env}-${var.project}-${var.role_db}"
}
```

main.tf
```bash
...
resource "yandex_compute_instance" "platform" {
  name        = local.vm_web_name
  platform_id = var.vm_web_platform_id
...
...
...
resource "yandex_compute_instance" "db" {
  name        = local.vm_db_name
  platform_id = var.vm_db_platform_id
  zone        = "ru-central1-b"
...
```

При применении изменений terraform не выдал информации о том, что имена изменены, что означает, что изменения в tf файлах были применены успешно.

```bash
 terraform plan
data.yandex_compute_image.ubuntu: Reading...
yandex_vpc_network.develop: Refreshing state... [id==********************]]
data.yandex_compute_image.ubuntu: Read complete after 3s [id==********************]]
yandex_vpc_subnet.develop_a: Refreshing state... [id==********************]]
yandex_vpc_subnet.develop_b: Refreshing state... [id==********************]]
yandex_compute_instance.platform: Refreshing state... [id==********************]]
yandex_compute_instance.db: Refreshing state... [id==********************]]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```



---

### Задание 6

1. Вместо использования трёх переменных  ".._cores",".._memory",".._core_fraction" в блоке  resources {...}, объедините их в единую map-переменную **vms_resources** и  внутри неё конфиги обеих ВМ в виде вложенного map(object).  
   ```
   пример из terraform.tfvars:
   vms_resources = {
     web={
       cores=2
       memory=2
       core_fraction=5
       hdd_size=10
       hdd_type="network-hdd"
       ...
     },
     db= {
       cores=2
       memory=4
       core_fraction=20
       hdd_size=10
       hdd_type="network-ssd"
       ...
     }
   }
   ```
3. Создайте и используйте отдельную map(object) переменную для блока metadata, она должна быть общая для всех ваших ВМ.
   ```
   пример из terraform.tfvars:
   metadata = {
     serial-port-enable = 1
     ssh-keys           = "ubuntu:ssh-ed25519 AAAAC..."
   }
   ```  
  
5. Найдите и закоментируйте все, более не используемые переменные проекта.
6. Проверьте terraform plan. Изменений быть не должно.

### Ответ

```bash
variable "vm_web_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_web_preemptible" {
  type    = bool
  default = true
}

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "vm_db_preemptible" {
  type    = bool
  default = true
}

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

variable "metadata" {
  type = map(string)
  default = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:ssh-ed25519 AAAA***********************"
  }
}

# variable "vm_web_cores" {
#   type    = number
#   default = 2
# }

# variable "vm_web_memory" {
#   type    = number
#   default = 1
# }

# variable "vm_web_core_fraction" {
#   type    = number
#   default = 5
# }

# variable "vm_db_cores" {
#   type    = number
#   default = 2
# }

# variable "vm_db_memory" {
#   type    = number
#   default = 2
# }

# variable "vm_db_core_fraction" {
#   type    = number
#   default = 20
# }
```

```bash
...
resource "yandex_compute_instance" "platform" {
  name        = local.vm_web_name
  platform_id = var.vm_web_platform_id

  resources {
    cores         = var.vms_resources["web"].cores
    memory        = var.vms_resources["web"].memory
    core_fraction = var.vms_resources["web"].core_fraction
  }
...
...
...
resource "yandex_compute_instance" "db" {
  name        = local.vm_db_name
  platform_id = var.vm_db_platform_id
  zone        = "ru-central1-b"

  resources {
    cores         = var.vms_resources["db"].cores
    memory        = var.vms_resources["db"].memory
    core_fraction = var.vms_resources["db"].core_fraction
  }
...  
```

```bash
$ terraform plan
data.yandex_compute_image.ubuntu: Reading...
yandex_vpc_network.develop: Refreshing state... [id=***********************]
data.yandex_compute_image.ubuntu: Read complete after 3s [id=***********************]
yandex_vpc_subnet.develop_b: Refreshing state... [id=***********************]
yandex_vpc_subnet.develop_a: Refreshing state... [id=***********************]
yandex_compute_instance.db: Refreshing state... [id=***********************]
yandex_compute_instance.platform: Refreshing state... [id=***********************]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
---

### Задание 7*

Изучите содержимое файла console.tf. Откройте terraform console, выполните следующие задания: 

1. Напишите, какой командой можно отобразить **второй** элемент списка test_list.
2. Найдите длину списка test_list с помощью функции length(<имя переменной>).
3. Напишите, какой командой можно отобразить значение ключа admin из map test_map.
4. Напишите interpolation-выражение, результатом которого будет: "John is admin for production server based on OS ubuntu-20-04 with X vcpu, Y ram and Z virtual disks", используйте данные из переменных test_list, test_map, servers и функцию length() для подстановки значений.

**Примечание**: если не догадаетесь как вычленить слово "admin", погуглите: "terraform get keys of map"

В качестве решения предоставьте необходимые команды и их вывод.

### Ответ

Используем 1 для получения 2 элемента, т.к. индексация начинается с 0.
```bash
$ terraform console
> local.test_list[1]
"staging"
> length(local.test_list)
3
> local.test_map["admin"]
"John"
> "${local.test_map["admin"]} is admin for ${local.test_list[2]} server based on OS ${local.servers.production.image} with ${local.servers.production.cpu} vcpu, ${local.servers.production.ram} ram and ${length(local.servers.production.disks)} virtual disks"
"John is admin for production server based on OS ubuntu-20-04 with 10 vcpu, 40 ram and 4 virtual disks"
```

---

### Задание 8*

1. Напишите и проверьте переменную test и полное описание ее type в соответствии со значением из terraform.tfvars:
```
test = [
  {
    "dev1" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117",
      "10.0.1.7",
    ]
  },
  {
    "dev2" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@84.252.140.88",
      "10.0.2.29",
    ]
  },
  {
    "prod1" = [
      "ssh -o 'StrictHostKeyChecking=no' ubuntu@51.250.2.101",
      "10.0.1.30",
    ]
  },
]
```
2. Напишите выражение в terraform console, которое позволит вычленить строку "ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117" из этой переменной.

### Ответ

Добавил переменную test в terraform.tfvars и описал ее в variables.tf

variables.tf
```bash
variable "test" {
  type = list(object({
    dev1 = optional(list(string))
    dev2 = optional(list(string))
    prod1 = optional(list(string))
  }))
}
```

```bash
$ terraform console
> var.test[0].dev1[0]
"ssh -o 'StrictHostKeyChecking=no' ubuntu@62.84.124.117"
```

---

### Задание 9*

Используя инструкцию https://cloud.yandex.ru/ru/docs/vpc/operations/create-nat-gateway#tf_1, настройте для ваших ВМ nat_gateway. Для проверки уберите внешний IP адрес (nat=false) у ваших ВМ и проверьте доступ в интернет с ВМ, подключившись к ней через serial console. Для подключения предварительно через ssh измените пароль пользователя: ```sudo passwd ubuntu```

### Правила приёма работы

Для подключения предварительно через ssh измените пароль пользователя: sudo passwd ubuntu
В качестве результата прикрепите ссылку на MD файл с описанием выполненой работы в вашем репозитории. Так же в репозитории должен присутсвовать ваш финальный код проекта.

### Ответ


---

