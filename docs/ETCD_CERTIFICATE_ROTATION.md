# ETCD CERTIFICATE ROTATION

Etcd 集群证书轮转.

> Etcd 证书轮转会造成整个集群在 1 分钟内, Kube-ApiServer 无法正常读写的问题。所以在更新时不要进行任何写的操作, 避免可能造成的请求丢失。

## Configure

配置围绕着 `nodes` 其他配置都不用操作。

> 如果修改修改 Etcd CA 证书时间请修改 `@crane/roles/etcd-install/defaults/tls.yaml` 默认 20 年.

在 `nodes` 文件中, 只需要保证 etcd 参数项内列表是对应的 etcd 节点即可:(外网地址可被解析成内网地址)

```
[kube-master]
35.200.23.39
...

[etcd]
35.200.23.39
35.243.107.98
34.85.14.128
```

同时在操作 etcd 节点的情况下会借用一台 master 节点更新 kubernetes 集群中的配置项.

## 执行

上述配置准备好后准备执行命令:

```
$ make rotation_etcd_ca
```

## 检测

可通过如下命令检测当前 etcd 节点状况:

```
$ /usr/local/bin/docker run --rm -i -v /etc/kubernetes/pki/etcd/:/etc/kubernetes/pki/etcd/ -w /etc/kubernetes/pki/etcd/ k8s.gcr.io/etcd:3.4.9 etcdctl --cacert /etc/kubernetes/pki/etcd/etcd-ca.pem --key /etc/kubernetes/pki/etcd/etcd-key.pem --cert /etc/kubernetes/pki/etcd/etcd.pem --endpoints https://10.146.0.10:2379,https://10.146.0.13:2379 member list
```

## 恢复

更新证书时会把旧的证书放置 `etcd[0]` 的 `/tmp/crane/etcd-ca-rotation` 中, 以时间戳后缀命名。

把当前的 certs 恢复至所有 etcd 节点的 `/etc/kubernetes/pki/etcd` 目录中, 并重启 etcd 后, 重启 Kube-ApiServer 和 Calico 生效。

Kube-ApiServer 重启执行命令即可:

```
# docker
$ docker rm -f $(docker ps --filter name=POD_kube-apiserver -q) ; sleep 2

# containerd
$ for i in $(crictl ps --name kube-apiserver -aq); do crictl rm -f ${i}; sleep 2 ; done
```

Calico 重启执行如下命令:

```
$ kubectl delete secret calico-etcd-secrets -n kube-system

$ kubectl create secret generic calico-etcd-secrets -n kube-system \
                --from-literal=etcd-ca={{ etcd_ssl_dirs }}etcd-ca.pem \
                --from-literal=etcd-cert={{ etcd_ssl_dirs }}etcd.pem
                --from-literal=etcd-key={{ etcd_ssl_dirs }}etcd-key.pem

$ kubectl delete -f /tmp/crane/etcd-ca-rotation/etcd-ca-rotation/calico.yml

$ kubectl apply -f /tmp/crane/etcd-ca-rotation/etcd-ca-rotation/calico.yml
```