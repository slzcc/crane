## 获取对应的版本

切记, 如需要安装哪个大版本的集群, 就获取相应的 tag :

```
$ git clone -b v1.18.x.x https://github.com/slzcc/crane.git
```

> v1.15.x.x 最末尾一位属于编写 Ansible 脚本的迭代版本, 不属于 Kubernetes 自身版本。

## Docker 安装

默认会检测是否有 Docker 可执行文件, 如果没有则可以通过三种方式安装 Docker, 参见 [Docker install](../crane/roles/docker-install)

安装 Docker 时会添加 `daemon.json` 配置, 如果不需要可设置 `is_docker_daemon_config` 进行关闭。

> Docker 19.03 中默认支持 GPU 驱动不需要额外添加，[Nvidia-Docker](https://github.com/NVIDIA/nvidia-docker#quickstart)

> 以下所有的部署全部使用 Ubuntu 16.04 为环境进行示例演练。个人部署时请使用最新版进行尝试。

## 使用说明

在 nodes 文件中, 分为三大块:

```
[kube-master]
35.236.167.32

[kube-node]
34.80.142.147

[etcd]
35.236.167.32

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
ansible_ssh_public_key_file='/Users/shilei/.ssh/id_rsa.pub'
ansible_ssh_private_key_file='/Users/shilei/.ssh/id_rsa'
```
第一部分为部署集群所规划的集群初始节点, 可自定义添加。(第一次创建集群时, 不能在添加 master/node/etcd 中写入节点地址, 否则会冲突)

第二部分为后续集群需要添加的节点可分为 master/node/etcd 。

第三部分为集群内所有节点均可使用的 SSH 秘钥。

在初次部署时, 应先修改基础配置文件 group_vars/all.yml 文件, 下面列出初始部署时应修改的选项：
```
# apiServer 的入口, 也就是 apiServer 的负载均衡层, 可支持 lvs/keepalived 组合, 如第一次部署请不要开启 lvs/keepalived , 如公有云环境也不支持 lvs/keepalived 。
k8s_load_balance_ip: < SLB 或 某节点 IP >

# Ansible 使用的远程服务器用户, 可使用普通用户但必须属于 Sudo 组
ssh_connect_user: < SSH USER >

# 所有节点统一的网卡名称, 否则会出现环境不一致的问题, 此配置被 Etcd/LVS 服务依赖。
os_network_device_name: < NetWork Name >
```

> 如有不明确的问题, 请参照上方的 Wiki 链接, 如果还有问题请提交 issue。

> 普通用户需要具有 Sudo 组, 并且配置 Sudo 免密。

## Deploy Kubernetes Cluster

如上述修改完成后, 可执行命令（v1.18.5.0 部署版本为例）：

```
$ docker run --name crane --rm -i \
         -e ANSIBLE_HOST_KEY_CHECKING=false \
         -e TERM=xterm-256color \
         -e COLUMNS=238 \
         -e LINES=61 \
         -v ~/.ssh:/root/.ssh \
         -v ${PWD}:/crane \
         slzcc/crane:v1.18.5.0 \
         -i nodes main.yml -vv
```
Cluster Status
```
$ kubectl get csr
NAME                                                   AGE       REQUESTOR                 CONDITION
csr-5hl64                                              11m       system:node:instance-3    Approved,Issued
csr-758h6                                              11m       system:node:instance-4    Approved,Issued
csr-fdf9g                                              11m       system:node:instance-2    Approved,Issued
node-csr-4PjnAlcpExzHYlotBexV1yaev40khyc3RjIlWj-JFMU   10m       system:bootstrap:b53294   Approved,Issued
node-csr-9qRs7kA959MOtQHx-5XXuMvmwl3vT6M1QkmmzUgvteQ   10m       system:bootstrap:b53294   Approved,Issued
node-csr-GJqCuRzlL6KzLvxLRgNo1fEswguU6RLaETPjw2SNzs4   10m       system:bootstrap:b53294   Approved,Issued

$ kubectl get nodes
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    11m       v1.18.5
instance-3   Ready      master    11m       v1.18.5
instance-4   Ready      master    11m       v1.18.5
instance-5   NotReady   node      10m       v1.18.5
instance-6   NotReady   node      10m       v1.18.5
instance-7   NotReady   node      10m       v1.18.5

$ kubectl -n kube-system get pod -o wide
NAME                                       READY     STATUS              RESTARTS   AGE       IP            NODE
calico-kube-controllers-7779fd5f4c-v95ps   1/1       Running             0          34m       10.30.0.204   instance-4
calico-node-6fcbj                          2/2       Running             0          34m       10.30.0.204   instance-4
calico-node-9tzx9                          0/2       ContainerCreating   0          34m       10.30.0.205   instance-5
calico-node-hhd5b                          2/2       Running             0          34m       10.30.0.202   instance-2
calico-node-hjzx7                          2/2       Running             0          34m       10.30.0.203   instance-3
calico-node-nfqqs                          0/2       ContainerCreating   0          34m       10.30.0.207   instance-7
calico-node-sm454                          0/2       ContainerCreating   0          34m       10.30.0.206   instance-6
etcd-instance-2                            1/1       Running             0          34m       10.30.0.202   instance-2
etcd-instance-3                            1/1       Running             0          35m       10.30.0.203   instance-3
etcd-instance-4                            1/1       Running             0          35m       10.30.0.204   instance-4
haproxy-instance-2                         1/1       Running             0          35m       10.30.0.202   instance-2
haproxy-instance-3                         1/1       Running             0          35m       10.30.0.203   instance-3
haproxy-instance-4                         1/1       Running             0          35m       10.30.0.204   instance-4
keepalived-instance-2                      1/1       Running             0          35m       10.30.0.202   instance-2
keepalived-instance-3                      1/1       Running             0          35m       10.30.0.203   instance-3
keepalived-instance-4                      1/1       Running             0          35m       10.30.0.204   instance-4
kube-apiserver-instance-2                  1/1       Running             0          35m       10.30.0.202   instance-2
kube-apiserver-instance-3                  1/1       Running             0          35m       10.30.0.203   instance-3
kube-apiserver-instance-4                  1/1       Running             0          35m       10.30.0.204   instance-4
kube-controller-manager-instance-2         1/1       Running             0          35m       10.30.0.202   instance-2
kube-controller-manager-instance-3         1/1       Running             0          35m       10.30.0.203   instance-3
kube-controller-manager-instance-4         1/1       Running             0          35m       10.30.0.204   instance-4
kube-dns-654684d656-jkprr                  0/3       Pending             0          34m       <none>        <none>
kube-proxy-4dtr6                           1/1       Running             0          34m       10.30.0.204   instance-4
kube-proxy-4lc6x                           1/1       Running             0          34m       10.30.0.203   instance-3
kube-proxy-84vzq                           0/1       ContainerCreating   0          34m       10.30.0.207   instance-7
kube-proxy-cxkdl                           0/1       ContainerCreating   0          34m       10.30.0.206   instance-6
kube-proxy-h2vgj                           0/1       ContainerCreating   0          34m       10.30.0.205   instance-5
kube-proxy-w9rxj                           1/1       Running             0          34m       10.30.0.202   instance-2
kube-scheduler-instance-2                  1/1       Running             0          35m       10.30.0.202   instance-2
kube-scheduler-instance-3                  1/1       Running             0          35m       10.30.0.203   instance-3
kube-scheduler-instance-4                  1/1       Running             0          35m       10.30.0.204   instance-4
```

## Add K8s Cluster Manager Node.

批量添加 Master 节点到集群, 首先在 `nodes` 文件中 `k8s-cluster-add-master` 下添加需要添加的节点: (支持批量)

```
[k8s-cluster-add-master]
130.211.245.55
...
```

部署安装:
```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \
        -i nodes add_master.yml -vv
```
查看 Cluster Status:
```
$ kubectl get node
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    46m       v1.18.5
instance-3   Ready      master    46m       v1.18.5
instance-4   Ready      master    46m       v1.18.5
instance-5   Ready      node      45m       v1.18.5
instance-6   Ready      node      45m       v1.18.5
instance-7   Ready      node      45m       v1.18.5
instance-8   Ready      master    7m        v1.18.5

$ kubectl get csr
NAME                                                   AGE       REQUESTOR                 CONDITION
csr-hs7lr                                              46m       system:node:instance-3    Approved,Issued
csr-kc46g                                              46m       system:node:instance-4    Approved,Issued
csr-nz8h2                                              7m        system:node:instance-8    Approved,Issued
csr-xbbg2                                              46m       system:node:instance-2    Approved,Issued
node-csr-DBuvqHT_-wjeb4DBGiovuWr3Y6t3MjywFj1kRpOIIhc   45m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-e-yBfiDSbcDTxJM8wloZLHsOStlO7TWiKDGX29dnm6I   45m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-xk3fBmT4OOHNAtbYJq4IXtLLpFlfyXLeX2PWFMNsrjk   45m       system:bootstrap:ed3fd7   Approved,Issued
```

> 在添加完相应的类型节点后, 请把 nodes 文件中对应添加节点的地址, 移动至 master/node 中, 以防止后续操作时遗漏。

## Add K8s Cluster Worker Node.

> 重要说明：
> 降低风险操作, nodes.kube-master 只保留第一个其余全部注释, 避免误操作执行其他的模式导致集群不可用。

批量添加 Node 节点到集群, 首先在 `nodes` 文件中 `k8s-cluster-add-node` 下添加需要添加的节点: (支持批量)

```
[k8s-cluster-add-node]
34.80.142.147
...
```

部署安装:
```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \
        -i nodes add_nodes.yml -vv
```
Cluster Status
```
$ kubectl get node
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    46m       v1.18.5
instance-3   Ready      master    46m       v1.18.5
instance-4   Ready      master    46m       v1.18.5
instance-5   Ready      node      45m       v1.18.5
instance-6   Ready      node      45m       v1.18.5
instance-7   Ready      node      45m       v1.18.5
instance-8   Ready      master    7m        v1.18.5
instance-9   NotReady   node      10s       v1.18.5

$ kubectl get csr
NAME                                                   AGE       REQUESTOR                 CONDITION
csr-hs7lr                                              47m       system:node:instance-3    Approved,Issued
csr-kc46g                                              47m       system:node:instance-4    Approved,Issued
csr-nz8h2                                              8m        system:node:instance-8    Approved,Issued
csr-xbbg2                                              47m       system:node:instance-2    Approved,Issued
node-csr-DBuvqHT_-wjeb4DBGiovuWr3Y6t3MjywFj1kRpOIIhc   46m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-GztgEuKzz0eVw77CDPzvxnkuhvYE8jucK_xA_tBkJCA   1m        system:bootstrap:ed3fd7   Approved,Issued
node-csr-e-yBfiDSbcDTxJM8wloZLHsOStlO7TWiKDGX29dnm6I   46m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-xk3fBmT4OOHNAtbYJq4IXtLLpFlfyXLeX2PWFMNsrjk   46m       system:bootstrap:ed3fd7   Approved,Issued
```

> 在添加完相应的类型节点后, 请把 nodes 文件中对应添加节点的地址, 移动至 master/node 中, 以防止后续操作时遗漏。

## Clean Kubernetes Cluster

清除集群所有部署的数据信息:

```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \
        -i nodes remove_cluster.yml -vv
```

> 移除集群是对集群中所有节点来说的, 它会销毁集群中的所有安装过的应用以及配置。但不包含 docker、cfssl 等可供后续使用的应用。
> 
> 清除集群时 IPVS 默认不会清除规则, 所以需要自己执行 `ipvsadm -C` 来解决.

## Add Etcd Cluster Node

对现有集群添加支持 TLS 的 Etcd 节点, 批量添加 Node 节点到集群, 首先在 `nodes` 文件中 `etcd-cluster-add-node` 下添加需要添加的节点: (支持批量)

> 添加 Etcd 需要保证 Etcd 节点数在 2 个以上, 否则会出现没有 Leader 而无法加入集群的问题。

```
[etcd-cluster-add-node]
130.211.245.55
...
```

> 添加 Etcd 时, 需要保证添加的节点已经是 Kubernetes Master/Node 的成员, 否则不会生效。

部署安装:
```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \
        -i nodes add_etcd.yml -vv
```
> 添加的节点在现有的集群中不会被直接识别到, 因为 Etcd Endpoints 还是之前使用的, 如需要修改目前只支持手动更新, 因为牵扯太多目前不支持热更新服务配置, 否则会引起 apiServer、Calico 等应用的使用。

> 在添加完相应的类型节点后, 请把 nodes 文件中对应添加节点的地址, 移动至 etcd 中, 以防止后续操作时遗漏。

## Add Ons

默认创建集群时, 是可以直接部署 Add-Ons 的, 如果后续进行部署, 则直接通过 tags 方式进行部署即可:

```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \ 
        -i nodes main.yml --tags k8s-addons -vv
```

## K8s TLS Rotation

默认通过 CFSSL 创建出的 CA 根证书只有 5 年时效, 如果更新根证书不当可能会涉及到 Master/Node 上大面积的应用不可用的问题, 下面的集群证书更新方式只适用于通过上述安装部署的集群使用, 其他服务集群请自行尝试, 目前没有发现问题:
> 需要保证 nodes 文件中不要有 add.* 开头的 Group, 在部署时会重新启动 Calico 网络, 但经过大量测试没有发现对集群访问的影响.

> 使用时, 只需要保证 `tls_k8s.*` 的配置符合自身需求即可进行证书更新.

部署安装:
```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \
        -i nodes k8s_certificate_rotation.yml -vv
```

此方式会让 kubelet 重新加入到集群中, 所以可能会大面积的看到 csr 状态:
```
$ kubectl get csr
NAME        AGE   REQUESTOR                         CONDITION
csr-26cfs   13m   system:node:instance-template-2   Approved,Issued
csr-2ldhb   18m   system:node:instance-template-2   Approved,Issued
csr-2q5rz   44m   system:node:instance-template-2   Approved,Issued
csr-5ww4d   26m   system:node:instance-template-2   Approved,Issued
csr-7fffj   62m   system:node:instance-template-1   Approved,Issued
csr-7swmb   44m   system:node:instance-template-1   Approved,Issued
csr-9pjxr   18m   system:node:instance-template-1   Approved,Issued
csr-blrw7   66m   system:node:instance-template-2   Approved,Issued
csr-bprkl   66m   system:node:instance-template-1   Approved,Issued
csr-cmt86   55m   system:bootstrap:0a7860           Approved,Issued
csr-dt6x4   48m   system:node:instance-template-1   Approved,Issued
csr-j87l7   12m   system:bootstrap:2db6c4           Approved,Issued
csr-kqtdr   75m   system:node:instance-template-2   Approved,Issued
csr-m4567   48m   system:node:instance-template-2   Approved,Issued
csr-mh9cr   26m   system:node:instance-template-1   Approved,Issued
csr-nnkwg   38m   system:node:instance-template-1   Approved,Issued
csr-pcnn8   13m   system:node:instance-template-1   Approved,Issued
csr-rvmws   62m   system:node:instance-template-2   Approved,Issued
csr-t8f44   38m   system:node:instance-template-2   Approved,Issued
csr-zp7tr   75m   system:node:instance-template-1   Approved,Issued
...
```
> 上述集群只有几个节点, 所以有重复的添加状态。

## Upgrade Version

支持集群版本升级, 执行命令如下: (目前支持 1.14.x 升级 1.15.x 其他版本请自行尝试)

只需要配置 `k8s_version` 参数指定版本即可。

部署安装:
```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.15.x \
        -i nodes upgrade_version.yml -vv
```

执行结果如下:
```
$  kubectl get node
NAME                  STATUS   ROLES    AGE    VERSION
instance-2            Ready    <none>   2m2s   v1.14.2
instance-template-1   Ready    master   2m5s   v1.14.2
instance-template-2   Ready    master   2m3s   v1.14.2

$ kubectl get node
NAME                  STATUS   ROLES    AGE   VERSION
instance-2            Ready    <none>   6m6s  v1.15.0
instance-template-1   Ready    master   6m6s  v1.15.0
instance-template-2   Ready    master   6m6s  v1.15.0
 
 $ kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.0", GitCommit:"e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529", GitTreeState:"clean", BuildDate:"2019-06-19T16:40:16Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.0", GitCommit:"e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529", GitTreeState:"clean", BuildDate:"2019-06-19T16:32:14Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

## Etcd TLS Rotation

与 K8s TLS Rotation 方式类似, 当更换证书时, 则集群中的 Etcd 需要重启服务, 可能会造成一定范围时间内的服务不可用, 启动完成时会对 Master 中的 apiServer 以及 Calico 进行重新配置并启动的过程.

部署安装:
```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \
        -i nodes etcd_certificate_rotation.yml -vv
```

## Ansible in Docker

在 Docker 内使用 Ansible 进行部署, 使用时挂载本地的 nodes 文件和 group_vars/all.yml 文件进行部署。

部署安装: (版本请自己根据需求查看 [slzcc/crane](https://cloud.docker.com/u/slzcc/repository/docker/slzcc/crane) 获取)
```
$ docker run --name crane --rm -i \
        -e ANSIBLE_HOST_KEY_CHECKING=false \
        -e TERM=xterm-256color \
        -e COLUMNS=238 \
        -e LINES=61 \
        -v ~/.ssh:/root/.ssh \
        -v ${PWD}:/crane \
        slzcc/crane:v1.18.5.0 \
        -i nodes main.yml -vv
```
> ~~切记！不要在任何 Master 或者 Node 节点上使用 Ansible in Docker 会造成 Dockerd 被重启导致服务中断！~~

> 如果实例上的 daemon.json 与部署的文件一致, 则不会导致 DockerD 重启, 可以在任意节点上使用 Ansible in Docker. 如果第一次部署请配置如下:
```
$ systemctl stop docker
$ cat > /etc/docker/daemon.json  <<EOF
{
    "registry-mirrors": ["https://4dyopx9i.mirror.aliyuncs.com"],
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "1G"
    },
    "data-root": "/var/lib/docker",
    "insecure-registry": []
}
EOF
 
 $ systemctl start docker
```

> 通过自定义 daemin.json 来保证 Ansible in Docker 不重启 DockerD。

---