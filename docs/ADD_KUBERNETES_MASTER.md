# ADD KUBERNETES MASTER

> 执行 Add Master 时首先保证此节点已经在集群内, 因此操作是通过 node 升级为 master 不是直接从头部署.

添加一个 Master 节点属于从新添加一个节点并启动 Master 服务的过程, 只需要在 `nodes` 中添加示例 IP 即可:

```
[k8s-cluster-add-master]
1.2.3.4
...
```

并执行:

```
$ make run_add_master
```