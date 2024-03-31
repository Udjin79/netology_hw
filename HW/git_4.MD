# Домашнее задание к занятию "`Инструменты Git`" - `Исаенков Евгений`

---

### Задание 1

#### Инструкция к заданию

1. Склонируйте [репозиторий](https://github.com/hashicorp/terraform) с исходным кодом Terraform.
2. Создайте файл для ответов на задания в своём репозитории, после выполнения прикрепите ссылку на .md-файл с ответами в личном кабинете.
3. Любые вопросы по решению задач задавайте в чате учебной группы.

------

#### Задание

В клонированном репозитории:

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
2. Ответьте на вопросы.

* Какому тегу соответствует коммит `85024d3`?
* Сколько родителей у коммита `b8d720`? Напишите их хеши.
* Перечислите хеши и комментарии всех коммитов, которые были сделаны между тегами  v0.12.23 и v0.12.24.
* Найдите коммит, в котором была создана функция `func providerSource`, её определение в коде выглядит так: `func providerSource(...)` (вместо троеточия перечислены аргументы).
* Найдите все коммиты, в которых была изменена функция `globalPluginDirs`.
* Кто автор функции `synchronizedWriters`? 

*В качестве решения ответьте на вопросы и опишите, как были получены эти ответы.*

### Ответ

Клонирую репозиторий
```bash
$ git clone https://github.com/hashicorp/terraform
Cloning into 'terraform'...
remote: Enumerating objects: 294941, done.
remote: Counting objects: 100% (3430/3430), done.
remote: Compressing objects: 100% (1501/1501), done.
remote: Total 294941 (delta 2242), reused 2763 (delta 1851), pack-reused 291511
Receiving objects: 100% (294941/294941), 300.38 MiB | 5.55 MiB/s, done.
Resolving deltas: 100% (185157/185157), done.
Updating files: 100% (4480/4480), done.
```

1. **Вывожу полный хеш и комментарий для коммита, хеш которого начинается на `aefea`**:
```bash
$ cd .\terraform\
$ git show --oneline aefea
aefead2207 Update CHANGELOG.md
```

2. **Вывожу теги, содержащие коммит `85024d3`**:
```bash
$ git tag --contains 85024d3
v0.12.23
v0.12.24
v0.12.25
v0.12.26
v0.12.27
v0.12.28
v0.12.29
v0.12.30
v0.12.31
```

3. **Вывожу родителей у коммита `b8d720` и их хеши**:
```bash
$ git show --pretty=%P b8d720
56cd7859e05c36c06b56d013b55a252d0bb7e158 
9ea88f22fc6269854151c571162c5bcf958bee2b
```

4. **Вывожу коммиты между тегами v0.12.23 и v0.12.24, включая хэши и комментарии**:
```bash
$ git log v0.12.23..v0.12.24 --oneline
33ff1c03bb (tag: v0.12.24) v0.12.24
b14b74c493 [Website] vmc provider links
3f235065b9 Update CHANGELOG.md
6ae64e247b registry: Fix panic when server is unreachable
5c619ca1ba website: Remove links to the getting started guide's old location
06275647e2 Update CHANGELOG.md
d5f9411f51 command: Fix bug when using terraform login on Windows
4b6d06cc5d Update CHANGELOG.md
dd01a35078 Update CHANGELOG.md
225466bc3e Cleanup after v0.12.23 release
```

5. **Вывожу коммит, где впервые появилась строка с объявлением функции `func providerSource`**:
```bash
$ git log -S'func providerSource(' --source --all
commit 8c928e83589d90a031f811fae52a81be7153e82f refs/remotes/origin/alisdair/getproviders-retries-bad-branch-do-not-use
Author: Martin Atkins <mart@degeneration.co.uk>
Date:   Thu Apr 2 18:04:39 2020 -0700

    main: Consult local directories as potential mirrors of providers
```

6. **Вывожу все коммиты, где упоминается изменение в функции `globalPluginDirs`**:
```bash
$ git log -S'globalPluginDirs' --oneline
65c4ba7363 Remove terraform binary
125eb51dc4 Remove accidentally-committed binary
22c121df86 Bump compatibility version to 1.3.0 for terraform core release (#30988)
7c7e5d8f0a Don't show data while input if sensitive
35a058fb3d main: configure credentials from the CLI config file
c0b1761096 prevent log output during init
8364383c35 Push plugin discovery down into command package
```

7. **Нахожу автора функции `synchronizedWriters`**:
```bash
$ git log -S'func synchronizedWriters' --source --all
commit bdfea50cc85161dea41be0fe3381fd98731ff786 refs/remotes/origin/f-gen-integration-tests
Author: James Bardin <j.bardin@gmail.com>
Date:   Mon Nov 30 18:02:04 2020 -0500

    remove unused

commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5 refs/tags/v0.9.5
Author: Martin Atkins <mart@degeneration.co.uk>
Date:   Wed May 3 16:25:41 2017 -0700

    main: synchronize writes to VT100-faker on Windows

$ git show --oneline 5ac311e2a91e381e2f52234668b49ba670aa0fe5
5ac311e2a9 main: synchronize writes to VT100-faker on Windows    
```
Сначала вывожу коммиты, где была изменена функция, и из контекста определяю автора.
Видим, что автор интересующего нас коммита Martin Atkins
