# KUBERNETES CERTIFICATE ROTATION

Kubernetes 集群证书轮转.

> Kubernetes 证书轮转会造成整个集群在 1 分钟内, Kube-ApiServer 无法正常读写的问题。所以在更新时不要进行任何写的操作, 避免可能造成的请求丢失。

## Configure

配置围绕着 `nodes` 其他配置都不用操作。

> 如果修改修改 Etcd CA 证书时间请修改 `@crane/roles/kubernetes-default/defaults/tls.yaml` 默认 20 年.

在 `nodes` 文件中, 只需要保证 kube-master/node 参数项内列表是对应的 etcd 节点即可:(外网地址可被解析成内网地址)

```
[kube-master]
35.200.23.39
...

[kube-node]
35.243.107.98
...
```

## 执行

上述配置准备好后准备执行命令:

```
$ make rotation_k8s_ca
```

## 恢复

会把旧的配置放置 `kube-master[0]` 的 `/tmp/crane/kubernetes-ca-rotation/kubernetes-etc.x` 中, 以时间戳后缀命名。

#### node 节点需要执行:

1、删除 `/var/lib/kubelet/pki/{kubelet-client-current.pem,kubelet.crt,kubelet.key}`

2、把当前的 kubernetes-etc.x 恢复至 /etc/kubernetes 后重启 kubelet.

#### master 节点需要执行:

重启服务

```
# Docker
$ docker rm -f $(docker ps --filter name=k8s_kube-apiserver -q)"

$ docker rm -f $(docker ps --filter name=k8s_kube-controller-manager -q)"

$ docker rm -f $(docker ps --filter name=k8s_kube-scheduler -q)"


# Containerd
$ for i in $(crictl ps | egrep '(kube-scheduler|kube-apiserver|kube-controller-manager)'|awk '{print $1}'); do crictl rm -f $i;done

```