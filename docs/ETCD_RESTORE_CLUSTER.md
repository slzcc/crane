# ETCD RESTORE CLUSTER

主要作用部署一个全新的 Etcd Cluster, 并通过 snapshot 文件恢复成一个新的有数据的 Etcd Cluster。

# 重要提示

> 此内容一定要关心, 否则可能影响集群正常运行.

> 1、手动或自动切换 apiServer 的后端 Etcd 时, 一定要重启 kubelet、calico(calico 原则上需要重新部署, 因 Etcd 证书进行了变更) 否则会影响整个 node 节点的存活以及 容器 运行无网络的问题。

> 2、calico 如果重新部署一定要对 `CALICO_IPV4POOL_CIDR` 的值设置正确, 否则会报错:

```
2021-06-03 10:39:16.890 [INFO][1] main.go 92: Loaded configuration from environment config=&config.Config{LogLevel:"info", WorkloadEndpointWorkers:1, ProfileWorkers:1, PolicyWorkers:1, NodeWorkers:1, Kubeconfig:"", DatastoreType:"kubernetes"}
W0603 10:39:16.891876       1 client_config.go:552] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
2021-06-03 10:39:16.892 [INFO][1] main.go 113: Ensuring Calico datastore is initialized
2021-06-03 10:39:26.892 [ERROR][1] client.go 261: Error getting cluster information config ClusterInformation="default" error=Get "https://10.32.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default": context deadline exceeded
2021-06-03 10:39:26.892 [FATAL][1] main.go 118: Failed to initialize Calico datastore error=Get "https://10.32.0.1:443/apis/crd.projectcalico.org/v1/clusterinformations/default": context deadline exceeded

```

## Configure

在 `nodes` 文件中, 主要操作 `[etcd-new-cluster]` 和 `[etcd]` 列表:

```
[etcd-new-cluster]
192.168.122.76
...

```

列表中不要有 Etcd 实例或者数据目录, 避免引起不必要的操作, 可以执行 `remove_etcd_cluster.yml` 初始化后继续执行。

> CA 证书是通过 etcd[0] 节点复制过来的, 不会重新生成, 如果重新生成则会引起不必要的服务异常。

> 如果要新建 CA 则修改 `roles/etcd-cluster-management/defaults/etcd-new-cluster.yaml` 中 `ca_new` 为 `true` 即可。新建 CA 需要手动更新 Network 等需要连接 Etcd 的配置项。

## 执行

上述配置准备好后准备执行命令:

```
$ make run_etcd_restore
```

## 检测

检车 etcd 列表时, 会发现多出的 etcd cluster 服务:

```
kube-system   etcd-master01.local                       1/1     Running   0          18h   192.168.122.86    master01.local   <none>           <none>
kube-system   etcd-master02.local                       1/1     Running   1          19h   192.168.122.120   master02.local   <none>           <none>
kube-system   etcd-master03.local                       1/1     Running   1          19h   192.168.122.108   master03.local   <none>           <none>
kube-system   etcd-master04.local                       1/1     Running   0           1h   192.168.122.76    master04.local   <none>           <none>
kube-system   etcd-master05.local                       1/1     Running   0           1h   192.168.122.19    master05.local   <none>           <none>
kube-system   etcd-master06.local                       1/1     Running   0           1h   192.168.122.220   master06.local   <none>           <none>
...
```