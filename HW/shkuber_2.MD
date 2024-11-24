# Домашнее задание к занятию "`Базовые объекты K8S`" - `Исаенков Евгений`

## Задание

### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

---

## Ответ

### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.

```bash
$ cat hello-world-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - name: echoserver
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
    - containerPort: 8080

$ kubectl apply -f hello-world-pod.yaml
pod/hello-world created
```

3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

```bash
$ kubectl get pods
NAME          READY   STATUS              RESTARTS   AGE
hello-world   0/1     ContainerCreating   0          7s

$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          16s

$ kubectl port-forward pod/hello-world 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080

$ curl http://localhost:8080
Hostname: hello-world
Pod Information:
        -no pod information available-
Server values:
        server_version=nginx: 1.12.2 - lua: 10010
Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://localhost:8080/
Request Headers:
        accept=*/*
        host=localhost:8080
        user-agent=curl/7.81.0
Request Body:
        -no body in request-

$ kubectl delete pod hello-world
pod "hello-world" deleted

$ kubectl get pods
No resources found in default namespace.
```

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.

```bash
$ cat netology-web-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    app: netology
spec:
  containers:
  - name: echoserver
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
    - containerPort: 8080

$ cat netology-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
spec:
  selector:
    app: netology
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080

$ kubectl apply -f netology-web-pod.yaml
pod/netology-web created

$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
netology-web   1/1     Running   0          8s

$ kubectl apply -f netology-svc.yaml
service/netology-svc created

$ kubectl get services
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes     ClusterIP   10.152.183.1    <none>        443/TCP   87m
netology-svc   ClusterIP   10.152.183.39   <none>        80/TCP    13s
```

4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

```bash
$ kubectl port-forward service/netology-svc 8080:80
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080

$ kubectl describe service netology-svc
Name:                     netology-svc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=netology
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.152.183.39
IPs:                      10.152.183.39
Port:                     <unset>  80/TCP
TargetPort:               8080/TCP
Endpoints:                10.1.2.199:8080
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

$ kubectl delete -f netology-web-pod.yaml
kubectl delete -f netology-svc.yaml
pod "netology-web" deleted
service "netology-svc" deleted
```

```bash
$ curl http://localhost:8080
Hostname: netology-web
Pod Information:
        -no pod information available-
Server values:
        server_version=nginx: 1.12.2 - lua: 10010
Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://localhost:8080/
Request Headers:
        accept=*/*
        host=localhost:8080
        user-agent=curl/7.81.0
Request Body:
        -no body in request-
```

