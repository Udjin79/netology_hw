# Домашнее задание к занятию "`Продвинутые методы работы с Terraform`" - `Исаенков Евгений`

### Чек-лист готовности к домашнему заданию

1. Зарегистрирован аккаунт в Yandex Cloud. Использован промокод на грант.
2. Установлен инструмент Yandex CLI.
3. Исходный код для выполнения задания расположен в директории [**04/src**](https://github.com/netology-code/ter-homeworks/tree/main/04/src).
4. Любые ВМ, использованные при выполнении задания, должны быть прерываемыми, для экономии средств.
5. 
### Ответ

```bash
$ yc --version
Yandex Cloud CLI 0.130.0 linux/amd64

$ terraform --version
Terraform v1.9.2
on linux_amd64
```

---

### Задание 1

1. Возьмите из [демонстрации к лекции готовый код](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) для создания с помощью двух вызовов remote-модуля -> двух ВМ, относящихся к разным проектам(marketing и analytics) используйте labels для обозначения принадлежности.  В файле cloud-init.yml необходимо использовать переменную для ssh-ключа вместо хардкода. Передайте ssh-ключ в функцию template_file в блоке vars ={} .
Воспользуйтесь [**примером**](https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/). Обратите внимание, что ssh-authorized-keys принимает в себя список, а не строку.
3. Добавьте в файл cloud-init.yml установку nginx.
4. Предоставьте скриншот подключения к консоли и вывод команды ```sudo nginx -t```, скриншот консоли ВМ yandex cloud с их метками. Откройте terraform console и предоставьте скриншот содержимого модуля. Пример: > module.marketing_vm

### Ответ

```bash
$ terraform validate
Success! The configuration is valid.

$ terraform plan
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=********************]
module.test-vm.data.yandex_compute_image.my_image: Reading...
module.test-vm.data.yandex_compute_image.my_image: Read complete after 2s [id=********************]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
...
...
...

$ terraform apply
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=********************]
module.test-vm.data.yandex_compute_image.my_image: Reading...
module.test-vm.data.yandex_compute_image.my_image: Read complete after 2s [id=********************]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
...
...
...
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

$ yc compute instances list
+----------------------+---------------+---------------+---------+---------------+-------------+
|          ID          |     NAME      |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+---------------+---------------+---------+---------------+-------------+
| ******************** | develop-web-1 | ru-central1-a | RUNNING | 89.169.146.6  | 10.0.1.14   |
| ******************** | develop-web-0 | ru-central1-a | RUNNING | 89.169.144.44 | 10.0.1.23   |
+----------------------+---------------+---------------+---------+---------------+-------------+

$ ssh ubuntu@89.169.146.6

ubuntu@develop-web-1:~$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

module.test-vm
```bash
> module.test-vm
{
  "external_ip_address" = [
    "89.169.144.44",
    "89.169.146.6",
  ]
  "fqdn" = [
    "develop-web-0.ru-central1.internal",
    "develop-web-1.ru-central1.internal",
  ]
  "internal_ip_address" = [
    "10.0.1.23",
    "10.0.1.14",
  ]
  "labels" = [
    tomap({
      "env" = "develop"
      "project" = "undefined"
    }),
    tomap({
      "env" = "develop"
      "project" = "undefined"
    }),
  ]
  "network_interface" = [
    tolist([
      {
        "dns_record" = tolist([])
        "index" = 0
        "ip_address" = "10.0.1.23"
        "ipv4" = true
        "ipv6" = false
        "ipv6_address" = ""
        "ipv6_dns_record" = tolist([])
        "mac_address" = "d0:0d:1b:53:d0:d5"
        "nat" = true
        "nat_dns_record" = tolist([])
        "nat_ip_address" = "89.169.144.44"
        "nat_ip_version" = "IPV4"
        "security_group_ids" = toset([])
        "subnet_id" = "********************"
      },
    ]),
    tolist([
      {
        "dns_record" = tolist([])
        "index" = 0
        "ip_address" = "10.0.1.14"
        "ipv4" = true
        "ipv6" = false
        "ipv6_address" = ""
        "ipv6_dns_record" = tolist([])
        "mac_address" = "d0:0d:13:db:f1:a9"
        "nat" = true
        "nat_dns_record" = tolist([])
        "nat_ip_address" = "89.169.146.6"
        "nat_ip_version" = "IPV4"
        "security_group_ids" = toset([])
        "subnet_id" = "********************"
      },
    ]),
  ]
}
```
---

### Задание 2

1. Напишите локальный модуль vpc, который будет создавать 2 ресурса: **одну** сеть и **одну** подсеть в зоне, объявленной при вызове модуля, например: ```ru-central1-a```.
2. Вы должны передать в модуль переменные с названием сети, zone и v4_cidr_blocks.
3. Модуль должен возвращать в root module с помощью output информацию о yandex_vpc_subnet. Пришлите скриншот информации из terraform console о своем модуле. Пример: > module.vpc_dev  
4. Замените ресурсы yandex_vpc_network и yandex_vpc_subnet созданным модулем. Не забудьте передать необходимые параметры сети из модуля vpc в модуль с виртуальной машиной.
5. Сгенерируйте документацию к модулю с помощью terraform-docs.
 
Пример вызова

```
module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  zone = "ru-central1-a"
  cidr = "10.0.1.0/24"
}
```

### Ответ

vpc main.tf
```bash
resource "yandex_vpc_network" "network" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "${var.vpc_name}-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = var.default_cidr
}
```

vps variables.tf
```bash
variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the VPC subnet"
  type        = string
}

variable "zone" {
  description = "The availability zone where the subnet will be created"
  type        = string
}

variable "v4_cidr_blocks" {
  description = "IPv4 CIDR blocks for the subnet"
  type        = list(string)
}
```

vpс outputs.tf
```bash
output "subnet_id" {
  description = "The ID of the created subnet"
  value       = yandex_vpc_subnet.subnet.id
}

output "network_id" {
  description = "The ID of the created network"
  value       = yandex_vpc_network.network.id
}
```

terraform console
```bash
$ terraform console
> module.vpc
{
  "network_id" = "enp0jjn6bno1nfk98j2k"
  "subnet_id" = "e9bb9p4r6g33ahdv9dt5"
}
>
```

Docs generation with terraform-docs
```bash
$ ls
main.tf  outputs.tf  variables.tf
$ ls
README.md  main.tf  outputs.tf  variables.tf
```

```markdown
$ cat README.md
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.126.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_vpc_network.network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | n/a | `any` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | n/a | `any` | n/a | yes |
| <a name="input_v4_cidr_blocks"></a> [v4\_cidr\_blocks](#input\_v4\_cidr\_blocks) | n/a | `list(string)` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | The ID of the network |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
```

---

### Задание 3

1. Выведите список ресурсов в стейте.
2. Полностью удалите из стейта модуль vpc.
3. Полностью удалите из стейта модуль vm.
4. Импортируйте всё обратно. Проверьте terraform plan. Значимых(!!) изменений быть не должно.
Приложите список выполненных команд и скриншоты процессы.

### Ответ

1. Список ресурсов в стейте
```bash
$ terraform state list
data.template_file.cloudinit
module.test-vm.data.yandex_compute_image.my_image
module.test-vm.yandex_compute_instance.vm[0]
module.test-vm.yandex_compute_instance.vm[1]
module.vpc.yandex_vpc_network.network
module.vpc.yandex_vpc_subnet.subnet
```

2. Удаление модуля vpc
```bash
$ terraform state rm module.vpc
Removed module.vpc.yandex_vpc_network.network
Removed module.vpc.yandex_vpc_subnet.subnet
Successfully removed 2 resource instance(s).

$ terraform state list
data.template_file.cloudinit
module.test-vm.data.yandex_compute_image.my_image
module.test-vm.yandex_compute_instance.vm[0]
module.test-vm.yandex_compute_instance.vm[1]
```

3. Удаление модуля vm
```bash
$ terraform state rm module.test-vm
Removed module.test-vm.data.yandex_compute_image.my_image
Removed module.test-vm.yandex_compute_instance.vm[0]
Removed module.test-vm.yandex_compute_instance.vm[1]
Successfully removed 3 resource instance(s).

$ terraform state list
data.template_file.cloudinit
```

4. Импорт обратно
```bash
$ yc vpc network list
+----------------------+---------+
|          ID          |  NAME   |
+----------------------+---------+
| enp0jjn6bno1nfk98j2k | develop |
+----------------------+---------+

$ yc vpc subnet list
+----------------------+-----------------------+----------------------+----------------+---------------+---------------+
|          ID          |         NAME          |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |     RANGE     |
+----------------------+-----------------------+----------------------+----------------+---------------+---------------+
| e9bb9p4r6g33ahdv9dt5 | develop-ru-central1-a | enp0jjn6bno1nfk98j2k |                | ru-central1-a | [10.0.1.0/24] |
+----------------------+-----------------------+----------------------+----------------+---------------+---------------+

$ yc compute instances list
+----------------------+---------------+---------------+---------+---------------+-------------+
|          ID          |     NAME      |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+---------------+---------------+---------+---------------+-------------+
| fhmjrfoqitlpqgv0t98b | develop-web-1 | ru-central1-a | RUNNING | 89.169.146.6  | 10.0.1.14   |
| fhmraf8dborjat0edfrn | develop-web-0 | ru-central1-a | RUNNING | 89.169.144.44 | 10.0.1.23   |
+----------------------+---------------+---------------+---------+---------------+-------------+

$ terraform import 'module.vpc.yandex_vpc_network.network' enp0jjn6bno1nfk98j2k
...
Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

$ terraform import 'module.vpc.yandex_vpc_subnet.subnet' e9bb9p4r6g33ahdv9dt5
...
Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

$ terraform import 'module.test-vm.yandex_compute_instance.vm[0]' fhmraf8dborjat0edfrn
...
Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

$ terraform import 'module.test-vm.yandex_compute_instance.vm[1]' fhmjrfoqitlpqgv0t98b
...
Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

$ terraform plan
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=f4cae70db665a3e983e4c991c7cb5d05b28cb7f08dd56571f57841fb9be69ae0]
module.test-vm.data.yandex_compute_image.my_image: Reading...
module.vpc.yandex_vpc_network.network: Refreshing state... [id=enp0jjn6bno1nfk98j2k]
module.test-vm.data.yandex_compute_image.my_image: Read complete after 1s [id=fd8ue2nph2v23d0rtfug]
module.vpc.yandex_vpc_subnet.subnet: Refreshing state... [id=e9bb9p4r6g33ahdv9dt5]
module.test-vm.yandex_compute_instance.vm[1]: Refreshing state... [id=fhmjrfoqitlpqgv0t98b]
module.test-vm.yandex_compute_instance.vm[0]: Refreshing state... [id=fhmraf8dborjat0edfrn]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.test-vm.yandex_compute_instance.vm[0] will be updated in-place
  ~ resource "yandex_compute_instance" "vm" {
      + allow_stopping_for_update = true
        id                        = "fhmraf8dborjat0edfrn"
        name                      = "develop-web-0"
        # (14 unchanged attributes hidden)

        # (6 unchanged blocks hidden)
    }

  # module.test-vm.yandex_compute_instance.vm[1] will be updated in-place
  ~ resource "yandex_compute_instance" "vm" {
      + allow_stopping_for_update = true
        id                        = "fhmjrfoqitlpqgv0t98b"
        name                      = "develop-web-1"
        # (14 unchanged attributes hidden)

        # (6 unchanged blocks hidden)
    }

Plan: 0 to add, 2 to change, 0 to destroy.
...
```
