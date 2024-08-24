# Домашнее задание к занятию "`Работа с Playbook`" - `Исаенков Евгений`

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook). Так же приложите скриншоты выполнения заданий №5-8
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

### Ответ

5.
```bash
$ ansible-lint site.yml
WARNING  Listing 6 violation(s) that are fatal
fqcn[action-core]: Use FQCN for builtin module actions (ansible.builtin.yum).
site.yml:27 Use ansible.builtin.dnf or ansible.legacy.dnf instead.

fqcn[action-core]: Use FQCN for builtin module actions (meta).
site.yml:35 Use ansible.builtin.meta or ansible.legacy.meta instead.

jinja[spacing]: Jinja2 spacing could be improved: create_db.rc != 0 and create_db.rc !=82 -> create_db.rc != 0 and create_db.rc != 82 (warning)
site.yml:37 Jinja2 template rewrite recommendation: create_db.rc != 0 and create_db.rc != 82.

fqcn[action-core]: Use FQCN for builtin module actions (ansible.builtin.yum).
site.yml:42 Use ansible.builtin.dnf or ansible.legacy.dnf instead.

risky-file-permissions: File permissions unset or incorrect.
site.yml:59 Task/Handler: Download Vector distribution

fqcn[action-core]: Use FQCN for builtin module actions (ansible.builtin.yum).
site.yml:63 Use ansible.builtin.dnf or ansible.legacy.dnf instead.

Read documentation for instructions on how to ignore specific rule violations.

                    Rule Violation Summary
 count tag                    profile    rule associated tags
     1 jinja[spacing]         basic      formatting (warning)
     1 risky-file-permissions safety     unpredictability
     4 fqcn[action-core]      production formatting

Failed: 5 failure(s), 1 warning(s) on 1 files. Last profile that met the validation criteria was 'min'.
```

1. **Use FQCN for builtin module actions**: В плейбуке `ansible-lint` нашел использование модулей `yum` и `meta`. Это можно исправить, заменив на полные имена, `ansible.builtin.dnf` для `yum` и `ansible.builtin.meta` для `meta`.

2. **Jinja2 spacing could be improved**: Обнаружена небольшая ошибка в пробелах внутри условия. Вместо `create_db.rc != 0 and create_db.rc !=82` должно быть `create_db.rc != 0 and create_db.rc != 82`. Не критично, но поправил.

3. **File permissions unset or incorrect**: `ansible-lint` заметил, что права на скачанный файл Vector не указаны или указаны некорректно. Обычно рекомендутся устанавливать более строгие права доступа, например, `mode: '0640'`, чтобы избежать потенциальных проблем с безопасностью.

После исправления ошибок
```bash
 ansible-lint site.yml

Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.
```

6.
```bash
$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] *************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] **************************************************************************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: OSError: Could not open: clickhouse-common-static-23.10.2.13.rpm clickhouse-client-23.10.2.13.rpm clickhouse-server-23.10.2.13.rpm
fatal: [clickhouse-01]: FAILED! => {"changed": false, "module_stderr": "Shared connection to 89.169.147.147 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/udjin79/.ansible/tmp/ansible-tmp-1724507161.845156-204823-39342938234815/AnsiballZ_dnf.py\", line 107, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/udjin79/.ansible/tmp/ansible-tmp-1724507161.845156-204823-39342938234815/AnsiballZ_dnf.py\", line 99, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/udjin79/.ansible/tmp/ansible-tmp-1724507161.845156-204823-39342938234815/AnsiballZ_dnf.py\", line 47, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.dnf', init_globals=dict(_module_fqn='ansible.modules.dnf', _modlib_path=modlib_path),\r\n  File \"/usr/lib64/python3.9/runpy.py\", line 225, in run_module\r\n    return _run_module_code(code, init_globals, run_name, mod_spec)\r\n  File \"/usr/lib64/python3.9/runpy.py\", line 97, in _run_module_code\r\n    _run_code(code, mod_globals, init_globals,\r\n  File \"/usr/lib64/python3.9/runpy.py\", line 87, in _run_code\r\n    exec(code, run_globals)\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_ljlxf4x6/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 1374, in <module>\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_ljlxf4x6/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 1363, in main\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_ljlxf4x6/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 1338, in run\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_ljlxf4x6/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 990, in ensure\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_ljlxf4x6/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 890, in _install_remote_rpms\r\n  File \"/usr/lib/python3.9/site-packages/dnf/base.py\", line 1343, in add_remote_rpms\r\n    raise IOError(_(\"Could not open: {}\").format(' '.join(pkgs_error)))\r\nOSError: Could not open: clickhouse-common-static-23.10.2.13.rpm clickhouse-client-23.10.2.13.rpm clickhouse-server-23.10.2.13.rpm\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}

PLAY RECAP ****************************************************************************************************************************************************
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```
По тексту ошибки видим, что не были загружены установочные файлы и поэтому не удалось проверить их установку.


7. 
```bash
$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] *************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] **************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Flush handlers] *****************************************************************************************************************************************

RUNNING HANDLER [Start clickhouse service] *********************************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Create database] ****************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Install required packages] ****************************************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install and configure Vector] *************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************
[WARNING]: Platform linux on host vector-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [vector-01]

TASK [Download Vector distribution] *************************************************************************************************************************************
changed: [vector-01]

TASK [Install Vector] *****************************************************************************************************************************************
changed: [vector-01]

TASK [Deploy Vector configuration] **************************************************************************************************************************************
--- before
+++ after: /home/udjin79/.ansible/tmp/ansible-local-204981ntx12v0q/tmpflfyildy/vector.j2
@@ -0,0 +1,9 @@
+# vector.j2
+[sources.in]
+  type = "stdin"
+
+[sinks.out]
+  inputs = ["in"]
+  type = "console"
+  encoding.codec = "json"
+

changed: [vector-01]

RUNNING HANDLER [Restart vector service] ***********************************************************************************************************************************************************************************************
changed: [vector-01]

PLAY RECAP ****************************************************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```bash
$ cat /etc/v
vconsole.conf  vector/        virc
$ cat /etc/vector/vector.toml
# vector.j2
[sources.in]
  type = "stdin"

[sinks.out]
  inputs = ["in"]
  type = "console"
  encoding.codec = "json"
```

Судя по результату playbook успешно выполнился.


8. 
```bash
$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] *************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] **************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers] *****************************************************************************************************************************************

TASK [Create database] ****************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install required packages] ****************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install and configure Vector] *************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************
[WARNING]: Platform linux on host vector-01 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
ok: [vector-01]

TASK [Download Vector distribution] *************************************************************************************************************************************
ok: [vector-01]

TASK [Install Vector] *****************************************************************************************************************************************
ok: [vector-01]

TASK [Deploy Vector configuration] **************************************************************************************************************************************
ok: [vector-01]

PLAY RECAP ****************************************************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

При повторном запуске видим, что результат не изменился.

---

