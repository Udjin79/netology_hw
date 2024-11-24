# Домашнее задание к занятию "`Базовые объекты K8S`" - `Запуск приложений в K8S`

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

---

## Ответ

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.

```bash
$ kubectl apply -f deployment.yaml
deployment.apps/nginx-multitool created

$ kubectl get pods
NAME                               READY   STATUS    RESTARTS     AGE
nginx-multitool-7db4bfc6b5-qzgft   2/2     Running   1 (4s ago)   43s
```

2. После запуска увеличить количество реплик работающего приложения до 2.

```bash
$ kubectl scale deployment nginx-multitool --replicas=2
deployment.apps/nginx-multitool scaled
```

3. Продемонстрировать количество подов до и после масштабирования.

```bash
$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
nginx-multitool-6d4886fdf6-9jjwr   2/2     Running   0          93s
nginx-multitool-6d4886fdf6-mvcmp   2/2     Running   0          54s
```

4. Создать Service, который обеспечит доступ до реплик приложений из п.1.

```bash
$ kubectl apply -f service.yaml
service/nginx-multitool-service created

$ kubectl get svc
NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
kubernetes                ClusterIP   10.96.0.1      <none>        443/TCP           30m
nginx-multitool-service   ClusterIP   10.99.167.14   <none>        80/TCP,1180/TCP   44s
```

5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

```bash
$ kubectl apply -f multitool.yaml
deployment.apps/multitool created

$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
multitool-6699b974db-c9jr8         1/1     Running   0          21s
nginx-multitool-6d4886fdf6-9jjwr   2/2     Running   0          9m45s
nginx-multitool-6d4886fdf6-mvcmp   2/2     Running   0          9m6s

$ kubectl exec multitool-6699b974db-c9jr8 -- curl nginx-multitool-service
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
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
100   615  100   615    0     0   330k      0 --:--:-- --:--:-- --:--:--  600k
```

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber3_1.png?raw=true)

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.

```bash
$ kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment created

$ kubectl get pods
NAME                                READY   STATUS     RESTARTS   AGE
multitool-6699b974db-c9jr8          1/1     Running    0          16m
nginx-deployment-6d8bccc48d-2bdnd   0/1     Init:0/1   0          14s
nginx-multitool-6d4886fdf6-9jjwr    2/2     Running    0          25m
nginx-multitool-6d4886fdf6-mvcmp    2/2     Running    0          24m

$ kubectl logs nginx-deployment-6d8bccc48d-2bdnd -c init-myservice

waiting for myservice

waiting for myservice

waiting for myservice
```

3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

```bash
$ kubectl apply -f nginx-service.yaml
service/nginx-service created
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
multitool-6699b974db-c9jr8          1/1     Running   0          17m
nginx-deployment-6d8bccc48d-2bdnd   1/1     Running   0          113s
nginx-multitool-6d4886fdf6-9jjwr    2/2     Running   0          27m
nginx-multitool-6d4886fdf6-mvcmp    2/2     Running   0          26m
```

![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber3_2.png?raw=true)
