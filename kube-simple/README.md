# Kube Simple

为了方便测试, 准备 Simple 方式测试部署 Crane . 如在 MacOS 等系统中可以直接进行部署。只需要安装 Docker for Mac 且不依赖其他环境即可进行部署。

> kube Simple 镜像中包含 System Kernel Module, 请自行编译安装 Kernel 所需模块。
> 因为是模拟内核驱动, 所以绝大部分的模块是无法加载的, 会造成 Kube-Proxy 等服务无法正常启动, 所以如此问题请忽略。

通过启动一个容器模拟 虚拟机/物理机 部署单点或集群的 Kubernetes Cluster 实例.

# 环境准备

启动 Simple 容器实例:

```
$ docker network create --subnet 172.20.0.0/24 kube-simple

$ docker run -d --net kube-simple --name kube-simple -p 22:22 -p 2379:2379 -p 2380:2380 -p 5443:5443 -p 6443:6443 -p 9090:9090 -p 10256:10256 -p 10257:10257 -p 10259:10259 --privileged --cap-add=ALL --memory 4G --memory-swap 0 slzcc/ubuntu:18.04-linuxkit-4.9.184
```

获取容器的 SSH 秘钥:

```
$ docker cp kube-simple:/root/.ssh/id_rsa ~/.ssh/kube-simple

$ docker cp kube-simple:/root/.ssh/id_rsa.pub ~/.ssh/kube-simple.pub
```

修改 group_vars/all.yml 中的 k8s_load_balance_ip 为容器内的 IP 地址, 通过如下命令获取:

```
$ docker inspect kube-simple --format '{{ .NetworkSettings.IPAddress }}'
172.20.0.2

# or
$ docker exec -it kube-simple ifconfig eth0 | grep "inet" | awk '{print $2}'

```

测试连接:（如果是本机则填写回环地址，如果非本机则填写远程机器地址）

```
$ docker run --name crane-test --net kube-simple --rm -it -v ~/.ssh:/root/.ssh slzcc/ubuntu:18.04-linuxkit-4.9.184 bash

$ ssh -p 22 -i ~/.ssh/kube-simple root@172.20.0.2

# or
$ ssh-keyscan -t rsa -p 22 172.20.0.2  >> ~/.ssh/known_hosts

```

> 如发现类似问题:
```
$ ssh -p 22 -i ~/.ssh/kube-simple root@172.20.0.2
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:zYcKdEqIF7nH/R/YJVxjpMmIHFlCAVaR8UuKQIhKqwo.
Please contact your system administrator.
Add correct host key in /Users/shilei/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /Users/shilei/.ssh/known_hosts:65
ECDSA host key for [172.20.0.2]:22 has changed and you have requested strict checking.
Host key verification failed.
```

> 请自行解决.

可以正常启动后，修改 nodes 对应的地址信息。（如果是本机则填写回环地址，如果非本机则填写远程机器地址）

```
[kube-master]
172.20.0.2

[kube-node]

[etcd]
172.20.0.2

[k8s-cluster-add-master]


[k8s-cluster-add-node]


[etcd-cluster-add-node]


[k8s-cluster:children]
kube-node
kube-master

[etcd-cluster:children]
etcd
etcd-cluster-add-node

[all:vars]
ansible_ssh_public_key_file='~/.ssh/kube-simple.pub'
ansible_ssh_private_key_file='~/.ssh/kube-simple'
ansible_ssh_port=22
ansible_ssh_user=root
```


然后执行部署命令:

```
$ make run_simple

```

部署完成后查看集群信息:

```
$ kubectl exec -it kube-simple bash
 
$ kubectl get csr
NAME        AGE     REQUESTOR                  CONDITION
csr-5lv28   9m37s   system:node:7ffa79cdabb0   Approved,Issued

$ kubectl get nodes
NAME           STATUS   ROLES    AGE   VERSION
7ffa79cdabb0   Ready    master   10m   v1.17.1

$ kubectl get cs
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true"}

$ kubectl get pod --all-namespaces -o wide
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE     IP              NODE           NOMINATED NODE   READINESS GATES
kube-system   calico-node-2cv6j                      1/1     Running   4          10m     172.20.0.2      7ffa79cdabb0   <none>           <none>
kube-system   coredns-67dcdb578f-67gzw               1/1     Running   0          10m     192.167.145.2   7ffa79cdabb0   <none>           <none>
kube-system   coredns-67dcdb578f-jqdkf               1/1     Running   0          10m     192.167.145.1   7ffa79cdabb0   <none>           <none>
kube-system   etcd-7ffa79cdabb0                      1/1     Running   0          10m     172.20.0.2      7ffa79cdabb0   <none>           <none>
kube-system   haproxy-7ffa79cdabb0                   1/1     Running   0          9m39s   172.20.0.2      7ffa79cdabb0   <none>           <none>
kube-system   kube-apiserver-7ffa79cdabb0            1/1     Running   0          9m39s   172.20.0.2      7ffa79cdabb0   <none>           <none>
kube-system   kube-controller-manager-7ffa79cdabb0   1/1     Running   0          10m     172.20.0.2      7ffa79cdabb0   <none>           <none>
kube-system   kube-proxy-sqscs                       1/1     Running   0          10m     172.20.0.2      7ffa79cdabb0   <none>           <none>
kube-system   kube-scheduler-7ffa79cdabb0            1/1     Running   0          9m49s   172.20.0.2      7ffa79cdabb0   <none>           <none>
```

# 销毁

部署完成后通过如下方式销毁数据:

```
$ docker rm -f kube-simple

$ rm -rf ~/.ssh/kube-simple*

$ docker network rm kube-simple
```

# 问题总汇

当 kube-proxy 无法启动时, 提示如下问题:

```
docker logs -f 1b3fc67995b4
W0116 17:12:06.788369       1 server.go:427] using lenient decoding as strict decoding failed: strict decoder error for apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /var/lib/kube-proxy/kubeconfig.conf
  qps: 5
clusterCIDR: ""
configSyncPeriod: 15m0s
conntrack:
  max: 0
  tcpCloseWaitTimeout: 1h0m0s
  tcpEstablishedTimeout: 24h0m0s
enableProfiling: false
healthzBindAddress: 0.0.0.0:10256
hostnameOverride: ""
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  excludeCIDRs: null
  minSyncPeriod: 0s
  scheduler: "rr"
  strictARP: false
  syncPeriod: 30s
kind: KubeProxyConfiguration
metricsBindAddress: 127.0.0.1:10249
mode: "ipvs"
nodePortAddresses:
  - "10.100.21.0/24"
  - "172.17.48.0/24"
oomScoreAdj: -999
portRange: ""
resourceContainer: /kube-proxy
udpIdleTimeout: 250ms
winkernel:
  enableDSR: false
  networkName: ""
  sourceVip: "": v1alpha1.KubeProxyConfiguration.Conntrack: v1alpha1.KubeProxyConntrackConfiguration.ReadObject: found unknown field: max, error found in #10 byte of ...|ck":{"max":0,"tcpClo|..., bigger context ...|":"","configSyncPeriod":"15m0s","conntrack":{"max":0,"tcpCloseWaitTimeout":"1h0m0s","tcpEstablishedT|...
I0116 17:12:07.265455       1 node.go:135] Successfully retrieved node IP: 172.20.0.2
I0116 17:12:07.266046       1 server_others.go:172] Using ipvs Proxier.
W0116 17:12:07.347586       1 proxier.go:414] clusterCIDR not specified, unable to distinguish between internal and external traffic
I0116 17:12:07.363075       1 server.go:571] Version: v1.17.1
I0116 17:12:07.363616       1 conntrack.go:52] Setting nf_conntrack_max to 131072
I0116 17:12:07.364081       1 conntrack.go:83] Setting conntrack hashsize to 32768
F0116 17:12:07.364145       1 server.go:485] write /sys/module/nf_conntrack/parameters/hashsize: operation not supported
```

请查看如下参数值:

```
$ cat /sys/module/nf_conntrack/parameters/hashsize
16384
```

修改 kube-proxy 配置文件修改如下内容:

```
$ kubectl edit configmap -n kube-system kube-proxy
...
      max: null
      min: 16384
...
```

修改完成后解决此问题.