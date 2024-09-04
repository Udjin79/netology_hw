# Домашнее задание к занятию "`Жизненный цикл ПО`" - `Исаенков Евгений`

## Подготовка к выполнению

1. Получить бесплатную версию Jira - https://www.atlassian.com/ru/software/jira/work-management/free (скопируйте ссылку в адресную строку). Вы можете воспользоваться любым(в том числе бесплатным vpn сервисом) если сайт у вас недоступен. Кроме того вы можете скачать [docker образ](https://hub.docker.com/r/atlassian/jira-software/#) и запустить на своем хосте self-managed версию jira.
2. Настроить её для своей команды разработки.
3. Создать доски Kanban и Scrum.
4. [Дополнительные инструкции от разработчика Jira](https://support.atlassian.com/jira-cloud-administration/docs/import-and-export-issue-workflows/).

## Основная часть

Необходимо создать собственные workflow для двух типов задач: bug и остальные типы задач. Задачи типа bug должны проходить жизненный цикл:

1. Open -> On reproduce.
2. On reproduce -> Open, Done reproduce.
3. Done reproduce -> On fix.
4. On fix -> On reproduce, Done fix.
5. Done fix -> On test.
6. On test -> On fix, Done.
7. Done -> Closed, Open.

Остальные задачи должны проходить по упрощённому workflow:

1. Open -> On develop.
2. On develop -> Open, Done develop.
3. Done develop -> On test.
4. On test -> On develop, Done.
5. Done -> Closed, Open.

**Что нужно сделать**

1. Создайте задачу с типом bug, попытайтесь провести его по всему workflow до Done. 
2. Создайте задачу с типом epic, к ней привяжите несколько задач с типом task, проведите их по всему workflow до Done. 
3. При проведении обеих задач по статусам используйте kanban. 
4. Верните задачи в статус Open.
5. Перейдите в Scrum, запланируйте новый спринт, состоящий из задач эпика и одного бага, стартуйте спринт, проведите задачи до состояния Closed. Закройте спринт.
6. Если всё отработалось в рамках ожидания — выгрузите схемы workflow для импорта в XML. Файлы с workflow и скриншоты workflow приложите к решению задания.


### Ответ

1. Создан Software проект, сделаны 2 кастомных бизнес-процесса согласно ТЗ. 
![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_1.png?raw=true)
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_3.png?raw=true)
![Название скриншота 4](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_4.png?raw=true)

2. Схема типов задач оставлена стандартная, т.к. она удовлетворяет ТЗ и содержит все необходимые типы задач.
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_2.png?raw=true)

3. Сделана Kanban доска, и созданы колонки, соответствующие статусам бизнес процесса.
![Название скриншота 5](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_5.png?raw=true)

4. Видим, что при переходе задач между статусами активны только те колонки, которые доступны задаче в их текущем статусе
![Название скриншота 6](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_6.png?raw=true)
![Название скриншота 7](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_7.png?raw=true)
![Название скриншота 8](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_8.png?raw=true)
![Название скриншота 9](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_9.png?raw=true)
![Название скриншота 10](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_10.png?raw=true)

**Важное замечание**

Перевести в Open задачи из статуса Closed невозможно, т.к. из данного статуса по бизнес-процессу, описанному в ТЗ, нет перехода в Open. Это финальный закрывающий статус. Для возврата в Open надо добавить переход между данными статусами, и не забыть добавить очистку системного поля "Решение", если оно проставлялось при переходе.

**Важное замечание 2**

Как сертифицированный Atlassian Administrator хотел бы заметить, что при закрытии задачи надо или добавлять экран, где проставляется решение, или выставлять фиксированное решение, как в приложенном к ДЗ бизнес-процессе. Если решение не выставлять, то задача не отмечается как решенная и в дальнейшем могут быть проблемы с отчетами по спринтам или отчетами вида Создано/Решено.

5. Сделана Scrum доска, и созданы колонки, соответствующие статусам бизнес процесса.
![Название скриншота 11](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_11.png?raw=true)

6. Создан и запущен спринт. При переходе задач между статусами, как и в Kanban доске, активны только те колонки, которые доступны задаче в их текущем статусе
![Название скриншота 12](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_12.png?raw=true)
![Название скриншота 13](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_13.png?raw=true)

**Важное замечание**

Спринт так же требует заполнения Story Points, т.к. оценка выполнения спринта (Burndown Report) делается именно на базе этих данных.
Это не критичное требование, спринт можно запустить и без оценки задач, просто будет показано предупреждение, которое можно игнорировать.

7. После решения задач спринт был закрыт. Увидеть его мы можем теперь только в отчете о спринтах. Там же мы можем увидеть даты спринта, задачи в которые в него входили и изменения в списке задач, если они были.
![Название скриншота 14](https://github.com/Udjin79/netology_hw/blob/main/img/09shcicd1_14.png?raw=true)
