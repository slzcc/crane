# ADD KUBERNETES NODES

添加一个 Node 节点属于从新添加一个节点, 只需要在 `nodes` 中添加示例 IP 即可:

```
[k8s-cluster-add-node]
1.2.3.4
...
```

并执行:

```
$ make run_add_nodes
```