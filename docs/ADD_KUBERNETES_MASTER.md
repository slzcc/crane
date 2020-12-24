# ADD KUBERNETES MASTER

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