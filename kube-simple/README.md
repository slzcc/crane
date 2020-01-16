# Kube Simple

为了方便测试, 准备 Simple 方式测试部署 Crane . 如在 MacOS 等系统中可以直接进行部署。只需要安装 Docker for Mac 且不依赖其他环境即可进行部署。

> kube Simple 镜像中包含 System Kernel Module, 请自行编译安装 Kernel 所需模块。
> 因为是模拟内核驱动, 所以绝大部分的模块是无法加载的, 会造成 Kube-Proxy 等服务无法正常启动, 所以如此问题请忽略。

通过启动一个容器模拟 虚拟机/物理机 部署单点或集群的 Kubernetes Cluster 实例.

# 环境准备

启动 Simple 容器实例:

```
$ docker network create kube-simple

$ docker run -d --name kube-simple -p 22:22 -p 2379:2379 -p 2380:2380 -p 5443:5443 -p 6443:6443 -p 9090:9090 -p 10256:10256 -p 10257:10257 -p 10259:10259 --privileged --cap-add=ALL --memory 4G --memory-swap 0 slzcc/ubuntu:18.04-systemd-kernel
```

获取容器的 SSH 秘钥:

```
$ docker cp kube-simple:/root/.ssh/id_rsa ~/.ssh/kube-simple

$ docker cp kube-simple:/root/.ssh/id_rsa.pub ~/.ssh/kube-simple.pub
```

修改 group_vars/all.yml 中的 k8s_load_balance_ip 为容器内的 IP 地址, 通过如下命令获取:

```
$ docker inspect kube-simple --format '{{ .NetworkSettings.IPAddress }}'
172.19.0.2

```

测试连接:（如果是本机则填写回环地址，如果非本机则填写远程机器地址）

```
$ docker run --name crane-test --net kube-simple --rm -it -v ~/.ssh:/root/.ssh ubuntu:18.04-systemd-kernel bash

$ ssh -p 22 -i ~/.ssh/kube-simple root@172.19.0.2

# or
$ ssh-keyscan -t rsa -p 22 172.19.0.2  >> ~/.ssh/known_hosts

```

> 如发现类似问题:
```
$ ssh -p 22 -i ~/.ssh/kube-simple root@172.19.0.2
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
ECDSA host key for [172.19.0.2]:22 has changed and you have requested strict checking.
Host key verification failed.
```

> 请自行解决.

可以正常启动后，修改 nodes 对应的地址信息。（如果是本机则填写回环地址，如果非本机则填写远程机器地址）

```
[kube-master]
172.19.0.2

[kube-node]

[etcd]
172.19.0.2

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

# 销毁

部署完成后通过如下方式销毁数据:

```
$ docker rm -f kube-simple

$ rm -rf ~/.ssh/kube-simple*

$ docker network rm kube-simple
```