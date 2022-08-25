# ADD ETCD

> 执行操作时, 必须保证宿主机拥有 docker, 否则无法正常运行。

添加一个新的 Etcd 节点.

> 必须保证新添加的节点存在 docker, 因为加入节点的命令是通过 docker 执行的.

> 新添加的节点需要已经存在 Kubernetes 集群中否则无法启动成功。

## Configure

在 `nodes` 文件中, 只需要保证 etcd-cluster-add-node 中 示例 已经在 Kubernetes 节点中（kube-node 或 kube-master 无所谓）: 

```
[kube-master]
35.200.23.39
...

[kube-node]
35.243.107.98
...

[etcd]
35.200.23.39
...

[etcd-cluster-add-node]
35.243.107.98
```

同时在操作 etcd 节点的情况下会借用一台 master 节点更新 kubernetes 集群中的配置项.

## 执行

上述配置准备好后准备执行命令:

```
$ make run_add_etcd
```

## 检测

可通过如下命令检测当前 etcd 节点状况:

```
$ /usr/local/bin/docker run --rm -i -v /etc/kubernetes/pki/etcd/:/etc/kubernetes/pki/etcd/ -w /etc/kubernetes/pki/etcd/ k8s.gcr.io/etcd:3.4.9 etcdctl --cacert /etc/kubernetes/pki/etcd/etcd-ca.pem --key /etc/kubernetes/pki/etcd/etcd-key.pem --cert /etc/kubernetes/pki/etcd/etcd.pem --endpoints https://10.146.0.10:2379,https://10.146.0.13:2379 member list
```

## 恢复

更新证书时会把旧的证书放置 `etcd[0]` 的 `/tmp/crane/etcd-add-node` 中, 以时间戳后缀命名。

把当前的 certs 恢复至所有 etcd 节点的 `/etc/kubernetes/pki/etcd` 目录中, 并重启 etcd 后, 执行删除新节点的命令:

```
$ docker run --rm -i -v /etc/kubernetes/pki/etcd/:/etc/kubernetes/pki/etcd/ -w /etc/kubernetes/pki/etcd/ {{ k8s_cluster_component_registry }}/etcd:3.4.9 etcdctl --cacert /etc/kubernetes/pki/etcd/etcd-ca.pem --key /etc/kubernetes/pki/etcd/etcd-key.pem --cert /etc/kubernetes/pki/etcd/etcd.pem --endpoints https://127.0.0.1:2379 member remove <clean_ip>
```

Kube-ApiServer 重启执行命令即可:

```
# docker
$ docker rm -f $(docker ps --filter name=POD_kube-apiserver -q) ; sleep 2

# containerd
$ for i in $(crictl ps --name kube-apiserver -aq); do crictl rm -f ${i}; sleep 2 ; done
```

Calico 重启执行如下命令:

```
$ kubectl rollout restart deployment/calico-kube-controllers -n kube-system

$ kubectl rollout restart daemonset/calico-node -n kube-system
```