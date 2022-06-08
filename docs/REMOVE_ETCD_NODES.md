# REMOVE ETCD NODES

> 执行操作时, 必须保证宿主机拥有 docker, 否则无法正常运行。

清除 Etcd 节点会重启 Kube-ApiServer 和 Calico 则会造成集群短暂不可用, 请在使用频率较低的时间段内进行。

> 必须保证新添加的节点存在 docker, 因为加入节点的命令是通过 docker 执行的.

## Configure

在 `nodes` 文件中, 只需要保证 etcd-cluster-del-node 中的 实例 是 `etcd` 中需要剔除的 实例 IP 即可:

```
[kube-master]
35.200.23.39
...

[etcd]
35.200.23.39
#35.243.107.98
...

[etcd-cluster-del-node]
35.243.107.98
```

> 删除的 node 一定要在 etcd 配置中移除, 否则更新 etcd 配置文件时会出现脏配置。

## 执行

上述配置准备好后准备执行命令:

```
$ make remove_etcd_nodes
```

## 恢复

此操作不可逆, 不可恢复。


## 问题

目前如下状态的 node 无法正常删除:

```
$ /usr/local/bin/docker run --rm -i -v /etc/kubernetes/pki/etcd/:/etc/kubernetes/pki/etcd/ -w /etc/kubernetes/pki/etcd/ k8s.gcr.io/etcd:3.4.9 etcdctl --cacert /etc/kubernetes/pki/etcd/etcd-ca.pem --key /etc/kubernetes/pki/etcd/etcd-key.pem --cert /etc/kubernetes/pki/etcd/etcd.pem --endpoints https://10.146.0.10:2379,https://10.146.0.12:2379 member list
35507ce955c2e3b2, unstarted, , https://10.146.0.13:2380, , false
452a756c0ce3c1b0, started, instance-1, https://10.146.0.10:2380, https://10.146.0.10:2379, false
5d80ed6e5a218aae, started, instance-3, https://10.146.0.12:2380, https://10.146.0.12:2379, false
```

请自行通过命令解决,或执行如下命令:

```
$ /usr/local/bin/docker run --rm -i -v /etc/kubernetes/pki/etcd/:/etc/kubernetes/pki/etcd/ -w /etc/kubernetes/pki/etcd/ k8s.gcr.io/etcd:3.4.9 etcdctl --cacert /etc/kubernetes/pki/etcd/etcd-ca.pem --key /etc/kubernetes/pki/etcd/etcd-key.pem --cert /etc/kubernetes/pki/etcd/etcd.pem --endpoints https://10.146.0.10:2379,https://10.146.0.12:2379 member remove 35507ce955c2e3b2
```