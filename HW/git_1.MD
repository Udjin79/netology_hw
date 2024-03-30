# Домашнее задание к занятию "`Системы контроля версий`" - `Исаенков Евгений`

---

### Задание 1

### Создание репозитория и первого коммита

1. Зарегистрируйте аккаунт на [https://github.com/](https://github.com/). Если предпочитаете другое хранилище для репозитория, можно использовать его.
2. Создайте публичный репозиторий, который будете использовать дальше на протяжении всего курса, желательное с названием `devops-netology`.
   Обязательно поставьте галочку `Initialize this repository with a README`. 
3. Создайте [авторизационный токен](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) для клонирования репозитория.
4. Склонируйте репозиторий, используя протокол HTTPS (`git clone ...`).
5. Перейдите в каталог с клоном репозитория (`cd devops-netology`).
6. Произведите первоначальную настройку Git, указав своё настоящее имя, чтобы нам было проще общаться, и email (`git config --global user.name` и `git config --global user.email johndoe@example.com`). 
7. Выполните команду `git status` и запомните результат.
8. Отредактируйте файл `README.md` любым удобным способом, тем самым переведя файл в состояние `Modified`.
9. Ещё раз выполните `git status` и продолжайте проверять вывод этой команды после каждого следующего шага. 
10. Теперь посмотрите изменения в файле `README.md`, выполнив команды `git diff` и `git diff --staged`.
11. Переведите файл в состояние `staged` (или, как говорят, просто добавьте файл в коммит) командой `git add README.md`.
12. И ещё раз выполните команды `git diff` и `git diff --staged`. Поиграйте с изменениями и этими командами, чтобы чётко понять, что и когда они отображают. 
13. Теперь можно сделать коммит `git commit -m 'First commit'`.
14. И ещё раз посмотреть выводы команд `git status`, `git diff` и `git diff --staged`.

### Создание файлов `.gitignore` и второго коммита

1. Создайте файл `.gitignore` (обратите внимание на точку в начале файла), проверьте его статус сразу после создания. 
1. Добавьте файл `.gitignore` в следующий коммит (`git add...`).
1. На одном из следующих блоков вы будете изучать `Terraform`, давайте сразу создадим соотвествующий каталог `terraform` и внутри этого каталога — файл `.gitignore` по примеру: https://github.com/github/gitignore/blob/master/Terraform.gitignore.  
1. В файле `README.md` опишите своими словами, какие файлы будут проигнорированы в будущем благодаря добавленному `.gitignore`.
1. Закоммитьте все новые и изменённые файлы. Комментарий к коммиту должен быть `Added gitignore`.

### Эксперимент с удалением и перемещением файлов (третий и четвёртый коммит)

1. Создайте файлы `will_be_deleted.txt` (с текстом `will_be_deleted`) и `will_be_moved.txt` (с текстом `will_be_moved`) и закоммите их с комментарием `Prepare to delete and move`.
1. В случае необходимости обратитесь к [официальной документации](https://git-scm.com/book/ru/v2/Основы-Git-Запись-изменений-в-репозиторий) — здесь подробно описано, как выполнить следующие шаги. 
1. Удалите файл `will_be_deleted.txt` с диска и из репозитория. 
1. Переименуйте (переместите) файл `will_be_moved.txt` на диске и в репозитории, чтобы он стал называться `has_been_moved.txt`.
1. Закоммитьте результат работы с комментарием `Moved and deleted`.

### Проверка изменения

1. В результате предыдущих шагов в репозитории должно быть как минимум пять коммитов (если вы сделали ещё промежуточные — нет проблем):
    * `Initial Commit` — созданный GitHub при инициализации репозитория. 
    * `First commit` — созданный после изменения файла `README.md`.
    * `Added gitignore` — после добавления `.gitignore`.
    * `Prepare to delete and move` — после добавления двух временных файлов.
    * `Moved and deleted` — после удаления и перемещения временных файлов. 
2. Проверьте это, используя комманду `git log`. Подробно о формате вывода этой команды мы поговорим на следующем занятии, но посмотреть, что она отображает, можно уже сейчас.

### Отправка изменений в репозиторий

Выполните команду `git push`, если Git запросит логин и пароль — введите ваши логин и пароль от GitHub. 

В качестве результата отправьте ссылку на репозиторий. 


### Ответ

https://github.com/Udjin79/devops-netology/commits/main/

```bash
$ git clone https://github.com/Udjin79/devops-netology.git
Cloning into 'devops-netology'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.

$ cd devops-netology/
$ git config user.name "Evgeniy Isaenkov"
$ git config user.email johndoe@example.com
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")

$ git diff
diff --git a/README.md b/README.md
index 647b370..922eccf 100644
--- a/README.md
+++ b/README.md
@@ -1 +1,2 @@
-# devops-netology
\ No newline at end of file
+# devops-netology^M
+### Change 1
\ No newline at end of file

$ git diff --staged
$ git add README.md
$ git diff
$ git diff --staged
diff --git a/README.md b/README.md
index 647b370..922eccf 100644
--- a/README.md
+++ b/README.md
@@ -1 +1,2 @@
-# devops-netology
\ No newline at end of file
+# devops-netology^M
+### Change 1
\ No newline at end of file

$ git commit -m 'First commit'
[main b057920] First commit
 1 file changed, 2 insertions(+), 1 deletion(-)

$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

$ git diff
$ git diff --staged
$ touch .gitignore
$ git add .gitignore
$ mkdir terraform
$ touch terraform/.gitignore
$ git add terraform/.gitignore
$ git add README.md
$ git commit -m 'Added gitignore'
[main dbeb6fb] Added gitignore
 3 files changed, 3 insertions(+), 1 deletion(-)
 create mode 100644 .gitignore
 create mode 100644 terraform/.gitignore

$ echo "will_be_deleted" >> will_be_deleted.txt
$ echo "will_be_moved" >> will_be_moved.txt
$ ls
README.md  terraform  will_be_deleted.txt  will_be_moved.txt
$ git add will_be_deleted.txt
$ git add will_be_moved.txt
$ git commit -m 'Prepare to delete and move'
[main bcf5e2f] Prepare to delete and move
 2 files changed, 2 insertions(+)
 create mode 100644 will_be_deleted.txt
 create mode 100644 will_be_moved.txt

$ rm will_be_deleted.txt
$ mv will_be_moved.txt has_been_moved.txt
$ ls
README.md  has_been_moved.txt  terraform
$ git add .
$ git commit -m 'Moved and deleted'
[main 52a9a0c] Moved and deleted
 2 files changed, 1 deletion(-)
 rename will_be_moved.txt => has_been_moved.txt (100%)
 delete mode 100644 will_be_deleted.txt
$ git log
commit 52a9a0c362d8012f7e1371d312d1f418f957d47f (HEAD -> main)
Author: Evgeniy Isaenkov <johndoe@example.com>
Date:   Sat Mar 23 17:00:17 2024 +0300

    Moved and deleted

commit bcf5e2fd8e3cc3e8c99a8d7d8e611ed8e1d881e9
Author: Evgeniy Isaenkov <johndoe@example.com>
Date:   Sat Mar 23 16:55:51 2024 +0300

    Prepare to delete and move

commit dbeb6fb1248f9a68bef494411be197ac64369901 (origin/main, origin/HEAD)
Author: Evgeniy Isaenkov <johndoe@example.com>
Date:   Sat Mar 23 16:44:41 2024 +0300

    Added gitignore

commit b057920f3f715c119ab529bf22fa4c4846bfaf23
Author: Evgeniy Isaenkov <johndoe@example.com>
Date:   Sat Mar 23 16:39:15 2024 +0300

    First commit

commit 6c34c5ba393d22b7b20cb62510f4f95540a2c8cb
Author: Evgeniy <68610242+Udjin79@users.noreply.github.com>
Date:   Sat Mar 23 16:14:45 2024 +0300

    Initial commit

```
