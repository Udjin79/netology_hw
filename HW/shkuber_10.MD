# Домашнее задание к занятию "`Helm`" - `Исаенков Евгений`

### Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

------

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

---

## Ответ

### Задание 1. Подготовить Helm-чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

```bash
$ helm create my-app
Creating my-app

$ ls
my-app

$ helm list --all-namespaces
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION

$ yamllint my-app/templates/deployment.yaml

$ helm lint my-app
==> Linting my-app
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

------
### Задание 2. Запустить две версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.

```bash
$ kubectl create namespace app1
namespace/app1 created

$ helm install my-app-1 . --namespace app1 --set image.tag=1.19.3
NAME: my-app-1
LAST DEPLOYED: Thu Nov 28 19:11:13 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app1 -l "app.kubernetes.io/name=my-app,app.kubernetes.io/instance=my-app-1" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app1 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT

$ helm install my-app-2 . --namespace app1 --set image.tag=1.20.1
NAME: my-app-2
LAST DEPLOYED: Thu Nov 28 19:11:28 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app1 -l "app.kubernetes.io/name=my-app,app.kubernetes.io/instance=my-app-2" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app1 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app1 port-forward $POD_NAME 8080:$CONTAINER_PORT

$ kubectl create namespace app2
namespace/app2 created

$ helm install my-app-3 . --namespace app2 --set image.tag=1.19.3
NAME: my-app-3
LAST DEPLOYED: Thu Nov 28 19:12:14 2024
NAMESPACE: app2
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace app2 -l "app.kubernetes.io/name=my-app,app.kubernetes.io/instance=my-app-3" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace app2 $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace app2 port-forward $POD_NAME 8080:$CONTAINER_PORT
```

3. Продемонстрируйте результат.
  
```bash
$ kubectl get all -n app1
NAME                            READY   STATUS    RESTARTS   AGE
pod/my-app-1-668899d77-b68g9    1/1     Running   0          77s
pod/my-app-2-665bcc59fb-rtvjc   1/1     Running   0          63s

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/my-app-1   ClusterIP   10.152.183.188   <none>        80/TCP    77s
service/my-app-2   ClusterIP   10.152.183.138   <none>        80/TCP    63s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-app-1   1/1     1            1           77s
deployment.apps/my-app-2   1/1     1            1           63s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/my-app-1-668899d77    1         1         1       77s
replicaset.apps/my-app-2-665bcc59fb   1         1         1       63s

$ kubectl get all -n app2
NAME                            READY   STATUS    RESTARTS   AGE
pod/my-app-3-65856777f5-kpt5j   1/1     Running   0          23s

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/my-app-3   ClusterIP   10.152.183.114   <none>        80/TCP    23s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-app-3   1/1     1            1           23s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/my-app-3-65856777f5   1         1         1       23s

$ helm list --all-namespaces
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
my-app-1        app1            1               2024-11-28 19:11:13.620577055 +0000 UTC deployed        my-app-0.1.0    1.16.0
my-app-2        app1            1               2024-11-28 19:11:28.20854627 +0000 UTC  deployed        my-app-0.1.0    1.16.0
my-app-3        app2            1               2024-11-28 19:12:14.78032607 +0000 UTC  deployed        my-app-0.1.0    1.16.0

$ kubectl describe pod my-app-1-668899d77-b68g9 -n app1
Name:             my-app-1-668899d77-b68g9
Namespace:        app1
Priority:         0
Service Account:  default
Node:             brix/192.168.1.11
Start Time:       Thu, 28 Nov 2024 19:11:14 +0000
Labels:           app=my-app-1
                  pod-template-hash=668899d77
Annotations:      cni.projectcalico.org/containerID: 033e4db9b895e4ebb84d088b3592f4402c5326876c2766b3ec0ede7497f9a7a4
                  cni.projectcalico.org/podIP: 10.1.38.157/32
                  cni.projectcalico.org/podIPs: 10.1.38.157/32
Status:           Running
IP:               10.1.38.157
IPs:
  IP:           10.1.38.157
Controlled By:  ReplicaSet/my-app-1-668899d77
Containers:
  my-app:
    Container ID:   containerd://fcaf970bb4fe528b9e9c392288941badedce6084a107cc38618c27ecdf9ed0bb
    Image:          nginx:1.19.3
    Image ID:       docker.io/library/nginx@sha256:ed7f815851b5299f616220a63edac69a4cc200e7f536a56e421988da82e44ed8
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Thu, 28 Nov 2024 19:11:29 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mbr8l (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-mbr8l:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```