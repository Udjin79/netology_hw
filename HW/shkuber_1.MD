# Домашнее задание к занятию "`Kubernetes. Причины появления. Команда kubectl`" - `Исаенков Евгений`

## Задание

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
2. Установить dashboard.
3. Сгенерировать сертификат для подключения к внешнему ip-адресу.

------

### Задание 2. Установка и настройка локального kubectl
1. Установить на локальную машину kubectl.
2. Настроить локально подключение к кластеру.
3. Подключиться к дашборду с помощью port-forward.

---

## Ответ

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.

```bash
$ sudo snap install microk8s --classic
microk8s (1.31/stable) v1.31.2 from Canonical✓ installed

$ sudo microk8s status --wait-ready
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
```

2. Установить dashboard.

```bash
$ microk8s enable dns dashboard

$ microk8s kubectl get pods -A
NAMESPACE     NAME                                         READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-759cd8b574-6kl6r     1/1     Running   0          3d21h
kube-system   calico-node-wb78q                            1/1     Running   0          3d21h
kube-system   coredns-7896dbf49-z8xlj                      1/1     Running   0          3d21h
kube-system   dashboard-metrics-scraper-6b96ff7878-lmwlf   1/1     Running   0          3d21h
kube-system   hostpath-provisioner-5fbc49d86c-cl7f4        1/1     Running   0          3d21h
kube-system   kubernetes-dashboard-7d869bcd96-j6ckq        1/1     Running   0          3d21h
kube-system   metrics-server-df8dbf7f5-bws5v               1/1     Running   0          3d21h
```

3. Сгенерировать сертификат для подключения к внешнему ip-адресу.

```bash
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout dashboard.key -out dashboard.crt \
  -subj "/CN=123.123.123.123"
...+......+.+........+.......+...+..+.+........+....+......+.....+..........+.........+..+...+......+....+...+.....+....+.........+......+.........+..+...+....+........+.......+..+.+............+...+.....+.......+......+.........+......+.....+.+.....+..........+.....+.+........+....+...+........+.+...+..+.+....+...+........+.+.....+..........+.....+.+.....+...+.+.....+...+................+.....+................+...+.....+...+..........+.........+...+...+...+......+......+..+.............+..+..........+........+...+......+..........+...+..+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.+.+...+...+........+..........+.................+.......+...+..+.+............+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*........+.+..+...+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*...+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
```
------

### Задание 2. Установка и настройка локального kubectl

1. Установить на локальную машину kubectl.

```bash
$ kubectl version
Client Version: v1.31.2
Kustomize Version: v5.4.2
Server Version: v1.31.2
```

2. Настроить локально подключение к кластеру.

```bash
$ microk8s config > kubeconfig

$ kubectl get po -A
NAMESPACE     NAME                                         READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-759cd8b574-gg2tl     1/1     Running   0          9m25s
kube-system   calico-node-fq8lw                            1/1     Running   0          9m25s
kube-system   coredns-7896dbf49-nmvkt                      1/1     Running   0          9m25s
kube-system   dashboard-metrics-scraper-6b96ff7878-gnbjj   1/1     Running   0          5m53s
kube-system   kubernetes-dashboard-7d869bcd96-rlsc7        1/1     Running   0          5m53s
kube-system   metrics-server-df8dbf7f5-8n8xm               1/1     Running   0          5m55s
```

3. Подключиться к дашборду с помощью port-forward.

```bash
$ kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
Forwarding from 127.0.0.1:10443 -> 8443
Forwarding from [::1]:10443 -> 8443
```