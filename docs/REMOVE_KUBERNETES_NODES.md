# REMOVE KUBERNETES NODES

清除的是 Kubernetes Nodes 节点, 并不是 Master 节点。

## Configure

在 `nodes` 文件中, 只需要保证 k8s-cluster-del-node 中的 实例 是 `kube-node` 中需要剔除的 实例 IP 即可:

```
[kube-master]
35.200.23.39
...

[kube-node]
35.200.23.39
#35.243.107.98
...

[k8s-cluster-del-node]
35.243.107.98
```
> 删除的 Node IP 地址一定要在 `kube-node` 配置中移除, 如果不设置不影响正常使用。

## 执行

上述配置准备好后准备执行命令:

```
$ make remove_k8s_master
```

## 恢复

此操作不可逆, 不可恢复。