# Домашнее задание к занятию "`Сетевое взаимодействие в K8S. Часть 1`" - `Исаенков Евгений`

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

---

## Ответ

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.

```bash
$ kubectl apply -f deployment.yaml
deployment.apps/my-deployment created

$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
my-deployment-59fcffbc4d-24hjm   2/2     Running   0          37s
my-deployment-59fcffbc4d-2qjjc   2/2     Running   0          37s
my-deployment-59fcffbc4d-fl77q   2/2     Running   0          37s

$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   16m
```

2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.

```bash
$ kubectl apply -f service.yaml
service/my-service created
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP             17m
my-service   ClusterIP   10.106.69.201   <none>        9001/TCP,9002/TCP   5s
```

3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.

```bash
$ kubectl apply -f multitool.yaml
deployment.apps/multitool created
$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
multitool-7d9b7bfbd7-6l2jc       1/1     Running   0          20s
my-deployment-59fcffbc4d-24hjm   2/2     Running   0          2m29s
my-deployment-59fcffbc4d-2qjjc   2/2     Running   0          2m29s
my-deployment-59fcffbc4d-fl77q   2/2     Running   0          2m29s
```

4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.

```bash
$ kubectl exec multitool-7d9b7bfbd7-6l2jc -- curl my-service:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
<!DOCTYPE html>    0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
100   615  100   615    0     0   171k      0 --:--:-- --:--:-- --:--:--  200k

$ kubectl exec multitool-7d9b7bfbd7-6l2jc -- curl my-service:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0WBITT Network MultiTool (with NGINX) - my-deployment-59fcffbc4d-2qjjc - 10.244.0.23 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
100   150  100   150    0     0   103k      0 --:--:-- --:--:-- --:--:--  146k
```

5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

------


### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.

```bash
$ kubectl apply -f nodeport_service.yaml
service/nginx-service created

$ kubectl get pods -o wide
NAME                             READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
multitool-7d9b7bfbd7-4zvdg       1/1     Running   0          4m2s    10.244.0.8   minikube   <none>           <none>
my-deployment-59fcffbc4d-pjzft   2/2     Running   0          6m39s   10.244.0.5   minikube   <none>           <none>
my-deployment-59fcffbc4d-tb8qg   2/2     Running   0          6m39s   10.244.0.4   minikube   <none>           <none>
my-deployment-59fcffbc4d-ww2w8   2/2     Running   0          6m39s   10.244.0.3   minikube   <none>           <none>

$ kubectl get svc
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP                         25m
my-service      ClusterIP   10.108.204.7    <none>        9001/TCP,9002/TCP               4m28s
nginx-service   NodePort    10.101.53.158   <none>        9001:30080/TCP,9002:30082/TCP   94s

```

2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.

```bash
$ curl http://127.0.0.1:30080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

$ curl http://127.0.0.1:30082
WBITT Network MultiTool (with NGINX) - my-deployment-59fcffbc4d-ww2w8 - 10.244.0.3 - HTTP: 8080 , HTTPS: 11443 . (Formerly praqma/network-multitool)
```

3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber4_1.png?raw=true)
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber4_2.png?raw=true)
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber4_3.png?raw=true)
