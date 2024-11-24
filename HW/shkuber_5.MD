# Домашнее задание к занятию "`Сетевое взаимодействие в K8S. Часть 2`" - `Исаенков Евгений`

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к двум приложениям снаружи кластера по разным путям.

------

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в MicroK8S.
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
4. Предоставить манифесты и скриншоты или вывод команды п.2.

---

## Ответ

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

```bash
$ kubectl apply -f frontend.yaml
deployment.apps/frontend-deployment created

$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
frontend-deployment-65d978c499-5jfq7   1/1     Running   0          32s
frontend-deployment-65d978c499-gnp57   1/1     Running   0          32s
frontend-deployment-65d978c499-gsbks   1/1     Running   0          32s

$ kubectl apply -f frontend_svc.yaml
service/frontend-service created

$ kubectl get svc
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
frontend-service   ClusterIP   10.96.105.165   <none>        80/TCP    9s
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP   79m

$ kubectl apply -f backend.yaml
deployment.apps/backend-deployment created

$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
backend-deployment-64576ccd57-5r9ss    1/1     Running   0          14s
frontend-deployment-65d978c499-5jfq7   1/1     Running   0          82s
frontend-deployment-65d978c499-gnp57   1/1     Running   0          82s
frontend-deployment-65d978c499-gsbks   1/1     Running   0          82s

$ kubectl apply -f backend_svc.yaml
service/backend-service created

$ kubectl get svc
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
backend-service    ClusterIP   10.104.236.124   <none>        80/TCP    3s
frontend-service   ClusterIP   10.96.105.165    <none>        80/TCP    51s
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP   80m

$ kubectl exec -it frontend-deployment-65d978c499-5jfq7 -- curl http://backend-service
WBITT Network MultiTool (with NGINX) - backend-deployment-64576ccd57-5r9ss - 10.244.0.13 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)

$ kubectl exec -it frontend-deployment-65d978c499-5jfq7 -- curl http://frontend-service
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
```

------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в Minikube.

```bash
$ minikube addons enable ingress
* ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
  - Используется образ registry.k8s.io/ingress-nginx/controller:v1.11.2
  - Используется образ registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.3
  - Используется образ registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.3
* Verifying ingress addon...
* The 'ingress' addon is enabled
```

2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.

```bash
$ kubectl apply -f ingress.yaml
ingress.networking.k8s.io/nginx created

$ kubectl get ingress
NAME    CLASS   HOSTS   ADDRESS        PORTS   AGE
nginx   nginx   *       192.168.49.2   80      18m

$ kubectl describe ingress
Name:             nginx
Labels:           <none>
Namespace:        default
Address:          192.168.49.2
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /      frontend-service:80 (10.244.0.9:80,10.244.0.11:80,10.244.0.10:80)
              /api   backend-service:80 (10.244.0.15:80)
Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
Events:
  Type    Reason  Age                  From                      Message
  ----    ------  ----                 ----                      -------
  Normal  Sync    3m56s (x3 over 20m)  nginx-ingress-controller  Scheduled for sync
```

3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.

```bash
$ curl http://192.168.49.2/api
WBITT Network MultiTool (with NGINX) - backend-deployment-64576ccd57-pzjcf - 10.244.0.15 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)

$ curl http://192.168.49.2/
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
```

4. Предоставить манифесты и скриншоты или вывод команды п.2.

![Название скриншота 1](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber5_1.png?raw=true)
![Название скриншота 2](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber5_2.png?raw=true)
![Название скриншота 3](https://github.com/Udjin79/netology_hw/blob/main/img/shkuber5_3.png?raw=true)
