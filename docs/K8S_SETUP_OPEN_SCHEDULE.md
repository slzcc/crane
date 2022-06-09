# K8S SETUP OPEN SCHEDULE

打开整个集群所有 node 节点的调度, 执行命令效果:

```
$ kubelet uncordon instance-2 ...
```

> 它的作用是保证集群如变更 `K8s 集群证书`、`Etcd 集群证书`、`升级集群版本` 时需要先停止集群整个的调度避免出现错误导致的集群不可用。

如需执行，命令如下:

```
$ make run_open_schedule
```