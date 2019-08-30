# Crane
![language](https://img.shields.io/badge/language-Ansible-green.svg) [![Wiki](https://img.shields.io/badge/docs-94%25-green.svg)](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster)

![logo](doc/logo_size6_w200_h200.jpeg)

---

Please refer to the documentation for detailed configuration: [Wiki Docs URL](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster)。

> Wiki 文档内容为 1.14.x 版本

> 以下所有的部署全部使用 Ubuntu 16.04 为环境进行示例演练。个人部署时请使用最新版进行尝试。

使用 Ansible 基于容器化部署 Kubernetes Cluster（非 Kubeadm）, 并支持 Master/Node 节点的添加。（旧版本的 HaProxy 需要自己更新新节点的上游配置）

部署全局基于 TLS, 并区分 K8s Cluster CA、Etcd CA 证书。

部署时支持离线、在线和镜像方式部署, 默认使用在线和镜像方式部署, 在线方式相当于主动 Pull 获取包(如果基于镜像则下载镜像, 如非镜像部署则下载二进制), 镜像方式基于 `image in image` 策略方式部署, 离线则只适用于镜像方式部署, 把 `image in image` 镜像放置在本地推送到目标机进行部署。参看文档: [Docs](script)

> 不支持单独使用 tag 方式部署, 因全部使用 Kubelet 的静态方式部署启动 Pod, 如删除集群某一批次的节点时 tag 比较有用。

> 目前还暂不支持国内服务器直接进行部署, 如果不使用镜像方式部署，则部署时镜像基于 `k8s.gcr.io` 地址进行下载, 国内访问时可能会被墙。受影响的应用 `etcd`、`kube-apiserver-amd64`、`kube-controller-manager`、`kube-scheduler`、`kube-proxy`、`pause` 。

> 可修改参数 `k8s_cluster_component_registry` 值为 `slzcc` 自定义镜像仓库地址, 在使用自定义镜像仓库时, 请确保已经执行过 `script/PublishK8sRegistryImages.sh` 脚本。(可支持的镜像版本参阅 [slzcc/kubernetes](https://hub.docker.com/r/slzcc/kubernetes))

> 默认 Etcd 需要跟随 Master 进行部署, 暂不支持 Etcd 部署在 Node 中 (后期会优化, 在添加  节点时支持 Node 节点部署)。

目前支持的 Kubernetes 版本:
* v1.10.0
* v1.14.x
* v1.15.x

在 v1.14.x 开始, 可以支持动态的选择版本进行部署, 如 v1.14.1/v1.14.2 版本, 但目前只支持小版本。后续会添加集群的热更新。
## 推荐亮点

- [x] 支持集群后续 Kubernetes Cluster 扩容, 支持添加 Master/None 节点。
- [x] 支持集群后续 Etcd Cluster 扩容 (只添加节点, 对现有集群无感知) v1.14.1.8 中添加。
- [x] 支持自定义镜像仓库地址。
- [x] 支持 Add-Ons 等应用部署。
- [x] 支持自定义 TLS 。
- [x] 支持 Kubernetes Cluster CA 根证书更新。
- [x] 支持 Kubernetes Cluster 版本升级。
- [x] 支持 Etcd Cluster CA 根证书更新。
- [x] 支持 Ansible in Docker 方式进行部署。

## 项目部署架构
以 v1.15.x 为例：
* Kubernetes A/C/S v1.15.x
* CoreDNS: v1.5.0
* Calico: v3.7.3
* Kube Proxy: v1.15.x
* HaProxy: v2.0.0
* Etcd: v3.3.10
* pause: v3.1

## 代办项目

- [x] 支持自定义远程镜像仓库地址, 默认 `k8s.gcr.io`, 可修改为 `slzcc` 自定义镜像仓库, 在使用自定义镜像仓库时, 请确保已经执行过 `script/PublishK8sRegistryImages.sh` 脚本。
- [x] 支持 Etcd 热添加节点。
- [x] 支持 Add Ons 其他 Tools 部署, 包括 Helm、Prometheus、Ingress-Nginx、Ingress-Example、DNS-Tools。
- [x] 支持 Istio。
- [x] 支持操作系统预判部署 Ubuntu/Centos 更合理的安装即优化, v1.14.2.6 中优化.
- [ ] 支持 Harbor HTTPS 部署。
- [x] 支持 TLS 证书自定义。v1.15.0.2 中更新。
- [ ] 支持 OpenResty 入口流量的灰度发布。
- [x] 支持 Kubernetes 热更新 TLS, v1.15.0.3 版本更新。对集群中 Master/Node/Kubelet 等组件的所有 TLS 服务进行证书更新, 主要解决 CFSSL 默认申请 CA 证书 5 年时效问题, 以及后续可能存在的证书泄露问题。（Beta Version）
- [x] 支持 Etcd 热更新 TLS, v1.15.0.6 中更新。
- [x] 支持 Kubernetes 镜像导入方式部署, v1.14.2.1 版本更新。 默认使用镜像部署, 支持的版本请参看 [slzcc/kubernetes](https://hub.docker.com/r/slzcc/kubernetes/tags)
- [ ] ~~支持 Proxy 方式部署 Docker Image 和 二进制应用, 已经通过容器方式部署.~~
- [x] 支持离线方式部署 Kubernetes Cluster, 可参阅 [downloads-packages](roles/downloads-packages/files/)
- [x] 支持 IPVS, v1.14.2.8 版本更新.
- [x] 支持 Ansible in Docker 方式部署, 不在依赖于本地环境。v1.15.3.0 中更新。
- [x] 支持 Kubernetes Cluster 版本更新, v1.15.0.5 中更新。

## 修复

- [x] 修复 Calico 在使用时, 无法与 Etcd 进行通信。
- [x] 脚本绝大部分使用 Shell 执行, 后期重构统一使用模块解决跨平台执行。
- [x] 修复 Calico 在使用时, 无法识别宿主机网卡, 造成无法通信的问题。
- [x] 修复 Bootstrap 无法创建凭证的问题。
- [x] 修复 Swap 如果打开情况下的优化配置, v1.14.2.5 中修复。
- [x] 修复 Ubuntu IPVS 模式下无法跨主机访问问。v1.14.2.9 中修复。
- [x] 修复 Kubernetes 添加节点时, 无法获取真实的宿主机 IP 地址, v1.15.0.1 中修复。
- [x] 修复 CNI 容器部署 Download Plugin 位置错误。v1.15.0.2 中修复。(之前版本实际不受影响, Calico 有自己的初始化 Plugin 部署方式) 
- [x] 修复 kubelet 重新加入集群时, 证书无效的问题, v1.15.0.3 中修复。
- [x] 修复添加 Master 节点时, HaProxy 没有及时更新新节点问题, v1.15.0.5 中修复。
- [x] 修复 Add Etcd 节点时, 没有更新 Kubu apiServer 和 Calico、Etcd 服务的配置信息, v1.15.0.6 中修复。

## 获取对应的版本
切记, 如需要安装哪个大版本的集群, 就获取相应的 tag :
```
$ git clone -b v1.15.x.x https://github.com/slzcc/crane.git
```

> v1.15.x.x 最末尾一位属于编写 Ansible 脚本的迭代版本, 不属于 Kubernetes 自身版本。

> 不建议下载 zip 格式源码进行部署, 没有正式测试。

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
如上述修改完成后, 可执行命令（v1.10.0 部署版本为例）：
```
$ export ANSIBLE_HOST_KEY_CHECKING=true
$ ansible-playbook -i nodes main.yml -vv
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
instance-2   Ready      master    11m       v1.10.0
instance-3   Ready      master    11m       v1.10.0
instance-4   Ready      master    11m       v1.10.0
instance-5   NotReady   node      10m       v1.10.0
instance-6   NotReady   node      10m       v1.10.0
instance-7   NotReady   node      10m       v1.10.0

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
$ ansible-playbook -i nodes add_master.yml -vv
```
查看 Cluster Status:
```
$ kubectl get node
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    46m       v1.10.0
instance-3   Ready      master    46m       v1.10.0
instance-4   Ready      master    46m       v1.10.0
instance-5   Ready      node      45m       v1.10.0
instance-6   Ready      node      45m       v1.10.0
instance-7   Ready      node      45m       v1.10.0
instance-8   Ready      master    7m        v1.10.0

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
批量添加 Node 节点到集群, 首先在 `nodes` 文件中 `k8s-cluster-add-node` 下添加需要添加的节点: (支持批量)
```
[k8s-cluster-add-node]
34.80.142.147
...
```

部署安装:
```
$ ansible-playbook -i nodes add_nodes.yml -vv
```
Cluster Status
```
$ kubectl get node
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    46m       v1.10.0
instance-3   Ready      master    46m       v1.10.0
instance-4   Ready      master    46m       v1.10.0
instance-5   Ready      node      45m       v1.10.0
instance-6   Ready      node      45m       v1.10.0
instance-7   Ready      node      45m       v1.10.0
instance-8   Ready      master    7m        v1.10.0
instance-9   NotReady   node      10s       v1.10.0

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
$ ansible-playbook -i nodes remove_cluster.yml -vv
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
$ ansible-playbook -i nodes add_etcd.yml -vv
```
> 添加的节点在现有的集群中不会被直接识别到, 因为 Etcd Endpoints 还是之前使用的, 如需要修改目前只支持手动更新, 因为牵扯太多目前不支持热更新服务配置, 否则会引起 apiServer、Calico 等应用的使用。

> 在添加完相应的类型节点后, 请把 nodes 文件中对应添加节点的地址, 移动至 etcd 中, 以防止后续操作时遗漏。

## Add Ons
默认创建集群时, 是可以直接部署 Add-Ons 的, 如果后续进行部署, 则直接通过 tags 方式进行部署即可:
```
$ ansible-playbook -i nodes main.yml --tags k8s-addons -vv
```

## K8s TLS Rotation
默认通过 CFSSL 创建出的 CA 根证书只有 5 年时效, 如果更新根证书不当可能会涉及到 Master/Node 上大面积的应用不可用的问题, 下面的集群证书更新方式只适用于通过上述安装部署的集群使用, 其他服务集群请自行尝试, 目前没有发现问题:
> 需要保证 nodes 文件中不要有 add.* 开头的 Group, 在部署时会重新启动 Calico 网络, 但经过大量测试没有发现对集群访问的影响.

> 使用时, 只需要保证 `tls_k8s.*` 的配置符合自身需求即可进行证书更新.

部署安装:
```
$ ansible-playbook -i nodes k8s_certificate_rotation.yml -vv
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
$ ansible-playbook -i nodes upgrade_version.yml -vv
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
$ ansible-playbook -i nodes etcd_certificate_rotation.yml -vv
```

## Ansible in Docker
在 Docker 内使用 Ansible 进行部署，使用时挂载本地的 nodes 文件和 group_vars/all.yml 文件进行部署。

部署安装:
```
$ docker run --rm -i \
         -v ~/.ssh:/root/.ssh \
         -v ${PWD}/nodes:/crane/nodes \
         -v ${PWD}/group_vars:/carne/group_vars \
         slzcc/crane:v1.15.0 \
         -i nodes main.yml -vv
```
> 切记！不要再任何 Master 或者 Node 节点上使用 Ansible in Docker 因为指令会重启 Dockerd！

---

>Logo 图片并非商业, 本人无意侵犯版权。 前 Ansible-Kubernetes 正式更名 Crane