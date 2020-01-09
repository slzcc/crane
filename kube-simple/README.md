# Kube Simple

为了方便测试, 准备 Simple 方式测试部署 Crane .

通过启动一个容器模拟 虚拟机/物理机 部署单点的 Kubernetes Master 实例.

# 环境准备

启动 Simple 容器实例:

```
$ docker run -d --name kube-simple -p 1220:22 -p 2379:2379 -p 2380:2380 -p 5443:5443 -p 6443:6443 -p 9090:9090 -p 10256:10256 -p 10257:10257 -p 10259:10259 --privileged slzcc/ubuntu:18.04-systemd
```

获取容器的 SSH 秘钥:

```
$ docker cp kube-simple:/root/.ssh/id_rsa ~/.ssh/kube-simple
$ docker cp kube-simple:/root/.ssh/id_rsa.pub ~/.ssh/kube-simple.pub
```

测试连接:

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