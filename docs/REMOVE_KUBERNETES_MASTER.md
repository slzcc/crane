# REMOVE KUBERNETES MASTER

清除的是 Kubernetes Master 节点, 清除 Master 后还会保留 Node 节点特性。

## Configure

在 `nodes` 文件中, 只需要保证 k8s-cluster-del-master 中的 实例 是 `kube-master` 中需要剔除的 实例 IP 即可:

```
[kube-master]
35.200.23.39
#35.243.107.98
...

[kube-node]
...

[k8s-cluster-del-master]
35.243.107.98
```

> 删除的 Master IP 地址一定要在 `kube-master` 配置中移除, 否则更新 Kube-ApiServer 配置文件时会出现脏配置。

## 执行

上述配置准备好后准备执行命令:

```
$ make remove_k8s_nodes
```

## 恢复

此操作不可逆, 不可恢复。