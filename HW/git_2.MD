# Домашнее задание к занятию "`Основы Git`" - `Исаенков Евгений`

---

### Задание 1

Создадим аккаунт в GitLab, если у вас его ещё нет:

1. GitLab. Для [регистрации](https://gitlab.com/users/sign_up)  можно использовать аккаунт Google, GitHub и другие. 
2. После регистрации или авторизации в GitLab создайте новый проект, нажав на ссылку `Create a projet`. 
Желательно назвать также, как и в GitHub — `devops-netology` и `visibility level`, выбрать `Public`.
3. Галочку `Initialize repository with a README` лучше не ставить, чтобы не пришлось разрешать конфликты.
4. Если вы зарегистрировались при помощи аккаунта в другой системе и не указали пароль, то увидите сообщение:
`You won't be able to pull or push project code via HTTPS until you set a password on your account`. 
Тогда перейдите [по ссылке](https://gitlab.com/profile/password/edit) из этого сообщения и задайте пароль. 
Если вы уже умеете пользоваться SSH-ключами, то воспользуйтесь этой возможностью (подробнее про SSH мы поговорим в следующем учебном блоке).
5. Перейдите на страницу созданного вами репозитория, URL будет примерно такой:
https://gitlab.com/YOUR_LOGIN/devops-netology. Изучите предлагаемые варианты для начала работы в репозитории в секции
`Command line instructions`. 
6. Запомните вывод команды `git remote -v`.
7. Из-за того, что это будет наш дополнительный репозиторий, ни один вариант из перечисленных в инструкции (на странице 
вновь созданного репозитория) нам не подходит. Поэтому добавляем этот репозиторий, как дополнительный `remote`, к созданному
репозиторию в рамках предыдущего домашнего задания:
`git remote add gitlab https://gitlab.com/YOUR_LOGIN/devops-netology.git`.
8. Отправьте изменения в новый удалённый репозиторий `git push -u gitlab main`.
9. Обратите внимание, как изменился результат работы команды `git remote -v`.

#### Как изменить видимость репозитория в  GitLab — сделать его публичным 

* На верхней панели выберите «Меню» -> «Проекты» и найдите свой проект.
* На левой боковой панели выберите «Настройки» -> «Основные».
* Разверните раздел «Видимость» -> «Функции проекта» -> «Разрешения».
* Измените видимость проекта на Public.
* Нажмите «Сохранить изменения».

### Ответ
```bash
$ git remote -v
origin  https://gitlab.com/udjin79/devops-netology.git (fetch)
origin  https://gitlab.com/udjin79/devops-netology.git (push)

$ git push -u gitlab main
Username for 'https://gitlab.com': udjin79@gmail.com
Password for 'https://udjin79@gmail.com@gitlab.com':
Enumerating objects: 17, done.
Counting objects: 100% (17/17), done.
Delta compression using up to 6 threads
Compressing objects: 100% (9/9), done.
Writing objects: 100% (17/17), 2.03 KiB | 83.00 KiB/s, done.
Total 17 (delta 2), reused 3 (delta 0), pack-reused 0
To https://gitlab.com/udjin79/devops-netology.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'gitlab'.

$ git remote -v
gitlab  https://gitlab.com/udjin79/devops-netology.git (fetch)
gitlab  https://gitlab.com/udjin79/devops-netology.git (push)
origin  https://github.com/Udjin79/devops-netology.git (fetch)
origin  https://github.com/Udjin79/devops-netology.git (push)
```

---

### Задание 2

Представьте ситуацию, когда в коде была обнаружена ошибка — надо вернуться на предыдущую версию кода,
исправить её и выложить исправленный код в продакшн. Мы никуда не будем выкладывать код, но пометим некоторые коммиты тегами и создадим от них ветки. 

1. Создайте легковестный тег `v0.0` на HEAD-коммите и запуште его во все три добавленных на предыдущем этапе `upstream`.
2. Аналогично создайте аннотированный тег `v0.1`.
3. Перейдите на страницу просмотра тегов в GitHab (и в других репозиториях) и посмотрите, чем отличаются созданные теги. 
    * в GitHub — https://github.com/YOUR_ACCOUNT/devops-netology/releases;
    * в GitLab — https://gitlab.com/YOUR_ACCOUNT/devops-netology/-/tags;
    * в Bitbucket — список тегов расположен в выпадающем меню веток на отдельной вкладке. 

### Ответ

```bash
$ git tag v0.0
$ git tag -a v0.1 -m "Annotated tag"
$ git remote -v
gitlab  https://gitlab.com/udjin79/devops-netology.git (fetch)
gitlab  https://gitlab.com/udjin79/devops-netology.git (push)
origin  https://github.com/Udjin79/devops-netology.git (fetch)
origin  https://github.com/Udjin79/devops-netology.git (push)
$ git push gitlab v0.0
Username for 'https://gitlab.com': udjin79@gmail.com
Password for 'https://udjin79@gmail.com@gitlab.com':
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
To https://gitlab.com/udjin79/devops-netology.git
 * [new tag]         v0.0 -> v0.0
$ git push gitlab v0.1
Username for 'https://gitlab.com': udjin79@gmail.com
Password for 'https://udjin79@gmail.com@gitlab.com':
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 170 bytes | 15.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0
To https://gitlab.com/udjin79/devops-netology.git
 * [new tag]         v0.1 -> v0.1

$ git remote -v
gitlab  https://gitlab.com/udjin79/devops-netology.git (fetch)
gitlab  https://gitlab.com/udjin79/devops-netology.git (push)
origin  https://github.com/Udjin79/devops-netology.git (fetch)
origin  https://github.com/Udjin79/devops-netology.git (push)
$ git push origin v0.0
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/Udjin79/devops-netology.git
 * [new tag]         v0.0 -> v0.0
$ git push origin v0.1
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 170 bytes | 170.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/Udjin79/devops-netology.git
 * [new tag]         v0.1 -> v0.1
$
```

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/git2_1.png?raw=true)
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/git2_2.png?raw=true)


---

### Задание 3

Давайте посмотрим, как будет выглядеть история коммитов при создании веток. 

1. Переключитесь обратно на ветку `main`, которая должна быть связана с веткой `main` репозитория на `github`.
2. Посмотрите лог коммитов и найдите хеш коммита с названием `Prepare to delete and move`, который был создан в пределах предыдущего домашнего задания. 
3. Выполните `git checkout` по хешу найденного коммита. 
4. Создайте новую ветку `fix`, базируясь на этом коммите `git switch -c fix`.
5. Отправьте новую ветку в репозиторий на GitHub `git push -u origin fix`.
6. Посмотрите, как визуально выглядит ваша схема коммитов: https://github.com/YOUR_ACCOUNT/devops-netology/network. 
7. Теперь измените содержание файла `README.md`, добавив новую строчку.
8. Отправьте изменения в репозиторий и посмотрите, как изменится схема на странице https://github.com/YOUR_ACCOUNT/devops-netology/network 
и как изменится вывод команды `git log`.

### Ответ

```bash
$ git checkout main
Already on 'main'
Your branch is up to date with 'gitlab/main'.

$ git log --grep="Prepare to delete and move"
commit bcf5e2fd8e3cc3e8c99a8d7d8e611ed8e1d881e9
Author: Evgeniy Isaenkov <johndoe@example.com>
Date:   Sat Mar 23 16:55:51 2024 +0300

    Prepare to delete and move

$ git checkout bcf5e2fd8e3cc3e8c99a8d7d8e611ed8e1d881e9
Note: switching to 'bcf5e2fd8e3cc3e8c99a8d7d8e611ed8e1d881e9'.
HEAD is now at bcf5e2f Prepare to delete and move

$ git switch -c fix
Switched to a new branch 'fix'

$ git push -u origin fix
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote:
remote: Create a pull request for 'fix' on GitHub by visiting:
remote:      https://github.com/Udjin79/devops-netology/pull/new/fix
remote:
To https://github.com/Udjin79/devops-netology.git
 * [new branch]      fix -> fix
branch 'fix' set up to track 'origin/fix'.

$ git add README.md

$ git commit -m "Update README.md"
[fix 65c508a] Update README.md
 1 file changed, 5 insertions(+), 1 deletion(-)

$ git push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 6 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 363 bytes | 363.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To https://github.com/Udjin79/devops-netology.git
   bcf5e2f..65c508a  fix -> fix
```

![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/git2_3.png?raw=true)
![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/git2_4.png?raw=true)

---

### Задание 4

Попробуем поработь с Git при помощи визуального редактора. 

1. В используемой IDE PyCharm откройте визуальный редактор работы с Git, находящийся в меню View -> Tool Windows -> Git.
2. Измените какой-нибудь файл, и он сразу появится на вкладке `Local Changes`, отсюда можно выполнить коммит, нажав на кнопку внизу этого диалога. 
3. Элементы управления для работы с Git будут выглядеть примерно так:
 
4. Попробуйте выполнить пару коммитов, используя IDE. 

[По ссылке](https://www.jetbrains.com/help/pycharm/commit-and-push-changes.html) можно найти справочную информацию по визуальному интерфейсу. 

Если вверху экрана выбрать свою операционную систему, можно посмотреть горячие клавиши для работы с Git. 
Подробней о визуальном интерфейсе мы расскажем на одной из следующих лекций.

*В качестве результата работы по всем заданиям приложите ссылки на ваши репозитории в GitHub, GitLab и Bitbucket*.  

### Ответ

![Название скриншота 5](https://github.com/Udjin79/netology_hw/blob/main/img/git2_5.png?raw=true)
![Название скриншота 6](https://github.com/Udjin79/netology_hw/blob/main/img/git2_6.png?raw=true)

