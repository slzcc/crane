# REMOVE ETCD NODES

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