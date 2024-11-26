# Домашнее задание к занятию "`Конфигурация приложений`" - `Исаенков Евгений`

### Цель задания

В тестовой среде Kubernetes необходимо создать конфигурацию и продемонстрировать работу приложения.

------

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
2. Решить возникшую проблему с помощью ConfigMap.
3. Продемонстрировать, что pod стартовал и оба конейнера работают.
4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

1. Создать Deployment приложения, состоящего из Nginx.
2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.
3. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.
4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

---

## Ответ

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
2. Решить возникшую проблему с помощью ConfigMap.

```bash
$ kubectl apply -f configMap-http.yaml
configmap/nginx-web-page created

$ kubectl apply -f deployment-http.yaml
deployment.apps/nginx-http created

$ kubectl apply -f service-http.yaml
service/nginx-http-service created
```

3. Продемонстрировать, что pod стартовал и оба конейнера работают.
```bash
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
nginx-http-fd679677f-ks26k     1/1     Running   0          4m

$ kubectl get svc
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes            ClusterIP   10.152.183.1     <none>        443/TCP   10h
nginx-http-service    ClusterIP   10.152.183.40    <none>        80/TCP    34m
```

4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.

```bash
$ kubectl port-forward service/nginx-http-service 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
```

```bash
udjin@brix:~$ curl http://localhost:8080
<!DOCTYPE html>
<html>
<body>
<h1>Hello from HTTP!</h1>
</body>
</html>
```

5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

1. Создать Deployment приложения, состоящего из Nginx.

```bash
$ kubectl apply -f deployment-https.yaml
deployment.apps/nginx-https created

$ kubectl apply -f service-https.yaml
service/nginx-https-service created
```

2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.

```bash
$ kubectl apply -f configMap-https.yaml
configmap/nginx-web-page-https created
```

3. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.

```bash
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=localhost"
...+............+...+..+....+........................+........+...+....+..+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.................+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*............+..+.......+......+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
..+..+...+......+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+.+.........+............+...+.........+.......................+....+...+..+.+..+......+.+.....+....+..+....+...+...........+......+.+........+.......+...+..+.........+....+.....+....+......+.....+......+.+...............+...............+.....+...+.+.....+.+...+.........+..+.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+............+...+...+....+........+.+......+........+......+.+.....+...+.+..+............+.......+......+.....+.......+...+.....+.......+.....+.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----
```

4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 

```bash
$ kubectl create secret tls nginx-tls-secret --key tls.key --cert tls.crt
secret/nginx-tls-secret created

$ kubectl get secrets
NAME               TYPE                DATA   AGE
nginx-tls-secret   kubernetes.io/tls   2      58s

$ kubectl get svc
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes            ClusterIP   10.152.183.1     <none>        443/TCP   10h
nginx-http-service    ClusterIP   10.152.183.40    <none>        80/TCP    21m
nginx-https-service   ClusterIP   10.152.183.218   <none>        80/TCP    27s

$ kubectl apply -f ingress.yaml
ingress.networking.k8s.io/nginx-https-ingress created

$ kubectl get ingress nginx-https-ingress
NAME                  CLASS   HOSTS       ADDRESS   PORTS     AGE
nginx-https-ingress   nginx   localhost             80, 443   49s

$ kubectl port-forward --namespace ingress-nginx service/ingress-nginx-controller 8443:443
Forwarding from 127.0.0.1:8443 -> 443
Forwarding from [::1]:8443 -> 443
Handling connection for 8443

$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

$ kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-7kt5k        0/1     Completed   0          2m50s
ingress-nginx-admission-patch-s6pfc         0/1     Completed   1          2m50s
ingress-nginx-controller-7d56585cd5-tp9mr   1/1     Running     0          2m50s
```

```bash
$ curl -k https://localhost:8443
<!DOCTYPE html>
<html>
<body>
<h1>Hello from HTTPS!</h1>
</body>
</html>
```

5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.
