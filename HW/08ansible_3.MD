# Домашнее задание к занятию "``" - `Исаенков Евгений`

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.
2. Репозиторий LightHouse находится [по ссылке](https://github.com/VKCOM/lighthouse).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.
4. Подготовьте свой inventory-файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Ответ

#### Подготовка

```bash
$ terraform validate
Success! The configuration is valid.

$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
...
...
...
Plan: 5 to add, 0 to change, 0 to destroy.

$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
...
...
...
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

5. 
```bash
$ ansible-lint playbook/site.yml

Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.
```

6. 
```bash
$ ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] 
---
TASK [Gathering Facts] 
ok: [clickhouse-01]

TASK [Get clickhouse distrib] 
---
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] 
---
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: OSError: Could not open: /home/centos/clickhouse-common-static-23.10.2.13.rpm /home/centos/clickhouse-client-23.10.2.13.rpm /home/centos/clickhouse-server-23.10.2.13.rpm
fatal: [clickhouse-01]: FAILED! => {"changed": false, "module_stderr": "Shared connection to 89.169.128.236 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/centos/.ansible/tmp/ansible-tmp-1725187087.9544601-224887-96085169511001/AnsiballZ_dnf.py\", line 107, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/centos/.ansible/tmp/ansible-tmp-1725187087.9544601-224887-96085169511001/AnsiballZ_dnf.py\", line 99, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/centos/.ansible/tmp/ansible-tmp-1725187087.9544601-224887-96085169511001/AnsiballZ_dnf.py\", line 47, in invoke_module\r\n    runpy.run_module(mod_name='ansible.modules.dnf', init_globals=dict(_module_fqn='ansible.modules.dnf', _modlib_path=modlib_path),\r\n  File \"/usr/lib64/python3.9/runpy.py\", line 225, in run_module\r\n    return _run_module_code(code, init_globals, run_name, mod_spec)\r\n  File \"/usr/lib64/python3.9/runpy.py\", line 97, in _run_module_code\r\n    _run_code(code, mod_globals, init_globals,\r\n  File \"/usr/lib64/python3.9/runpy.py\", line 87, in _run_code\r\n    exec(code, run_globals)\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_vp861f0j/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 1374, in <module>\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_vp861f0j/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 1363, in main\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_vp861f0j/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 1338, in run\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_vp861f0j/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 990, in ensure\r\n  File \"/tmp/ansible_ansible.legacy.dnf_payload_vp861f0j/ansible_ansible.legacy.dnf_payload.zip/ansible/modules/dnf.py\", line 890, in _install_remote_rpms\r\n  File \"/usr/lib/python3.9/site-packages/dnf/base.py\", line 1343, in add_remote_rpms\r\n    raise IOError(_(\"Could not open: {}\").format(' '.join(pkgs_error)))\r\nOSError: Could not open: /home/centos/clickhouse-common-static-23.10.2.13.rpm /home/centos/clickhouse-client-23.10.2.13.rpm /home/centos/clickhouse-server-23.10.2.13.rpm\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}

PLAY RECAP 
---
clickhouse-01              : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```
По тексту ошибки видим, что не были загружены установочные файлы и поэтому не удалось проверить их установку.


7. 
```bash
$ ansible-playbook -i inventory/prod.yml site.yml --diff

$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] 
---
TASK [Gathering Facts] 
---
ok: [clickhouse-01]

TASK [Get clickhouse distrib] 
---
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] 
---
changed: [clickhouse-01]

TASK [Flush handlers] 
---

RUNNING HANDLER [Start clickhouse service] 
---
changed: [clickhouse-01]

TASK [Create database]  
---
changed: [clickhouse-01]

TASK [Install required packages]  
---
changed: [clickhouse-01]

PLAY [Install and configure Vector]  
---

TASK [Gathering Facts]  
---
ok: [vector-01]

TASK [Download Vector distribution]  
---
changed: [vector-01]

TASK [Install Vector]  
---
changed: [vector-01]

TASK [Deploy Vector configuration]  
---
--- before
+++ after: /home/centos/.ansible/tmp/ansible-local-224896dt3kuwv0/tmpsev1464c/vector.j2
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

RUNNING HANDLER [Restart vector service]  
---
changed: [vector-01]

PLAY [Install and configure LightHouse]  
---

TASK [Gathering Facts]  
---
ok: [lighthouse-01]

TASK [Install required packages]  
---
changed: [lighthouse-01]

TASK [Clone LightHouse repository]  
---
>> Newly checked out d701335c25cd1bb9b5155711190bad8ab852c2ce
changed: [lighthouse-01]

TASK [Ensure permissions on LightHouse directory]  
---
ok: [lighthouse-01]

TASK [Install EPEL repo]  
---
changed: [lighthouse-01]

TASK [Install Nginx] 
---
changed: [lighthouse-01]

TASK [Deploy Nginx configuration for LightHouse] 
---
--- before
+++ after: /home/centos/.ansible/tmp/ansible-local-225265moy53kiq/tmpoozut21i/nginx_lighthouse.j2
@@ -0,0 +1,12 @@
+server {
+    listen 80;
+    server_name 0.0.0.0;
+
+    access_log /var/log/nginx/lighthouse-access.log;
+
+    location / {
+        root /var/www/lighthouse/data;
+        index index.html;
+
+    }
+}
\ No newline at end of file

changed: [lighthouse-01]

TASK [Ensure Nginx is running] 
---
changed: [lighthouse-01]

RUNNING HANDLER [Restart nginx service] 
---
changed: [lighthouse-01]

PLAY RECAP 
---
clickhouse-01              : ok=5    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
lighthouse-01              : ok=9    changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=4    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

Судя по результату playbook успешно выполнился.


8. 
```bash
$ ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] 
---

TASK [Gathering Facts] 
---
ok: [clickhouse-01]

TASK [Get clickhouse distrib] 
---
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] 
---
ok: [clickhouse-01]

TASK [Flush handlers] 
---

TASK [Create database] 
---
ok: [clickhouse-01]

TASK [Install required packages] 
---
ok: [clickhouse-01]

PLAY [Install and configure Vector] 
---

TASK [Gathering Facts] 
---
ok: [vector-01]

TASK [Download Vector distribution] 
---
ok: [vector-01]

TASK [Install Vector] 
---
ok: [vector-01]

TASK [Deploy Vector configuration] 
---
ok: [vector-01]

PLAY [Install and configure LightHouse] 
---

TASK [Gathering Facts] 
---
ok: [lighthouse-01]

TASK [Install required packages] 
---
ok: [lighthouse-01]

TASK [Clone LightHouse repository] 
---
ok: [lighthouse-01]

TASK [Ensure permissions on LightHouse directory] 
---
ok: [lighthouse-01]

TASK [Install EPEL repo] 
---
ok: [lighthouse-01]

TASK [Install Nginx] 
---
ok: [lighthouse-01]

TASK [Deploy Nginx configuration for LightHouse] 
---
ok: [lighthouse-01]

TASK [Ensure Nginx is running] 
---
ok: [lighthouse-01]

PLAY RECAP 
---
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
lighthouse-01              : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
vector-01                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

При повторном запуске видим, что результат не изменился.
