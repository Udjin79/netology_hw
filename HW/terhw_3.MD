# Домашнее задание к занятию "`Управляющие конструкции в коде Terraform`" - `Исаенков Евгений`

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

1. Изучите проект.
2. Заполните файл personal.auto.tfvars.
3. Инициализируйте проект, выполните код. Он выполнится, даже если доступа к preview нет.

Примечание. Если у вас не активирован preview-доступ к функционалу «Группы безопасности» в Yandex Cloud, запросите доступ у поддержки облачного провайдера. Обычно его выдают в течение 24-х часов.

Приложите скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud или скриншот отказа в предоставлении доступа к preview-версии.

### Ответ

```bash
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.126.0...
- Installed yandex-cloud/yandex v0.126.0 (unauthenticated)
...
...
Terraform has been successfully initialized!

$ terraform validate
Success! The configuration is valid.

$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
...
...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/terhw_3_1.png?raw=true)

---

### Задание 2

1. Создайте файл count-vm.tf. Опишите в нём создание двух **одинаковых** ВМ  web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент **count loop**. Назначьте ВМ созданную в первом задании группу безопасности.(как это сделать узнайте в документации провайдера yandex/compute_instance )
2. Создайте файл for_each-vm.tf. Опишите в нём создание двух ВМ для баз данных с именами "main" и "replica" **разных** по cpu/ram/disk_volume , используя мета-аргумент **for_each loop**. Используйте для обеих ВМ одну общую переменную типа:
```
variable "each_vm" {
  type = list(object({  vm_name=string, cpu=number, ram=number, disk_volume=number }))
}
```  
При желании внесите в переменную все возможные параметры.
4. ВМ из пункта 2.1 должны создаваться после создания ВМ из пункта 2.2.
5. Используйте функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ 2.
6. Инициализируйте проект, выполните код.

### Ответ

count-vm.tf
```bash
resource "yandex_compute_instance" "web" {
  count = 2
  name  = "web-${count.index + 1}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd870suu28d40fqp8srr"
      size     = 20
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.develop.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  depends_on = [yandex_compute_instance.db]
}
```

for_each-vm.tf
```bash
resource "yandex_compute_instance" "db" {
  for_each = { for vm in local.each_vm : vm.vm_name => vm }

  name  = each.value.vm_name

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
  }

  boot_disk {
    initialize_params {
      image_id = "fd870suu28d40fqp8srr"
      size     = each.value.disk_volume
    }
  }

  network_interface {
    subnet_id           = yandex_vpc_subnet.develop.id
    nat                 = true
    security_group_ids  = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}
```

locals.tf
```bash
locals {
  ssh_key = file("~/.ssh/id_rsa.pub")
  each_vm = [
    {
      vm_name     = "main"
      cpu         = 4
      ram         = 8
      disk_volume = 50
    },
    {
      vm_name     = "replica"
      cpu         = 2
      ram         = 4
      disk_volume = 20
    }
  ]
}
```

```bash
$ terraform validate
Success! The configuration is valid.

$ terraform apply
yandex_vpc_network.develop: Refreshing state... [id=********************]
yandex_vpc_subnet.develop: Refreshing state... [id=********************]
yandex_vpc_security_group.example: Refreshing state... [id=********************]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
...
...
...
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

```bash
$ yc compute instance list
+----------------------+---------+---------------+---------+----------------+-------------+
|          ID          |  NAME   |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+---------+---------------+---------+----------------+-------------+
| ******************** | web-1   | ru-central1-a | RUNNING | 89.169.130.99  | 10.0.1.33   |
| ******************** | main    | ru-central1-a | RUNNING | 89.169.133.138 | 10.0.1.21   |
| ******************** | replica | ru-central1-a | RUNNING | 89.169.143.91  | 10.0.1.34   |
| ******************** | web-2   | ru-central1-a | RUNNING | 89.169.142.92  | 10.0.1.4    |
+----------------------+---------+---------------+---------+----------------+-------------+
```

---
### Задание 3

1. Создайте 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf** .
2. Создайте в том же файле **одиночную**(использовать count или for_each запрещено из-за задания №4) ВМ c именем "storage"  . Используйте блок **dynamic secondary_disk{..}** и мета-аргумент for_each для подключения созданных вами дополнительных дисков.

### Ответ

disk_vm.tf
```bash
resource "yandex_compute_disk" "disk" {
  count   = 3
  name  = "disk-${count.index + 1}"
  size  = 1
}

resource "yandex_compute_instance" "storage" {
  name = "storage"
  resources {
        cores           = 2
        memory          = 1
        core_fraction = 5
  }

  boot_disk {
        initialize_params {
        image_id = "fd8g64rcu9fq5kpfqls0"
        }
  }

  dynamic "secondary_disk" {
   for_each = yandex_compute_disk.disk.*.id
   content {
        disk_id = yandex_compute_disk.disk[secondary_disk.key].id
   }
  }
  network_interface {
        subnet_id = yandex_vpc_subnet.develop.id
        nat     = true
  }

  metadata = var.metadata
}
```

```bash
$ yc compute instance list
+----------------------+---------+---------------+---------+----------------+-------------+
|          ID          |  NAME   |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+---------+---------------+---------+----------------+-------------+
| ******************** | web-1   | ru-central1-a | RUNNING | 51.250.77.87   | 10.0.1.37   |
| ******************** | web-2   | ru-central1-a | RUNNING | 89.169.132.139 | 10.0.1.13   |
| ******************** | main    | ru-central1-a | RUNNING | 62.84.125.235  | 10.0.1.35   |
| ******************** | storage | ru-central1-a | RUNNING | 51.250.8.38    | 10.0.1.10   |
| ******************** | replica | ru-central1-a | RUNNING | 51.250.67.124  | 10.0.1.24   |
+----------------------+---------+---------------+---------+----------------+-------------+

```

![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/terhw_3_2.png?raw=true)
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/terhw_3_3.png?raw=true)

---
### Задание 4

1. В файле ansible.tf создайте inventory-файл для ansible.
Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/03/demo).
Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2, т. е. 5 ВМ.
2. Инвентарь должен содержать 3 группы и быть динамическим, т. е. обработать как группу из 2-х ВМ, так и 999 ВМ.
3. Добавьте в инвентарь переменную  [**fqdn**](https://cloud.yandex.ru/docs/compute/concepts/network#hostname).
``` 
[webservers]
web-1 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
web-2 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[databases]
main ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
replica ansible_host<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[storage]
storage ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
```
Пример fqdn: ```web1.ru-central1.internal```(в случае указания переменной hostname(не путать с переменной name)); ```fhm8k1oojmm5lie8i22a.auto.internal```(в случае отсутвия перменной hostname - автоматическая генерация имени,  зона изменяется на auto). нужную вам переменную найдите в документации провайдера или terraform console.
4. Выполните код. Приложите скриншот получившегося файла. 

Для общего зачёта создайте в вашем GitHub-репозитории новую ветку terraform-03. Закоммитьте в эту ветку свой финальный код проекта, пришлите ссылку на коммит.   
**Удалите все созданные ресурсы**.

### Ответ

ansible.tf
```bash
resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/inventory.tftpl",
        {
          webservers = yandex_compute_instance.web,
          databases  = yandex_compute_instance.db,
          storage    = [yandex_compute_instance.storage]
        }
  )
  filename = "${abspath(path.module)}/inventory"
}

resource "null_resource" "web_hosts_provision" {

  # Ждем, пока сервера поднимутся
  depends_on = [yandex_compute_instance.storage, local_file.inventory_cfg]

  # Даем серверам немного времени для старта.
  provisioner "local-exec" {
        command = "sleep 90"
  }

  # Запуск ansible-playbook
  provisioner "local-exec" {
        command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/inventory playbook.yml"
        on_failure = continue # Делаем, чтобы продолжить выполнение, даже если что-то пойдет не так
        environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  }

  triggers = {
        always_run      = "${timestamp()}" # Запускаем всегда, так как время постоянно меняется
        playbook_src_hash  = filemd5("${abspath(path.module)}/test.yml") # Добавляем перезапуск при изменении файла
        ssh_public_key  = var.metadata["ssh-keys"]
  }
}
```

inventory.tftpl
```bash
[webservers]

%{~ for i in webservers ~}
${i.name} ansible_host=${i.network_interface[0].nat_ip_address} fqdn=${i.fqdn}
%{ endfor ~}

[databases]

%{~ for i in databases ~}
${i.name} ansible_host=${i.network_interface[0].nat_ip_address} fqdn=${i.fqdn}
%{ endfor ~}

[storage]

%{~ for i in storage ~}
${i.name} ansible_host=${i.network_interface[0].nat_ip_address} fqdn=${i.fqdn}
%{ endfor ~}
```


```bash
$ cat inventory
[webservers]
web-1 ansible_host=51.250.77.87 fqdn=fhm9rgtuuf4b3to23r5l.auto.internal
web-2 ansible_host=89.169.132.139 fqdn=fhmdrujumndq9hsns4kk.auto.internal

[databases]
main ansible_host=62.84.125.235 fqdn=fhmj6nmvo45b5nvppplm.auto.internal
replica ansible_host=51.250.67.124 fqdn=fhmvq408tsiknvpjrhd2.auto.internal

[storage]
storage ansible_host=51.250.8.38 fqdn=fhml18vcnuqep7r887k8.auto.internal
```
