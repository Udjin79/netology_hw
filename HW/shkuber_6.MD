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
/ # tail -f /var/log/syslog
2024-11-25T21:07:15.386754+00:00 ubuntu systemd[1]: Cannot find unit for notify message of PID 469315, ignoring.
2024-11-25T21:07:16.228396+00:00 ubuntu systemd[1]: Cannot find unit for notify message of PID 469414, ignoring.
2024-11-25T21:07:21.302263+00:00 ubuntu systemd[1]: Cannot find unit for notify message of PID 469482, ignoring.
2024-11-25T21:07:21.551030+00:00 ubuntu systemd[1]: run-containerd-runc-k8s.io-e2489c98e9851ebd79310eac7d36b8aa6639d569c3fc9a25fc28dac75d4aa1df-runc.3WAJVu.mount: Deactivated successfully.
2024-11-25T21:07:27.976456+00:00 ubuntu systemd[1]: Cannot find unit for notify message of PID 469813, ignoring.
2024-11-25T21:07:33.632578+00:00 ubuntu systemd[1]: run-containerd-runc-k8s.io-ab9384ab0041eb6ebfa9ded8a1d3a51c8f5aec870714c15af1c730adfc976722-runc.zHksCB.mount: Deactivated successfully.
^C
```

4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.
