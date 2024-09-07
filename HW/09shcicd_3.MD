# Домашнее задание к занятию "`Процессы CI/CD`" - `Исаенков Евгений`

## Подготовка к выполнению

1. Создайте два VM в Yandex Cloud с параметрами: 2CPU 4RAM Centos7 (остальное по минимальным требованиям).
2. Пропишите в [inventory](./infrastructure/inventory/cicd/hosts.yml) [playbook](./infrastructure/site.yml) созданные хосты.
3. Добавьте в [files](./infrastructure/files/) файл со своим публичным ключом (id_rsa.pub). Если ключ называется иначе — найдите таску в плейбуке, которая использует id_rsa.pub имя, и исправьте на своё.
4. Запустите playbook, ожидайте успешного завершения.
5. Проверьте готовность SonarQube через [браузер](http://localhost:9000).
6. Зайдите под admin\admin, поменяйте пароль на свой.
7. Проверьте готовность Nexus через [бразуер](http://localhost:8081).
8. Подключитесь под admin\admin123, поменяйте пароль, сохраните анонимный доступ.

## Знакомоство с SonarQube

### Основная часть

1. Создайте новый проект, название произвольное.
2. Скачайте пакет sonar-scanner, который вам предлагает скачать SonarQube.
3. Сделайте так, чтобы binary был доступен через вызов в shell (или поменяйте переменную PATH, или любой другой, удобный вам способ).
4. Проверьте `sonar-scanner --version`.
5. Запустите анализатор против кода из директории [example](./example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`.
6. Посмотрите результат в интерфейсе.
7. Исправьте ошибки, которые он выявил, включая warnings.
8. Запустите анализатор повторно — проверьте, что QG пройдены успешно.
9. Сделайте скриншот успешного прохождения анализа, приложите к решению ДЗ.

## Знакомство с Nexus

### Основная часть

1. В репозиторий `maven-public` загрузите артефакт с GAV-параметрами:

- groupId: netology;
- artifactId: java;
- version: 8_282;
- classifier: distrib;
- type: tar.gz.

2. В него же загрузите такой же артефакт, но с version: 8_102.
3. Проверьте, что все файлы загрузились успешно.
4. В ответе пришлите файл `maven-metadata.xml` для этого артефекта.

### Знакомство с Maven

### Подготовка к выполнению

1. Скачайте дистрибутив с [maven](https://maven.apache.org/download.cgi).
2. Разархивируйте, сделайте так, чтобы binary был доступен через вызов в shell (или поменяйте переменную PATH, или любой другой, удобный вам способ).
3. Удалите из `apache-maven-<version>/conf/settings.xml` упоминание о правиле, отвергающем HTTP- соединение — раздел mirrors —> id: my-repository-http-unblocker.
4. Проверьте `mvn --version`.
5. Заберите директорию [mvn](./mvn) с pom.

### Основная часть

1. Поменяйте в `pom.xml` блок с зависимостями под ваш артефакт из первого пункта задания для Nexus (java с версией 8_282).
2. Запустите команду `mvn package` в директории с `pom.xml`, ожидайте успешного окончания.
3. Проверьте директорию `~/.m2/repository/`, найдите ваш артефакт.
4. В ответе пришлите исправленный файл `pom.xml`.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---

## Ответ

### Подготовка к выполнению

1. Создайте два VM в Yandex Cloud с параметрами: 2CPU 4RAM Centos7 (остальное по минимальным требованиям).

```bash
$ terraform apply
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
...
...
...
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

$ yc compute instances list
+----------------------+------+---------------+---------+----------------+-------------+
|          ID          | NAME |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+------+---------------+---------+----------------+-------------+
| ******************** | vm-2 | ru-central1-a | RUNNING | 89.169.150.245 | 10.0.1.12   |
| ******************** | vm-1 | ru-central1-a | RUNNING | 89.169.152.181 | 10.0.1.26   |
+----------------------+------+---------------+---------+----------------+-------------+
```

2. Пропишите в [inventory](./infrastructure/inventory/cicd/hosts.yml) [playbook](./infrastructure/site.yml) созданные хосты.

```bash
$ cat ./infrastructure/inventory/cicd/hosts.yml
---
all:
  hosts:
    sonar-01:
      ansible_host: 89.169.152.181
    nexus-01:
      ansible_host: 89.169.150.245
  children:
    sonarqube:
      hosts:
        sonar-01:
    nexus:
      hosts:
        nexus-01:
    postgres:
      hosts:
        sonar-01:
  vars:
    ansible_connection_type: paramiko
    ansible_user: centos
```

3. Добавьте в [files](./infrastructure/files/) файл со своим публичным ключом (id_rsa.pub). Если ключ называется иначе — найдите таску в плейбуке, которая использует id_rsa.pub имя, и исправьте на своё.

```bash
    - name: "Set up ssh key to access for managed node"
      authorized_key:
        user: "{{ sonarqube_db_user }}"
        state: present
        key: "{{ lookup('file', 'id_ed25519.pub') }}"
```

```bash
$ ls ./infrastructure/files/
CentOS-Base.repo  id_ed25519.pub    pg_hba.conf
```

4. Запустите playbook, ожидайте успешного завершения.

```bash
$ ansible-playbook -i infrastructure/inventory/cicd/hosts.yml infrastructure/site.yml
...
...
...
PLAY RECAP
---
nexus-01                   : ok=16   changed=16    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
sonar-01                   : ok=32   changed=32   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

```

5. Проверьте готовность SonarQube через [браузер](http://localhost:9000).
6. Зайдите под admin\admin, поменяйте пароль на свой.
   ![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_3.png?raw=true)
   ![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_4.png?raw=true)

7. Проверьте готовность Nexus через [бразуер](http://localhost:8081).
8. Подключитесь под admin\admin123, поменяйте пароль, сохраните анонимный доступ.
   ![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_2.png?raw=true)
   ![Название скриншота 5](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_5.png?raw=true)

## Знакомоство с SonarQube

### Основная часть

1. Создайте новый проект, название произвольное.
2. Скачайте пакет sonar-scanner, который вам предлагает скачать SonarQube.
3. Сделайте так, чтобы binary был доступен через вызов в shell (или поменяйте переменную PATH, или любой другой, удобный вам способ).
4. Проверьте `sonar-scanner --version`.

```bash
$ export PATH=/mnt/h/DevOps/CICD/03/sonar-scanner-6.1/bin:$PATH

$ sonar-scanner --version
20:47:10.412 INFO  Scanner configuration file: /mnt/h/DevOps/CICD/03/sonar-scanner-6.1/conf/sonar-scanner.properties
20:47:10.418 INFO  Project root configuration file: NONE
20:47:10.437 INFO  SonarScanner CLI 6.1.0.4477
20:47:10.441 INFO  Java 17.0.11 Eclipse Adoptium (64-bit)
20:47:10.441 INFO  Linux 5.15.153.1-microsoft-standard-WSL2 amd64
```

```bash
$ sonar-scanner \
  -Dsonar.projectKey=Netology-HW \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://89.169.155.98:9000 \
  -Dsonar.login=**************************
20:49:34.175 INFO  Scanner configuration file: /mnt/h/DevOps/CICD/03/sonar-scanner-6.1/conf/sonar-scanner.properties
20:49:34.181 INFO  Project root configuration file: NONE
20:49:34.201 INFO  SonarScanner CLI 6.1.0.4477
20:49:34.205 INFO  Java 17.0.11 Eclipse Adoptium (64-bit)
20:49:34.206 INFO  Linux 5.15.153.1-microsoft-standard-WSL2 amd64
20:49:34.259 INFO  User cache: /home/user/.sonar/cache
...
...
...
20:49:49.036 INFO  ANALYSIS SUCCESSFUL, you can browse http://89.169.155.98:9000/dashboard?id=Netology-HW
20:49:49.036 INFO  Note that you will be able to access the updated dashboard once the server has processed the submitted analysis report
20:49:49.036 INFO  More about the report processing at http://89.169.155.98:9000/api/ce/task?id=****************
20:49:49.090 INFO  Analysis total time: 7.952 s
20:49:49.091 INFO  EXECUTION SUCCESS
20:49:49.092 INFO  Total time: 14.922s
```

5. Запустите анализатор против кода из директории [example](./example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`.
6. Посмотрите результат в интерфейсе.
   ![Название скриншота 7](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_7.png?raw=true)

7. Исправьте ошибки, которые он выявил, включая warnings.
8. Запустите анализатор повторно — проверьте, что QG пройдены успешно.
9. Посмотрите результат в интерфейсе.
10. Сделайте скриншот успешного прохождения анализа, приложите к решению ДЗ.
    ![Название скриншота 8](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_8.png?raw=true)

## Знакомство с Nexus

### Основная часть

1. В репозиторий `maven-public` загрузите артефакт с GAV-параметрами:

- groupId: netology;
- artifactId: java;
- version: 8_282;
- classifier: distrib;
- type: tar.gz.

2. В него же загрузите такой же артефакт, но с version: 8_102.
3. Проверьте, что все файлы загрузились успешно.
4. В ответе пришлите файл `maven-metadata.xml` для этого артефекта.

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_1.png?raw=true)
![Название скриншота 6](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd3_6.png?raw=true)

### Знакомство с Maven

### Подготовка к выполнению

1. Скачайте дистрибутив с [maven](https://maven.apache.org/download.cgi).
2. Разархивируйте, сделайте так, чтобы binary был доступен через вызов в shell (или поменяйте переменную PATH, или любой другой, удобный вам способ).
3. Удалите из `apache-maven-<version>/conf/settings.xml` упоминание о правиле, отвергающем HTTP- соединение — раздел mirrors —> id: my-repository-http-unblocker.
4. Проверьте `mvn --version`.
5. Заберите директорию [mvn](./mvn) с pom.

```bash
$ whereis mvn
mvn: /mnt/h/devops/apache-maven/bin/mvn

$ mvn --version
Apache Maven 3.9.2 (c9616018c7a021c1c39be70fb2843d6f5f9b8a1c)
Maven home: /mnt/h/devops/apache-maven/
Java version: 11.0.24, vendor: Ubuntu, runtime: /usr/lib/jvm/java-11-openjdk-amd64
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "5.15.153.1-microsoft-standard-wsl2", arch: "amd64", family: "unix"
```

### Основная часть

1. Поменяйте в `pom.xml` блок с зависимостями под ваш артефакт из первого пункта задания для Nexus (java с версией 8_282).

```bash
$ cat pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.netology.app</groupId>
  <artifactId>simple-app</artifactId>
  <version>1.0-SNAPSHOT</version>
   <repositories>
    <repository>
      <id>my-repo</id>
      <name>maven-public</name>
      <url>http://89.169.142.113:8081/repository/maven-public/</url>
    </repository>
  </repositories>
  <dependencies>
	<dependency>
	  <groupId>netology</groupId>
	  <artifactId>java</artifactId>
	  <version>8_282</version>
	  <type>app</type>
	</dependency>
  </dependencies>
</project>
```

2. Запустите команду `mvn package` в директории с `pom.xml`, ожидайте успешного окончания.

```bash
$ mvn package
[INFO] Scanning for projects...
[INFO]
[INFO] --------------------< com.netology.app:simple-app >---------------------
[INFO] Building simple-app 1.0-SNAPSHOT
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[WARNING] The POM for netology:java:app:8_282 is missing, no dependency information available
Downloading from my-repo: http://89.169.142.113:8081/repository/maven-public/netology/java/8_282/java-8_282.app
Downloaded from my-repo: http://89.169.142.113:8081/repository/maven-public/netology/java/8_282/java-8_282.app (792 B at 2.7 kB/s)
[INFO]
[INFO] --- resources:3.3.0:resources (default-resources) @ simple-app ---
...
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /mnt/h/DevOps/CICD/03/mvn/src/main/resources
[INFO]
[INFO] --- compiler:3.10.1:compile (default-compile) @ simple-app ---
...
[INFO] No sources to compile
[INFO]
[INFO] --- resources:3.3.0:testResources (default-testResources) @ simple-app ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /mnt/h/DevOps/CICD/03/mvn/src/test/resources
[INFO]
[INFO] --- compiler:3.10.1:testCompile (default-testCompile) @ simple-app ---
[INFO] No sources to compile
[INFO]
[INFO] --- surefire:3.0.0:test (default-test) @ simple-app ---
...
[INFO] No tests to run.
[INFO]
[INFO] --- jar:3.3.0:jar (default-jar) @ simple-app ---
...
[WARNING] JAR will be empty - no content was marked for inclusion!
[INFO] Building jar: /mnt/h/DevOps/CICD/03/mvn/target/simple-app-1.0-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  14.804 s
[INFO] Finished at: 2024-09-07T21:32:34+03:00
[INFO] ------------------------------------------------------------------------
[WARNING]
[WARNING] Plugin validation issues were detected in 2 plugin(s)
[WARNING]
[WARNING]  * org.apache.maven.plugins:maven-compiler-plugin:3.10.1
[WARNING]  * org.apache.maven.plugins:maven-resources-plugin:3.3.0
[WARNING]
[WARNING] For more or less details, use 'maven.plugin.validation' property with one of the values (case insensitive): [BRIEF, DEFAULT, VERBOSE]
[WARNING]
```

3. Проверьте директорию `~/.m2/repository/`, найдите ваш артефакт.
4. В ответе пришлите исправленный файл `pom.xml`.

```bash
$ ll ~/.m2/repository/
total 8
drwxrwxrwx 1 user user 4096 Sep  7 21:32 ./
drwxrwxrwx 1 user user 4096 Sep  7 21:24 ../
-rwxrwxrwx 1 user user  164 Sep  7 21:32 _remote.repositories*
-rwxrwxrwx 1 user user  392 Sep  7 21:26 java-8_282-test.txt.lastUpdated*
-rwxrwxrwx 1 user user  792 Sep  7 21:32 java-8_282.app*
-rwxrwxrwx 1 user user   40 Sep  7 21:32 java-8_282.app.sha1*
-rwxrwxrwx 1 user user  734 Sep  7 21:26 java-8_282.pom.lastUpdated*
```
