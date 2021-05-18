# MIGRATION K8S TO NEW ETCD CLUSTER

对当前 Master 节点连接的 Etcd 集群节点, 改成新的 Etcd 集群节点。

## Configure

配置围绕着 `nodes` 其他配置都不用操作。


在 `nodes` 文件中, 只需要保证 `kube-master` 和 `etcd-new-cluster` 的配置完整性, 它是把 master 上 apiServer 指向的 etcd 配置改为 `etcd-new-cluster` 的配置地址:

```
[kube-master]
35.200.23.39
...

[etcd-new-cluster]
35.243.107.98
...
```

## 执行

上述配置准备好后准备执行命令:

```
$ make run_migration_k8s_etcd
```

## 检测

登入 Master 后查看 `/etc/kubernetes/manifests/kube-apiserver.yml` 是否是正常值, 并且通过 kubectl 执行命令查看是否正确即可。