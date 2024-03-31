# Домашнее задание к занятию "`Ветвления в Git`" - `Исаенков Евгений`

---

### Задание 1

### Инструкция к заданию

1. В личном кабинете отправьте на проверку ссылку на network графика вашего репозитория.
2. Любые вопросы по решению задач задавайте в чате учебной группы.


### Дополнительные материалы для выполнения задания

1. Тренажёр [LearnGitBranching](https://learngitbranching.js.org/), где можно потренироваться в работе с деревом коммитов и ветвлений. 

------

## Задание «Ветвление, merge и rebase»  

**Шаг 1.** Предположим, что есть задача — написать скрипт, выводящий на экран параметры его запуска. 
Давайте посмотрим, как будет отличаться работа над этим скриптом с использованием ветвления, merge и rebase. 

Создайте в своём репозитории каталог `branching` и в нём два файла — `merge.sh` и `rebase.sh` — с 
содержимым:

```bash
#!/bin/bash
# display command line options

count=1
for param in "$*"; do
    echo "\$* Parameter #$count = $param"
    count=$(( $count + 1 ))
done
```

Этот скрипт отображает на экране все параметры одной строкой, а не разделяет их.

**Шаг 2.** Создадим коммит с описанием `prepare for merge and rebase` и отправим его в ветку main. 

#### Подготовка файла merge.sh 
 
**Шаг 1.** Создайте ветку `git-merge`. 

**Шаг 2**. Замените в ней содержимое файла `merge.sh` на:

```bash
#!/bin/bash
# display command line options

count=1
for param in "$@"; do
    echo "\$@ Parameter #$count = $param"
    count=$(( $count + 1 ))
done
```

**Шаг 3.** Создайте коммит `merge: @ instead *`, отправьте изменения в репозиторий.  
**Шаг 4.** Разработчик подумал и решил внести ещё одно изменение в `merge.sh`:
 
```bash
#!/bin/bash
# display command line options

count=1
while [[ -n "$1" ]]; do
    echo "Parameter #$count = $1"
    count=$(( $count + 1 ))
    shift
done
```

Теперь скрипт будет отображать каждый переданный ему параметр отдельно. 

**Шаг 5.** Создайте коммит `merge: use shift` и отправьте изменения в репозиторий. 

#### Изменим main  

**Шаг 1.** Вернитесь в ветку `main`. 
**Шаг 2.** Предположим, что пока мы работали над веткой `git-merge`, кто-то изменил `main`. Для этого
изменим содержимое файла `rebase.sh` на:

```bash
#!/bin/bash
# display command line options

count=1
for param in "$@"; do
    echo "\$@ Parameter #$count = $param"
    count=$(( $count + 1 ))
done

echo "====="
```

В этом случае скрипт тоже будет отображать каждый параметр в новой строке. 

**Шаг 3.** Отправляем изменённую ветку `main` в репозиторий.

#### Подготовка файла rebase.sh  

**Шаг 1.** Предположим, что теперь другой участник нашей команды не сделал `git pull` либо просто хотел ответвиться не от последнего коммита в `main`, а от коммита, когда мы только создали два файла
`merge.sh` и `rebase.sh` на первом шаге.  
Для этого при помощи команды `git log` найдём хеш коммита `prepare for merge and rebase` и выполним `git checkout` на него так:
`git checkout 8baf217e80ef17ff577883fda90f6487f67bbcea` (хеш будет другой).
**Шаг 2.** Создадим ветку `git-rebase`, основываясь на текущем коммите. 
**Шаг 3.** И изменим содержимое файла `rebase.sh` на следующее, тоже починив скрипт, но немного в другом стиле:

```bash
#!/bin/bash
# display command line options

count=1
for param in "$@"; do
    echo "Parameter: $param"
    count=$(( $count + 1 ))
done

echo "====="
```

**Шаг 4.** Отправим эти изменения в ветку `git-rebase` с комментарием `git-rebase 1`.

**Шаг 5.** И сделаем ещё один коммит `git-rebase 2` с пушем, заменив `echo "Parameter: $param"` на `echo "Next parameter: $param"`.

#### Промежуточный итог  

Мы сэмулировали типичную ситуации в разработке кода, когда команда разработчиков работала над одним и тем же участком кода, и кто-то из разработчиков 
предпочитает делать `merge`, а кто-то — `rebase`. Конфликты с merge обычно решаются просто, 
а с rebase бывают сложности, поэтому давайте смержим все наработки в `main` и разрешим конфликты. 

Если всё было сделано правильно, то на странице `network` в GitHub, находящейся по адресу 
`https://github.com/ВАШ_ЛОГИН/ВАШ_РЕПОЗИТОРИЙ/network`, будет примерно такая схема:
  
#### Merge

Сливаем ветку `git-merge` в main и отправляем изменения в репозиторий, должно получиться без конфликтов:

```bash
$ git merge git-merge
Merge made by the 'recursive' strategy.
 branching/merge.sh | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
$ git push
#!/bin/bash
Enumerating objects: 1, done.
Counting objects: 100% (1/1), done.
Writing objects: 100% (1/1), 223 bytes | 223.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0), pack-reused 0
```  

#### Rebase

**Шаг 1.** Перед мержем ветки `git-rebase` выполним её `rebase` на main. Да, мы специально создали ситуацию с конфликтами, чтобы потренироваться их решать. 
**Шаг 2.** Переключаемся на ветку `git-rebase` и выполняем `git rebase -i main`. 
В открывшемся диалоге должно быть два выполненных коммита, давайте заодно объединим их в один, 
указав слева от нижнего `fixup`. 
В результате получаем:

```bash
$ git rebase -i main
Auto-merging branching/rebase.sh
CONFLICT (content): Merge conflict in branching/rebase.sh
error: could not apply dc4688f... git 2.3 rebase @ instead *
Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".
Could not apply dc4688f... git 2.3 rebase @ instead *
``` 

Если посмотреть содержимое файла `rebase.sh`, то увидим метки, оставленные Git для решения конфликта:

```bash
cat rebase.sh
#!/bin/bash
# display command line options
count=1
for param in "$@"; do
<<<<<<< HEAD
    echo "\$@ Parameter #$count = $param"
=======
    echo "Parameter: $param"
>>>>>>> dc4688f... git 2.3 rebase @ instead *
    count=$(( $count + 1 ))
done
```

**Шаг 3.** Удалим метки, отдав предпочтение варианту:

```bash
echo "\$@ Parameter #$count = $param"
```

**Шаг 4.** Сообщим Git, что конфликт решён `git add rebase.sh` и продолжим rebase `git rebase --continue`.

**Шаг 5.** Опять получим конфликт в файле `rebase.sh` при попытке применения нашего второго коммита. Давайте разрешим конфликт, оставив строчку `echo "Next parameter: $param"`.

**Шаг 6.** Далее опять сообщаем Git о том, что конфликт разрешён — `git add rebase.sh` — и продолжим rebase — `git rebase --continue`.

В результате будет открыт текстовый редактор, предлагающий написать комментарий к новому объединённому коммиту:

```
# This is a combination of 2 commits.
# This is the 1st commit message:

Merge branch 'git-merge'

# The commit message #2 will be skipped:

# git 2.3 rebase @ instead * (2)
```

Все строчки, начинающиеся на `#`, будут проигнорированны. 

После сохранения изменения Git сообщит:

```
Successfully rebased and updated refs/heads/git-rebase
```

**Шаг 7.** И попробуем выполнить `git push` либо `git push -u origin git-rebase`, чтобы точно указать, что и куда мы хотим запушить. 

Эта команда завершится с ошибкой:

```bash
git push
To github.com:andrey-borue/devops-netology.git
 ! [rejected]        git-rebase -> git-rebase (non-fast-forward)
error: failed to push some refs to 'git@github.com:andrey-borue/devops-netology.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Это произошло, потому что мы пытаемся перезаписать историю. 

**Шаг 8.** Чтобы Git позволил нам это сделать, добавим флаг `force`:

```bash
git push -u origin git-rebase -f
Enumerating objects: 10, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 12 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 443 bytes | 443.00 KiB/s, done.
Total 4 (delta 1), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To github.com:andrey-borue/devops-netology.git
 + 1829df1...e3b942b git-rebase -> git-rebase (forced update)
Branch 'git-rebase' set up to track remote branch 'git-rebase' from 'origin'.
```

**Шаг 9**. Теперь можно смержить ветку `git-rebase` в main без конфликтов и без дополнительного мерж-комита простой перемоткой: 

```
$ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

$ git merge git-rebase
Updating 6158b76..45893d1
Fast-forward
 branching/rebase.sh | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)
```

*В качестве результата работы по всем заданиям приложите ссылку на .md-файл в вашем репозитории.*

### Ответ

**Подготовка каталога и файлов**
```bash
$ ls


    Каталог: H:\DevOps\GitHub\devops-netology\branching


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        31.03.2024     12:17              0 merge.sh
-a----        31.03.2024     12:17              0 rebase.sh
```

```bash
$ git add .
$ git commit -m "prepare for merge and rebase"
[main df1a0b6] prepare for merge and rebase
 2 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 branching/merge.sh
 create mode 100644 branching/rebase.sh
$ git push origin main
To https://github.com/Udjin79/devops-netology.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'https://github.com/Udjin79/devops-netology.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. If you want to integrate the remote changes,
hint: use 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
$ git pull origin main
From https://github.com/Udjin79/devops-netology
 * branch            main       -> FETCH_HEAD
Merge made by the 'ort' strategy.
 README.md | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)
$ git push origin main
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 6 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 613 bytes | 613.00 KiB/s, done.
Total 5 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (2/2), completed with 1 local object.
To https://github.com/Udjin79/devops-netology.git
   a3a8b8a..2c5e0c5  main -> main
```
**Подготовка файла merge.sh**
```bash
$ git checkout -b git-merge
Switched to a new branch 'git-merge'
$ git add merge.sh
$ git commit -m "merge: @ instead *"
[git-merge 5bb0e18] merge: @ instead *
 1 file changed, 8 insertions(+)
$ git add merge.sh
$ git commit -m "merge: use shift"
[git-merge 7161ab8] merge: use shift
 1 file changed, 3 insertions(+), 2 deletions(-)
$ git push -u origin git-merge
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 6 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (8/8), 900 bytes | 900.00 KiB/s, done.
Total 8 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (2/2), completed with 1 local object.
remote:
remote: Create a pull request for 'git-merge' on GitHub by visiting:
remote:      https://github.com/Udjin79/devops-netology/pull/new/git-merge
remote:
To https://github.com/Udjin79/devops-netology.git
 * [new branch]      git-merge -> git-merge
branch 'git-merge' set up to track 'origin/git-merge'.
```
**Изменим main**
```bash
$ git checkout main
M       branching/rebase.sh
Switched to branch 'main'
Your branch is ahead of 'gitlab/main' by 4 commits.
  (use "git push" to publish your local commits)
$ git add rebase.sh
$ git commit -m "show parameters in new line"
[main 19c9c70] show parameters in new line
 1 file changed, 10 insertions(+)
$ git push -u origin main
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 6 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 476 bytes | 476.00 KiB/s, done.
Total 4 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To https://github.com/Udjin79/devops-netology.git
   2c5e0c5..19c9c70  main -> main
branch 'main' set up to track 'origin/main'.
```
**Подготовка файла rebase.sh**
```bash
$ git log --all --grep='prepare for merge and rebase'
commit df1a0b6b168516e3284e4a09e83a84102ba54314
Author: Evgeniy Isaenkov <johndoe@example.com>
Date:   Sun Mar 31 12:18:05 2024 +0300

    prepare for merge and rebase
$ git checkout df1a0b6b168516e3284e4a09e83a84102ba54314
Note: switching to 'df1a0b6b168516e3284e4a09e83a84102ba54314'.
HEAD is now at df1a0b6 prepare for merge and rebase
$ git checkout -b git-rebase
Switched to a new branch 'git-rebase'
$ git add rebase.sh
$ git commit -m "git-rebase 1"
[git-rebase e4db13e] git-rebase 1
 1 file changed, 10 insertions(+)
$ git add rebase.sh
$ git commit -m "git-rebase 2"
[git-rebase 70f0f43] git-rebase 2
 1 file changed, 1 insertion(+), 1 deletion(-)
 $ git push -u origin git-rebase
Enumerating objects: 11, done.
Counting objects: 100% (11/11), done.
Delta compression using up to 6 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (8/8), 781 bytes | 781.00 KiB/s, done.
Total 8 (delta 3), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (3/3), completed with 1 local object.
remote:
remote: Create a pull request for 'git-rebase' on GitHub by visiting:
remote:      https://github.com/Udjin79/devops-netology/pull/new/git-rebase
remote:
To https://github.com/Udjin79/devops-netology.git
 * [new branch]      git-rebase -> git-rebase
branch 'git-rebase' set up to track 'origin/git-rebase'.
 ```
**Промежуточный итог**

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/git3_1.png?raw=true)

**Merge**
 ```bash
 $ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
$ git pull origin main
From https://github.com/Udjin79/devops-netology
 * branch            main       -> FETCH_HEAD
Already up to date.
$ git merge git-merge
Merge made by the 'ort' strategy.
 branching/merge.sh | 9 +++++++++
 1 file changed, 9 insertions(+)
$ git push origin main
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 6 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 371 bytes | 371.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To https://github.com/Udjin79/devops-netology.git
   19c9c70..ac95539  main -> main
```
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/git3_2.png?raw=true)

**Rebase**
```bash
$ git checkout git-rebase
Already on 'git-rebase'
Your branch is ahead of 'origin/git-rebase' by 6 commits.
  (use "git push" to publish your local commits)
$ git rebase -i main
Auto-merging branching/rebase.sh
CONFLICT (content): Merge conflict in branching/rebase.sh
error: could not apply e4db13e... git-rebase 1
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
Could not apply e4db13e... git-rebase 1
$ git add rebase.sh
$ git rebase --continue
Auto-merging branching/rebase.sh
CONFLICT (content): Merge conflict in branching/rebase.sh
error: could not apply 70f0f43... git-rebase 2
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
Could not apply 70f0f43... git-rebase 2
$ git add rebase.sh
$ git rebase --continue
[detached HEAD 2b892d2] Merge branch 'git-merge'
 Date: Sun Mar 31 12:51:42 2024 +0300
Successfully rebased and updated refs/heads/git-rebase.
```
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/git3_3.png?raw=true)

```bash
$ git push -u origin git-rebase
To https://github.com/Udjin79/devops-netology.git
 ! [rejected]        git-rebase -> git-rebase (non-fast-forward)
error: failed to push some refs to 'https://github.com/Udjin79/devops-netology.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. If you want to integrate the remote changes,
hint: use 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
$ git push -u origin git-rebase -f
Enumerating objects: 10, done.
Counting objects: 100% (10/10), done.
Delta compression using up to 6 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 438 bytes | 438.00 KiB/s, done.
Total 4 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To https://github.com/Udjin79/devops-netology.git
 + 70f0f43...2b892d2 git-rebase -> git-rebase (forced update)
branch 'git-rebase' set up to track 'origin/git-rebase'.
```

```bash
$ git checkout main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
$ git merge git-rebase
Merge made by the 'ort' strategy.
 branching/rebase.sh | 1 +
 1 file changed, 1 insertion(+)
```
