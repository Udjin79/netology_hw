# Домашнее задание к занятию "`Хранение в K8s. Часть 2`" - `Исаенков Евгений`

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

---

## Ответ

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.

```bash
$ kubectl apply -f local-pv.yaml
persistentvolume/local-pv created

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                               STORAGECLASS        VOLUMEATTRIBUTESCLASS   REASON   AGE
local-pv                                   1Gi        RWX            Retain           Available                                       manual              <unset>                          31s
pvc-c01de902-abfa-4314-9525-9b37461e8328   20Gi       RWX            Delete           Bound       container-registry/registry-claim   microk8s-hostpath   <unset>                          8h

$ kubectl apply -f local-pvc.yaml
persistentvolumeclaim/local-pvc created

$ kubectl get pvc
NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
local-pvc   Bound    local-pv   1Gi        RWX            manual         <unset>                 7s

$ kubectl apply -f deployment.yaml
deployment.apps/busybox-multitool created

$ kubectl get pods
NAME                                 READY   STATUS    RESTARTS   AGE
busybox-multitool-86f89bb969-d4tfx   2/2     Running   0          17s
```

3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 

```bash
$ kubectl exec -it busybox-multitool-86f89bb969-d4tfx -c multitool -- sh
/ # cat /data/sharedfile.txt
Tue Nov 26 16:36:37 UTC 2024
Tue Nov 26 16:36:42 UTC 2024
Tue Nov 26 16:36:47 UTC 2024
Tue Nov 26 16:36:52 UTC 2024
Tue Nov 26 16:36:57 UTC 2024
Tue Nov 26 16:37:02 UTC 2024
Tue Nov 26 16:37:07 UTC 2024
Tue Nov 26 16:37:12 UTC 2024
Tue Nov 26 16:37:17 UTC 2024
Tue Nov 26 16:37:22 UTC 2024
Tue Nov 26 16:37:27 UTC 2024
/ # tail -f /data/sharedfile.txt
Tue Nov 26 16:36:57 UTC 2024
Tue Nov 26 16:37:02 UTC 2024
Tue Nov 26 16:37:07 UTC 2024
Tue Nov 26 16:37:12 UTC 2024
Tue Nov 26 16:37:17 UTC 2024
Tue Nov 26 16:37:22 UTC 2024
Tue Nov 26 16:37:27 UTC 2024
Tue Nov 26 16:37:32 UTC 2024
Tue Nov 26 16:37:37 UTC 2024
Tue Nov 26 16:37:42 UTC 2024
Tue Nov 26 16:37:47 UTC 2024
Tue Nov 26 16:37:52 UTC 2024
Tue Nov 26 16:37:57 UTC 2024
^C
/ # exit
command terminated with exit code 130
```

4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.

```bash
$ kubectl delete deployment busybox-multitool
deployment.apps "busybox-multitool" deleted

$ kubectl delete pvc local-pvc
persistentvolumeclaim "local-pvc" deleted

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                               STORAGECLASS        VOLUMEATTRIBUTESCLASS   REASON   AGE
local-pv                                   1Gi        RWX            Retain           Released   default/local-pvc                   manual              <unset>                          3m57s
pvc-c01de902-abfa-4314-9525-9b37461e8328   20Gi       RWX            Delete           Bound      container-registry/registry-claim   microk8s-hostpath   <unset>                          8h
```

Это происходит из-за того, что жизненный цикл PV не контролируется автоматически. Когда PVC, использовавший этот PV, удаляется, PV переходит в состояние **Released** и становится доступным для другого PVC. Однако данные на диске сохраняются из-за политики **Retain** и остаются неизменными, пока администратор не очистит или не удалит PV вручную.

5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.

```bash
$ cat /mnt/data/sharedfile.txt
Tue Nov 26 16:36:37 UTC 2024
Tue Nov 26 16:36:42 UTC 2024
Tue Nov 26 16:36:47 UTC 2024
Tue Nov 26 16:36:52 UTC 2024
Tue Nov 26 16:36:57 UTC 2024
Tue Nov 26 16:37:02 UTC 2024
Tue Nov 26 16:37:07 UTC 2024
Tue Nov 26 16:37:12 UTC 2024
Tue Nov 26 16:37:17 UTC 2024
Tue Nov 26 16:37:22 UTC 2024
Tue Nov 26 16:37:27 UTC 2024
Tue Nov 26 16:37:32 UTC 2024
Tue Nov 26 16:37:37 UTC 2024
Tue Nov 26 16:37:42 UTC 2024
Tue Nov 26 16:37:47 UTC 2024
Tue Nov 26 16:37:52 UTC 2024
Tue Nov 26 16:37:57 UTC 2024
Tue Nov 26 16:38:02 UTC 2024
Tue Nov 26 16:38:07 UTC 2024
Tue Nov 26 16:38:12 UTC 2024
Tue Nov 26 16:38:17 UTC 2024
Tue Nov 26 16:38:22 UTC 2024
Tue Nov 26 16:38:27 UTC 2024
Tue Nov 26 16:38:32 UTC 2024
Tue Nov 26 16:38:37 UTC 2024
Tue Nov 26 16:38:42 UTC 2024

$ kubectl delete pv local-pv
persistentvolume "local-pv" deleted

$ ls /mnt/data/sharedfile.txt
/mnt/data/sharedfile.txt
```

После удаления PV файл `sharedfile.txt` все еще присутствует в каталоге `/mnt/data` на ноде. Это происходит потому, что `hostPath` обращается непосредственно к файловой системе ноды, и удаление PV не влияет на данные, хранящиеся в `hostPath`. PV выступает лишь как абстракция, представляющая реальное хранилище, которым в данном случае является `hostPath`.

5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.

```bash
$ sudo apt install -y nfs-kernel-server

$ sudo mkdir -p /srv/nfs/kubedata
sudo chown nobody:nogroup /srv/nfs/kubedata
sudo chmod 777 /srv/nfs/kubedata

$ echo "/srv/nfs/kubedata *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
/srv/nfs/kubedata *(rw,sync,no_subtree_check,no_root_squash)

$ sudo exportfs -a
sudo systemctl restart nfs-kernel-server

$ kubectl create namespace nfs-provisioner
namespace/nfs-provisioner created

$ kubectl get namespaces
NAME                 STATUS   AGE
container-registry   Active   8h
default              Active   8h
istio-system         Active   8h
kube-node-lease      Active   8h
kube-public          Active   8h
kube-system          Active   8h
nfs-provisioner      Active   21s

$ kubectl apply -f nfs-provisioner-configmap.yaml
configmap/nfs-client-provisioner created

$ kubectl apply -f nfs-provisioner-rbac.yaml
serviceaccount/nfs-client-provisioner created
clusterrole.rbac.authorization.k8s.io/nfs-client-provisioner-runner created
clusterrolebinding.rbac.authorization.k8s.io/run-nfs-client-provisioner created

$ kubectl apply -f nfs-provisioner-deployment.yaml
deployment.apps/nfs-client-provisioner created

$ kubectl apply -f nfs-provisioner-storageclass.yaml
storageclass.storage.k8s.io/nfs-client created

$ kubectl get pods -n nfs-provisioner
NAME                                      READY   STATUS    RESTARTS   AGE
nfs-client-provisioner-7c6cdbfd54-mwt8k   1/1     Running   0          41s
```

2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.

```bash
$ kubectl apply -f nfs-pvc.yaml
persistentvolumeclaim/nfs-pvc created

$ kubectl get pvc
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
nfs-pvc   Bound    pvc-f09d9d0a-0c85-4ab5-834b-8125fea3b1c6   1Gi        RWX            nfs-client     <unset>                 17s

$ kubectl apply -f multitool-deployment.yaml
deployment.apps/multitool-nfs created

$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
multitool-nfs-79c4d49776-gbbxr   1/1     Running   0          60s
```

3. Продемонстрировать возможность чтения и записи файла изнутри пода. 

```bash
$ kubectl exec -it multitool-nfs-79c4d49776-gbbxr -- sh
/ # cd /data/
/data # echo "Netology. It's NFS Storage Test!" > testfile.txt
/data # cat testfile.txt
Netology. It's NFS Storage Test!
/data # exit

$ ls /srv/nfs/kubedata
default-nfs-pvc-pvc-f09d9d0a-0c85-4ab5-834b-8125fea3b1c6

$ cat /srv/nfs/kubedata/default-nfs-pvc-pvc-f09d9d0a-0c85-4ab5-834b-8125fea3b1c6/testfile.txt
Netology. It's NFS Storage Test!
```

4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.
