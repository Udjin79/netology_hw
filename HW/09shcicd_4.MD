# Домашнее задание к занятию "`Jenkins`" - `Исаенков Евгений`

# Домашнее задание к занятию 10 «Jenkins»

## Подготовка к выполнению

1. Создать два VM: для jenkins-master и jenkins-agent.
2. Установить Jenkins при помощи playbook.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.

## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.
4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True). По умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.
8. Отправить ссылку на репозиторий с ролью и Declarative Pipeline и Scripted Pipeline.
9. Сопроводите процесс настройки скриншотами для каждого пункта задания!!

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---

## Ответ
### Подготовка к выполнению

1. Создать два VM: для jenkins-master и jenkins-agent.

```bash
$ yc compute instances list
+----------------------+----------------+---------------+---------+----------------+-------------+
|          ID          |      NAME      |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+----------------+---------------+---------+----------------+-------------+
| ******************** | jenkins-master | ru-central1-a | RUNNING | 89.169.150.173 | 10.128.0.32 |
| ******************** | jenkins-agent  | ru-central1-a | RUNNING | 89.169.136.235 | 10.128.0.25 |
+----------------------+----------------+---------------+---------+----------------+-------------+
```

2. Установить Jenkins при помощи playbook.

```bash
$ ansible-playbook -i infrastructure/inventory/cicd/hosts.yml infrastructure/site.yml
[WARNING]: Collection ansible.posix does not support Ansible version 2.17.3

PLAY [Prepare all hosts] 
...
...
...
jenkins-agent-01           : ok=15   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
jenkins-master-01          : ok=12   changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.

```bash
$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
aaec2c51a9a5494f8f07c3fb2ccb0fc7
```

![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_2.png?raw=true)
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_3.png?raw=true)
![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_4.png?raw=true)


### Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
![Название скриншота 5](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_5.png?raw=true)

2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
![Название скриншота 6](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_6.png?raw=true)

3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.

[Jenkinsfile](https://github.com/Udjin79/netology_hw/blob/main/files/09shcicd_4/Jenkinsfile)

4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.

![Название скриншота 8](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_8.png?raw=true)
![Название скриншота 9](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_9.png?raw=true)

5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).


6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True). По умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.

![Название скриншота 7](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd4_7.png?raw=true)

7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.

[ScriptedJenkinsfile](https://github.com/Udjin79/netology_hw/blob/main/files/09shcicd_4/ScriptedJenkinsfile)

8. Отправить ссылку на репозиторий с ролью и Declarative Pipeline и Scripted Pipeline.
9. Сопроводите процесс настройки скриншотами для каждого пункта задания!!

