# Домашнее задание к занятию "`Установка Kubernetes`" - `Исаенков Евгений`

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.

```bash
$ terraform apply
yandex_vpc_network.develop: Refreshing state... [id=enpik5t5aidvao1d43io]
yandex_vpc_subnet.develop: Refreshing state... [id=e9blhdnkqt6ch4ici2d4]
yandex_compute_instance.master: Refreshing state... [id=fhm2cjoh4m9lddejr025]
yandex_compute_instance.workers[0]: Refreshing state... [id=fhm2c9rte4betsa1krf9]
yandex_compute_instance.workers[3]: Refreshing state... [id=fhm7uo6gig6266v760gk]
yandex_compute_instance.workers[2]: Refreshing state... [id=fhm2hvf7t1kue6q2gkkb]
yandex_compute_instance.workers[1]: Refreshing state... [id=fhm12qguccfttq07r0cd]

Note: Objects have changed outside of Terraform
...
...
...
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

master_public_ip = "89.169.153.251"
worker_public_ips = [
  "89.169.152.192",
  "89.169.150.97",
  "89.169.153.121",
  "89.169.153.176",
]

$ yc compute instance list
+----------------------+---------------+---------------+---------+----------------+-------------+
|          ID          |     NAME      |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+---------------+---------------+---------+----------------+-------------+
| fhm03ophljhelhn38gm3 | worker-node-3 | ru-central1-a | RUNNING | 89.169.152.192 | 10.0.1.8    |
| fhm634a0tis9ltr42mu7 | worker-node-1 | ru-central1-a | RUNNING | 89.169.150.97  | 10.0.1.33   |
| fhm74sh9s2mg7f8mqeag | worker-node-2 | ru-central1-a | RUNNING | 89.169.153.121 | 10.0.1.34   |
| fhm77abiha764u6idmno | worker-node-4 | ru-central1-a | RUNNING | 89.169.153.176 | 10.0.1.4    |
| fhmheo6ce2srlpfq47tb | master-node   | ru-central1-a | RUNNING | 89.169.153.251 | 10.0.1.38   |
+----------------------+---------------+---------------+---------+----------------+-------------+
```

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

## Дополнительные задания (со звёздочкой)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой необязательные к выполнению и не повлияют на получение зачёта по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA.
2. Использовать нечётное количество Master-node.
3. Для cluster ip использовать keepalived или другой способ.

---

## Ответ

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

master and worker nodes:
```bash
$ sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

$ sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

$ sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

$ sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io

$ sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io

$ containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```


master node:
```bash
$ sudo kubeadm init
I1130 18:00:01.184811   53886 version.go:256] remote version is much newer: v1.31.3; falling back to: stable-1.28
[init] Using Kubernetes version: v1.28.15
...
...
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.1.38:6443 --token p2z8uj.8iq4lerebl68yar8 \
        --discovery-token-ca-cert-hash sha256:d56fe749524b6c36787e00fbb7cfa50519d2b5926b7834e6413287bbd6e9f912


$ mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

worker nodes:
```bash
$ sudo kubeadm join 10.0.1.38:6443 --token p2z8uj.8iq4lerebl68yar8 \
        --discovery-token-ca-cert-hash sha256:d56fe749524b6c36787e00fbb7cfa50519d2b5926b7834e6413287bbd6e9f912
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

master node:
```bash
$ kubectl get pods -n kube-system
NAME                                           READY   STATUS    RESTARTS   AGE
coredns-5dd5756b68-8n7fp                       0/1     Pending   0          4m8s
coredns-5dd5756b68-8w9wn                       0/1     Pending   0          4m8s
etcd-fhmheo6ce2srlpfq47tb                      1/1     Running   0          4m13s
kube-apiserver-fhmheo6ce2srlpfq47tb            1/1     Running   0          4m13s
kube-controller-manager-fhmheo6ce2srlpfq47tb   1/1     Running   0          4m13s
kube-proxy-8b4bn                               1/1     Running   0          116s
kube-proxy-kfvwp                               1/1     Running   0          2m
kube-proxy-rx79v                               1/1     Running   0          2m6s
kube-proxy-vszs2                               1/1     Running   0          4m9s
kube-proxy-xw9wq                               1/1     Running   0          111s
kube-scheduler-fhmheo6ce2srlpfq47tb            1/1     Running   0          4m13s

$ kubectl get node
NAME                   STATUS   ROLES           AGE     VERSION
fhm03ophljhelhn38gm3   Ready    <none>          6m20s   v1.28.1
fhm634a0tis9ltr42mu7   Ready    <none>          6m30s   v1.28.1
fhm74sh9s2mg7f8mqeag   Ready    <none>          6m24s   v1.28.1
fhm77abiha764u6idmno   Ready    <none>          6m15s   v1.28.1
fhmheo6ce2srlpfq47tb   Ready    control-plane   8m41s   v1.28.1
```
