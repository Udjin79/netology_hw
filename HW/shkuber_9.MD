# Домашнее задание к занятию "`Управление доступом`" - `Исаенков Евгений`

### Цель задания

В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

------

### Задание 1. Создайте конфигурацию для подключения пользователя

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.
2. Настройте конфигурационный файл kubectl для подключения.
3. Создайте роли и все необходимые настройки для пользователя.
4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).
5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.

---

## Ответ

### Задание 1. Создайте конфигурацию для подключения пользователя

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.

```bash
$ mkdir ~/certs
$ cd ~/certs

$ openssl genrsa -out user.key 2048
$ openssl req -new -key user.key -out user.csr -subj "/CN=regular-user"
$ sudo openssl x509 -req -in user.csr -CA /var/snap/microk8s/current/certs/ca.crt \
  -CAkey /var/snap/microk8s/current/certs/ca.key -CAcreateserial \
  -out user.crt -days 365
Certificate request self-signature ok
subject=CN = regular-user
```

2. Настройте конфигурационный файл kubectl для подключения.
  
```bash
$ kubectl config view --raw > kubeconfig

$ kubectl --kubeconfig=kubeconfig config set-credentials regular-user \
  --client-certificate=$(pwd)/user.crt \
  --client-key=$(pwd)/user.key
User "regular-user" set.

$ CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')

$ CLUSTER_SERVER=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')

$ CLUSTER_CA=$(kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority}')

$ kubectl --kubeconfig=kubeconfig config set-context regular-user-context \
  --cluster=$CLUSTER_NAME \
  --user=regular-user
Context "regular-user-context" created.

$ kubectl --kubeconfig=kubeconfig config use-context regular-user-context
Switched to context "regular-user-context".
```

3. Создайте роли и все необходимые настройки для пользователя.

```bash
$ kubectl apply -f role.yaml
role.rbac.authorization.k8s.io/pod-reader created

$ kubectl apply -f rolebinding.yaml
rolebinding.rbac.authorization.k8s.io/read-pods-binding created
```

4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).

```bash
$ kubectl run nginx --image=nginx --restart=Never
pod/nginx created

$ kubectl --kubeconfig=kubeconfig get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          32s

$ kubectl --kubeconfig=kubeconfig describe pod nginx
Name:             nginx
Namespace:        default
Priority:         0
Service Account:  default
...
...
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  57s   default-scheduler  Successfully assigned default/nginx to brix
  Normal  Pulling    57s   kubelet            Pulling image "nginx"
  Normal  Pulled     42s   kubelet            Successfully pulled image "nginx" in 15.263s (15.263s including waiting). Image size: 72996017 bytes.
  Normal  Created    42s   kubelet            Created container nginx
  Normal  Started    42s   kubelet            Started container nginx

$ kubectl --kubeconfig=kubeconfig logs nginx
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/11/28 17:49:38 [notice] 1#1: using the "epoll" event method
2024/11/28 17:49:38 [notice] 1#1: nginx/1.27.3
2024/11/28 17:49:38 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2024/11/28 17:49:38 [notice] 1#1: OS: Linux 6.8.0-49-generic
2024/11/28 17:49:38 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
2024/11/28 17:49:38 [notice] 1#1: start worker processes
2024/11/28 17:49:38 [notice] 1#1: start worker process 29
2024/11/28 17:49:38 [notice] 1#1: start worker process 30
2024/11/28 17:49:38 [notice] 1#1: start worker process 31
2024/11/28 17:49:38 [notice] 1#1: start worker process 32

$ kubectl get pods --all-namespaces | grep nginx
default              nginx                                        1/1     Running     0          2m34s
ingress-nginx        ingress-nginx-admission-create-7kt5k         0/1     Completed   0          47h
ingress-nginx        ingress-nginx-admission-patch-s6pfc          0/1     Completed   1          47h
ingress-nginx        ingress-nginx-controller-7d56585cd5-tp9mr    1/1     Running     0          47h

$ kubectl delete pod nginx
pod "nginx" deleted

$ kubectl --kubeconfig=kubeconfig run nginx --image=nginx
Error from server (Forbidden): pods is forbidden: User "regular-user" cannot create resource "pods" in API group "" in the namespace "default"
```

5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.
