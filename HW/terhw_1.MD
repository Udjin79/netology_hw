# Домашнее задание к занятию "`Введение в Terraform`" - `Исаенков Евгений`

### Чек-лист готовности к домашнему заданию

1. Скачайте и установите **Terraform** версии ~>1.8.4 . Приложите скриншот вывода команды ```terraform --version```.
2. Скачайте на свой ПК этот git-репозиторий. Исходный код для выполнения задания расположен в директории **01/src**.
3. Убедитесь, что в вашей ОС установлен docker.

### Ответ

```bash
$ terraform --version
Terraform v1.9.2
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.9.3. You can update by downloading from https://www.terraform.io/downloads.html

$ docker --version
Docker version 27.0.3, build 7d4bcd8

$ git clone https://github.com/netology-code/ter-homeworks.git
Cloning into 'ter-homeworks'...
remote: Enumerating objects: 1376, done.
remote: Counting objects: 100% (308/308), done.
remote: Compressing objects: 100% (152/152), done.
remote: Total 1376 (delta 187), reused 238 (delta 151), pack-reused 1068
Receiving objects: 100% (1376/1376), 311.03 KiB | 1.30 MiB/s, done.
Resolving deltas: 100% (705/705), done.
```

---

### Задание 1

1. Перейдите в каталог [**src**](https://github.com/netology-code/ter-homeworks/tree/main/01/src). Скачайте все необходимые зависимости, использованные в проекте. 
2. Изучите файл **.gitignore**. В каком terraform-файле, согласно этому .gitignore, допустимо сохранить личную, секретную информацию?(логины,пароли,ключи,токены итд)
3. Выполните код проекта. Найдите  в state-файле секретное содержимое созданного ресурса **random_password**, пришлите в качестве ответа конкретный ключ и его значение.
4. Раскомментируйте блок кода, примерно расположенный на строчках 29–42 файла **main.tf**.
Выполните команду ```terraform validate```. Объясните, в чём заключаются намеренно допущенные ошибки. Исправьте их.
5. Выполните код. В качестве ответа приложите: исправленный фрагмент кода и вывод команды ```docker ps```.
6. Замените имя docker-контейнера в блоке кода на ```hello_world```. Не перепутайте имя контейнера и имя образа. Мы всё ещё продолжаем использовать name = "nginx:latest". Выполните команду ```terraform apply -auto-approve```.
Объясните своими словами, в чём может быть опасность применения ключа  ```-auto-approve```. Догадайтесь или нагуглите зачем может пригодиться данный ключ? В качестве ответа дополнительно приложите вывод команды ```docker ps```.
8. Уничтожьте созданные ресурсы с помощью **terraform**. Убедитесь, что все ресурсы удалены. Приложите содержимое файла **terraform.tfstate**. 
9. Объясните, почему при этом не был удалён docker-образ **nginx:latest**. Ответ **ОБЯЗАТЕЛЬНО НАЙДИТЕ В ПРЕДОСТАВЛЕННОМ КОДЕ**, а затем **ОБЯЗАТЕЛЬНО ПОДКРЕПИТЕ** строчкой из документации [**terraform провайдера docker**](https://docs.comcloud.xyz/providers/kreuzwerker/docker/latest/docs).  (ищите в классификаторе resource docker_image )

### Ответ

1. 

```bash
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 3.0.1"...
- Finding latest version of hashicorp/random...
- Installing hashicorp/random v3.6.2...
- Installed hashicorp/random v3.6.2 (unauthenticated)
- Installing kreuzwerker/docker v3.0.2...
- Installed kreuzwerker/docker v3.0.2 (unauthenticated)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

╷
│ Warning: Incomplete lock file information for providers
│
│ Due to your customized provider installation methods, Terraform was forced to calculate lock file checksums locally for the following providers:
│   - hashicorp/random
│   - kreuzwerker/docker
│
│ The current .terraform.lock.hcl file only includes checksums for linux_amd64, so Terraform running on another platform will fail to install these providers.
│
│ To calculate additional checksums for another platform, run:
│   terraform providers lock -platform=linux_amd64
│ (where linux_amd64 is the platform to generate)
╵
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

2. Согласно представленному файлу .gitignore допустимо сохранить личную, секретную информацию В файле personal.auto.tfvars.

3. 

```bash
$ terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_password.random_string will be created
  + resource "random_password" "random_string" {
      + bcrypt_hash = (sensitive value)
      + id          = (known after apply)
      + length      = 16
      + lower       = true
      + min_lower   = 1
      + min_numeric = 1
      + min_special = 0
      + min_upper   = 1
      + number      = true
      + numeric     = true
      + result      = (sensitive value)
      + special     = false
      + upper       = true
    }

Plan: 1 to add, 0 to change, 0 to destroy.
random_password.random_string: Creating...
random_password.random_string: Creation complete after 0s [id=none]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

```json
      "mode": "managed",
      "type": "random_password",
      "name": "random_string",
      "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
      "instances": [
        {
          "schema_version": 3,
          "attributes": {
            ...
            "result": "VvmV2JmkHqtXRrrV",
            ...
          },
          ...
```

4. 

- В docker_container имя ресурса не может начинаться с цифры.
- Неправильный атрибут name в docker_container. Должно быть правильное имя ресурса и атрибут.
- Отсутствует имя ресурса docker_image.

```bash
$ terraform validate
╷
│ Error: Missing name for resource
│
│   on main.tf line 23, in resource "docker_image":
│   23: resource "docker_image" {
│
│ All resource blocks must have 2 labels (type, name).
╵
╷
│ Error: Invalid resource name
│
│   on main.tf line 28, in resource "docker_container" "1nginx":
│   28: resource "docker_container" "1nginx" {
│
│ A name must start with a letter or underscore and may contain only letters, digits, underscores, and dashes.
╵
```

```tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
  required_version = "~> 1.9.2"
}

provider "docker" {}

resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 9090
  }
}
```

5. 

```bash
$ terraform validate
terraform apply -auto-approve
docker ps

Success! The configuration is valid.

random_password.random_string: Refreshing state... [id=none]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
...
...
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS                  PORTS                    NAMES
121fab7616bb   a72860cb95fd             "/docker-entrypoint.…"   6 seconds ago   Up Less than a second   0.0.0.0:9090->80/tcp     example_VvmV2JmkHqtXRrrV
```

6. 

```tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
  required_version = "~> 1.9.2"
}

provider "docker" {}

resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "hello_world"

  ports {
    internal = 80
    external = 9090
  }
}
```

```bash
terraform apply -auto-approve
docker ps

docker_image.nginx: Refreshing state... [id=sha256:a72860cb95fd59e9c696c66441c64f18e66915fa26b249911e83c3854477ed9anginx:latest]
random_password.random_string: Refreshing state... [id=none]
docker_container.nginx: Refreshing state... [id=121fab7616bb5d9c9fd048aa4a57f34990cbfc0d3bee2fc0c4cd29e2eeb8b967]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:
...
...
...
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

CONTAINER ID   IMAGE                    COMMAND                  CREATED                  STATUS                  PORTS                    NAMES
c6c928637d7e   a72860cb95fd             "/docker-entrypoint.…"   Less than a second ago   Up Less than a second   0.0.0.0:9090->80/tcp     hello_world
```

**Опасность применения ключа -auto-approve:**
Ключ -auto-approve применяет изменения без подтверждения пользователя, что может привести к нежелательным изменениям или ошибкам, особенно если конфигурация содержит ошибки или не была тщательно проверена.

**Применение ключа -auto-approve:**
Ключ полезен для автоматизации процессов в сценариях CI/CD, где необходимо автоматическое развертывание без вмешательства пользователя.

8. 

```bash
$ terraform destroy -auto-approve
docker_image.nginx: Refreshing state... [id=sha256:a72860cb95fd59e9c696c66441c64f18e66915fa26b249911e83c3854477ed9anginx:latest]
docker_container.nginx: Refreshing state... [id=c6c928637d7ed3b7b9011515d2baa1b8d38499a89d2d00c460bd12c2a6ce4cdb]
random_password.random_string: Refreshing state... [id=none]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy
...
...
...
Destroy complete! Resources: 3 destroyed.
```

```bash
$ cat terraform.tfstate
{
  "version": 4,
  "terraform_version": "1.9.2",
  "serial": 11,
  "lineage": "d08a93d5-c463-cf8c-bdc3-641d35a788ce",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```

9. В предоставленном файле main.tf у ресурса docker_image используется директива, запрещающая его удаление.

```hcl
Copy code
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}
```

Из [документации](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) Terraform провайдера Docker:
```keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation.```
Вот почему образ nginx:latest не был удален.

---

### Задание 2

1. Создайте в облаке ВМ. Сделайте это через web-консоль, чтобы не слить по незнанию токен от облака в github(это тема следующей лекции). Если хотите - попробуйте сделать это через terraform, прочитав документацию yandex cloud. Используйте файл ```personal.auto.tfvars``` и гитигнор или иной, безопасный способ передачи токена!
2. Подключитесь к ВМ по ssh и установите стек docker.
3. Найдите в документации docker provider способ настроить подключение terraform на вашей рабочей станции к remote docker context вашей ВМ через ssh.
4. Используя terraform и  remote docker context, скачайте и запустите на вашей ВМ контейнер ```mysql:8``` на порту ```127.0.0.1:3306```, передайте ENV-переменные. Сгенерируйте разные пароли через random_password и передайте их в контейнер, используя интерполяцию из примера с nginx.(```name  = "example_${random_password.random_string.result}"```  , двойные кавычки и фигурные скобки обязательны!) 
```
    environment:
      - "MYSQL_ROOT_PASSWORD=${...}"
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - "MYSQL_PASSWORD=${...}"
      - MYSQL_ROOT_HOST="%"
```
6. Зайдите на вашу ВМ , подключитесь к контейнеру и проверьте наличие секретных env-переменных с помощью команды ```env```. Запишите ваш финальный код в репозиторий.

### Ответ

Создал ВМ в Yandex.Cloud и настроил remote context

```bash
user@fhm0kcvfp2opdbk2kghn:~$ sudo su
root@fhm0kcvfp2opdbk2kghn:/home/user# docker --version
Docker version 24.0.5, build ced0996
root@fhm0kcvfp2opdbk2kghn:/home/user# exit
exit
user@fhm0kcvfp2opdbk2kghn:~$ exit
logout
Connection to 89.169.134.89 closed.
$ docker context create remote-docker --docker "host=ssh://user@89.169.134.89"
remote-docker
Successfully created context "remote-docker"
$ docker context use remote-docker
remote-docker
Current context is now "remote-docker"
$
```

Изменил main.tf для работы с удаленным Docker

```tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
  required_version = "~> 1.9.2"
}

provider "docker" {
  host = "ssh://user@89.169.134.89"
}

resource "random_password" "mysql_root_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "random_password" "mysql_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "docker_image" "mysql" {
  name         = "mysql:8"
  keep_locally = true
}

resource "docker_container" "mysql_container" {
  image = docker_image.mysql.image_id
  name  = "mysql_server"

  ports {
    internal = 3306
    external = 3306
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_password.result}",
    "MYSQL_ROOT_HOST=%"
  ]
}
```

Применил конфигурацию

```bash
$ terraform init
terraform apply -auto-approve
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of kreuzwerker/docker from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Using previously-installed kreuzwerker/docker v3.0.2
- Using previously-installed hashicorp/random v3.6.2

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

...
...
...

Plan: 4 to add, 0 to change, 0 to destroy.
random_password.mysql_password: Creating...
random_password.mysql_root_password: Creating...
random_password.mysql_password: Creation complete after 0s [id=none]
random_password.mysql_root_password: Creation complete after 0s [id=none]
docker_image.mysql: Creating...
docker_image.mysql: Still creating... [10s elapsed]
docker_image.mysql: Creation complete after 18s [id=sha256:233a484acc79daf2d74ea6eb4f702bbbaea5f092c0b102a70dfe23bd4a172d8bmysql:8]
docker_container.mysql_container: Creating...
docker_container.mysql_container: Creation complete after 4s [id=12aafd47a8da1e68766108299d3cb55dfc9612c4f98424bcccafa265455794fc]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

$ ssh user@89.169.134.89
user@fhm0kcvfp2opdbk2kghn:~$ sudo su
root@fhm0kcvfp2opdbk2kghn:/home/user# docker exec -it mysql_server env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=12aafd47a8da
TERM=xterm
MYSQL_ROOT_HOST=%
MYSQL_DATABASE=wordpress
MYSQL_PASSWORD=r7Tfn0QsL0G1ZPxv
MYSQL_ROOT_PASSWORD=Ktd0Su2UlR0wdGVh
MYSQL_USER=wordpress
GOSU_VERSION=1.17
MYSQL_MAJOR=8.4
MYSQL_VERSION=8.4.2-1.el9
MYSQL_SHELL_VERSION=8.4.1-1.el9
HOME=/root
```

---

### Задание 3

1. Установите [opentofu](https://opentofu.org/)(fork terraform с лицензией Mozilla Public License, version 2.0) любой версии
2. Попробуйте выполнить тот же код с помощью ```tofu apply```, а не terraform apply.

### Ответ

```bash
$ tofu --version
OpenTofu v1.7.3
on linux_amd64
+ provider registry.terraform.io/hashicorp/random v3.6.2
+ provider registry.terraform.io/kreuzwerker/docker v3.0.2

$ tofu init

Initializing the backend...

Initializing provider plugins...
...

$ tofu validate
Success! The configuration is valid.

$ tofu apply -auto-approve

OpenTofu used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

OpenTofu will perform the following actions:

...
...
...

Plan: 4 to add, 0 to change, 0 to destroy.
random_password.mysql_password: Creating...
random_password.mysql_root_password: Creating...
random_password.mysql_password: Creation complete after 0s [id=none]
random_password.mysql_root_password: Creation complete after 0s [id=none]
docker_image.mysql: Creating...
docker_image.mysql: Creation complete after 2s [id=sha256:233a484acc79daf2d74ea6eb4f702bbbaea5f092c0b102a70dfe23bd4a172d8bmysql:8]
docker_container.mysql_container: Creating...
docker_container.mysql_container: Creation complete after 2s [id=544bb43458eb5cb18a8daf6d8040d3f2f6d282ec84b525eb109966ce132f26be]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

$ ssh user@89.169.134.89
user@fhm0kcvfp2opdbk2kghn:~$ sudo su
root@fhm0kcvfp2opdbk2kghn:/home/user# docker exec -it mysql_server env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=544bb43458eb
TERM=xterm
MYSQL_ROOT_HOST=%
MYSQL_ROOT_PASSWORD=5CfKc9lxTcIred8N
MYSQL_PASSWORD=9SogS2vlEfm5e3RW
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
GOSU_VERSION=1.17
MYSQL_MAJOR=8.4
MYSQL_VERSION=8.4.2-1.el9
MYSQL_SHELL_VERSION=8.4.1-1.el9
HOME=/root
```
