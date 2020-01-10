# Kube Simple

为了方便测试, 准备 Simple 方式测试部署 Crane .

通过启动一个容器模拟 虚拟机/物理机 部署单点的 Kubernetes Master 实例.

# 环境准备

启动 Simple 容器实例:

```
$ docker run -d --name kube-simple -p 1220:22 -p 2379:2379 -p 2380:2380 -p 5443:5443 -p 6443:6443 -p 9090:9090 -p 10256:10256 -p 10257:10257 -p 10259:10259 --privileged --cap-add=ALL slzcc/ubuntu:18.04-systemd
```

获取容器的 SSH 秘钥:

```
$ docker cp kube-simple:/root/.ssh/id_rsa ~/.ssh/kube-simple
$ docker cp kube-simple:/root/.ssh/id_rsa.pub ~/.ssh/kube-simple.pub
```

测试连接:（如果是本机则填写回环地址，如果非本机则填写远程机器地址）

```
$ ssh -p 1220 -i ~/.ssh/kube-simple root@127.0.0.1
```

> 如发现类似问题:
```
$ ssh -p 1220 -i ~/.ssh/kube-simple root@127.0.0.1
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
ECDSA host key for [127.0.0.1]:1220 has changed and you have requested strict checking.
Host key verification failed.
```

> 请自行解决.

可以正常启动后，修改 nodes 对应的地址信息。（如果是本机则填写回环地址，如果非本机则填写远程机器地址）

```
[kube-master]
127.0.0.1

[kube-node]

[etcd]
127.0.0.1

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
ansible_ssh_public_key_file='~/.ssh/simple.pub'
ansible_ssh_private_key_file='~/.ssh/simple'
ansible_ssh_port=1220
ansible_ssh_user=root
```

修改 group_vars/all.yml 中的 k8s_load_balance_ip 为容器内的 IP 地址, 通过如下命令获取:

```
$ docker inspect kube-simple --format '{{ .NetworkSettings.IPAddress }}'

```

然后执行部署命令:

```
$ docker inspect kube-simple --format '{{ .NetworkSettings.IPAddress }}'

```