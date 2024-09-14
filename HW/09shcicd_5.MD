# Домашнее задание к занятию "`Teamcity`" - `Исаенков Евгений`

## Подготовка к выполнению

1. В Yandex Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`.
2. Дождитесь запуска teamcity, выполните первоначальную настройку.
3. Создайте ещё один инстанс (2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`.
4. Авторизуйте агент.
5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity).
6. Создайте VM (2CPU4RAM) и запустите [playbook](./infrastructure).

## Основная часть

1. Создайте новый проект в teamcity на основе fork.
2. Сделайте autodetect конфигурации.
3. Сохраните необходимые шаги, запустите первую сборку master.
4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит `mvn clean deploy`, иначе `mvn clean test`.
5. Для deploy будет необходимо загрузить [settings.xml](./teamcity/settings.xml) в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus.
6. В pom.xml необходимо поменять ссылки на репозиторий и nexus.
7. Запустите сборку по master, убедитесь, что всё прошло успешно и артефакт появился в nexus.
8. Мигрируйте `build configuration` в репозиторий.
9. Создайте отдельную ветку `feature/add_reply` в репозитории.
10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`.
11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике.
12. Сделайте push всех изменений в новую ветку репозитория.
13. Убедитесь, что сборка самостоятельно запустилась, тесты прошли успешно.
14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`.
15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`.
16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки.
17. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны.
18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity.
19. В ответе пришлите ссылку на репозиторий.

---

## Ответ
### Подготовка к выполнению

1. В Yandex Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`.
2. Дождитесь запуска teamcity, выполните первоначальную настройку.
3. Создайте ещё один инстанс (2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`.
4. Авторизуйте агент.
6. Создайте VM (2CPU4RAM) и запустите [playbook](./infrastructure).

![Название скриншота 14](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_14.png?raw=true)

```bash
 docker run --name teamcity-server-instance  \
    -v ./data/:/data/teamcity_server/datadir \
    -v ./logs/:/opt/teamcity/logs  \
    -p 8111:8111 \
    jetbrains/teamcity-server
/run-services.sh
/services/check-server-volumes.sh
/run-server.sh
TeamCity server.xml parameter: -config conf/server.xml
Java executable is found: '/opt/java/openjdk/bin/java'
2024-09-14 18:36:06 UTC: Starting TeamCity server
...
```

```bash
$ docker run -e SERVER_URL="http://89.169.155.163:8111/"  \
    -v ./conf/:/data/teamcity_agent/conf  \
    jetbrains/teamcity-agent
/run-services.sh
/services/run-docker.sh
/run-agent.sh
Will create new buildAgent.properties using distributive
TeamCity URL is provided: http://89.169.155.163:8111/
...
```

```bash
$ cat ./infrastructure/inventory/cicd/hosts.yml
---
all:
  hosts:
    nexus-01:
      ansible_host: 84.252.129.74
  children:
    nexus:
      hosts:
        nexus-01:
  vars:
    ansible_connection_type: paramiko
    ansible_user: centos
```

```bash
$ ansible-playbook -i infrastructure/inventory/cicd/hosts.yml infrastructure/site.yml

PLAY [Get Nexus installed] 
...
TASK [Gathering Facts] 
...
...
...
nexus-01                   : ok=16   changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```

5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity).

![Название скриншота 8](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_8.png?raw=true)
![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_1.png?raw=true)

### Основная часть

1. Создайте новый проект в teamcity на основе fork.

Сделан форк репозитория https://github.com/Udjin79/example-teamcity
Произвведена настройка проекта в TeamCity
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_2.png?raw=true)

2. Сделайте autodetect конфигурации.

![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_4.png?raw=true)

3. Сохраните необходимые шаги, запустите первую сборку master.

![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_3.png?raw=true)

4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит `mvn clean deploy`, иначе `mvn clean test`.

![Название скриншота 5](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_5.png?raw=true)

5. Для deploy будет необходимо загрузить [settings.xml](./teamcity/settings.xml) в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus.
6. В pom.xml необходимо поменять ссылки на репозиторий и nexus.

```bash
		<repository>
				<id>nexus</id>
				<url>http://84.252.129.74:8081/repository/maven-releases</url>
		</repository>
```

7. Запустите сборку по master, убедитесь, что всё прошло успешно и артефакт появился в nexus.

![Название скриншота 6](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_6.png?raw=true)
![Название скриншота 7](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_7.png?raw=true)

8. Мигрируйте `build configuration` в репозиторий.

![Название скриншота 9](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_9.png?raw=true)

9. Создайте отдельную ветку `feature/add_reply` в репозитории.
![Название скриншота 15](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_15.png?raw=true)

10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`.

```java
    public String sayRandomHunterPhrase() {
        String[] hunterPhrases = {
            "Hunter, your strength knows no bounds.",
            "A hunter must always be prepared.",
            "Hunter, never lose sight of your prey.",
            "The hunter's journey is never easy.",
            "Hunter, may your blade stay sharp."
        };
        int randomIndex = (int) (Math.random() * hunterPhrases.length);
        return hunterPhrases[randomIndex];
    }
```

11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике.

```java
	@Test
	public void welcomerSaysRandomHunterPhrase() {
		assertThat(welcomer.sayRandomHunterPhrase().toLowerCase(), containsString("hunter"));
	}
```

12. Сделайте push всех изменений в новую ветку репозитория.
13. Убедитесь, что сборка самостоятельно запустилась, тесты прошли успешно.

![Название скриншота 10](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_10.png?raw=true)

14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`.

![Название скриншота 11](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_11.png?raw=true)

15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`.
16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки.
17. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны.

![Название скриншота 12](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_12.png?raw=true)
![Название скриншота 13](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_13.png?raw=true)

18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity.

![Название скриншота 16](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd5_16.png?raw=true)

19. В ответе пришлите ссылку на репозиторий.









