# Домашнее задание к занятию "`Хранение в K8s. Часть 1`" - `Исаенков Евгений`

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

---

## Ответ

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.

```bash
$ kubectl apply -f busybox-multitool-deployment.yaml
deployment.apps/busybox-multitool-deployment created
$ kubectl get pods -l app=busybox-multitool
NAME                                            READY   STATUS    RESTARTS   AGE
busybox-multitool-deployment-67dd5bb78f-8sh2r   2/2     Running   0          21s
```

4. Продемонстрировать, что multitool может читать файл, который периодически обновляется.

```bash
$ kubectl exec -it busybox-multitool-deployment-67dd5bb78f-8sh2r -c multitool -- sh
/ # tail -f /data/shared-file.txt
Текущее время: Mon Nov 25 18:54:23 UTC 2024
Текущее время: Mon Nov 25 18:54:28 UTC 2024
Текущее время: Mon Nov 25 18:54:33 UTC 2024
Текущее время: Mon Nov 25 18:54:38 UTC 2024
Текущее время: Mon Nov 25 18:54:43 UTC 2024
Текущее время: Mon Nov 25 18:54:48 UTC 2024
Текущее время: Mon Nov 25 18:54:53 UTC 2024
Текущее время: Mon Nov 25 18:54:58 UTC 2024
Текущее время: Mon Nov 25 18:55:03 UTC 2024
Текущее время: Mon Nov 25 18:55:08 UTC 2024
Текущее время: Mon Nov 25 18:55:13 UTC 2024
Текущее время: Mon Nov 25 18:55:18 UTC 2024
^C
/ # exit
command terminated with exit code 130
```

5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.

```bash
$ kubectl apply -f multitool-daemonset.yaml
daemonset.apps/multitool-daemonset created

$ kubectl get daemonsets
NAME                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
multitool-daemonset   1         1         1       1            1           <none>          14s

$ kubectl get pods -l app=multitool-daemonset
NAME                        READY   STATUS    RESTARTS   AGE
multitool-daemonset-4cgs4   1/1     Running   0          19s
```

3. Продемонстрировать возможность чтения файла изнутри пода.

```bash
$ POD_NAME=$(kubectl get pods -l app=multitool-daemonset -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $POD_NAME -- sh
/ # cat /var/log/syslog
Nov 25 20:15:09 Brix systemd[1]: run-containerd-runc-k8s.io-9af3d672e4c8.mount: Deactivated successfully.
Nov 25 20:15:10 Brix systemd[1]: 1cf4a89b25de-run.woHWw.mount: Deactivated successfully.
Nov 25 20:15:11 Brix systemd[1]: run-containerd-runc-k8s.io-6e7c32fba1d4.mount: Deactivated successfully.
Nov 25 20:15:12 Brix systemd[1]: 7e8f93ad21bc-run.eXpRf.mount: Deactivated successfully.
Nov 25 20:15:13 Brix systemd[1]: run-containerd-runc-k8s.io-2d8f1b46e79a.mount: Deactivated successfully.
Nov 25 20:15:14 Brix systemd[1]: 8cf27a1d93eb-run.hDQwL.mount: Deactivated successfully.
Nov 25 20:15:15 Brix systemd[1]: run-containerd-runc-k8s.io-3a7b2f49c8ed.mount: Deactivated successfully.
Nov 25 20:15:16 Brix systemd[1]: 2db8e1f473ca-run.nJWZx.mount: Deactivated successfully.
Nov 25 20:15:17 Brix systemd[1]: run-containerd-runc-k8s.io-4c6a2b89d7fe.mount: Deactivated successfully.
Nov 25 20:15:18 Brix systemd[1]: 9eb1cf374a62-run.rMqYp.mount: Deactivated successfully.
```

4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.
