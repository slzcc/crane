# Ansible-Kubernetes
Please refer to the documentation for detailed configuration: [Wiki Docs URL](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster).

使用 Ansible 基于容器化部署 Kubernetes Cluster（非 Kubeadm）, 并支持 Master/Node 节点的添加。（旧版本的 HaProxy 需要自己更新新节点的上游配置）, 部署全局基于 TLS，并区分 K8s Cluster CA、Etcd CA 证书。
> 不支持单独使用 tag 方式部署, 因全部使用 Kubelet 的静态方式部署启动 Pod, 如删除集群某一批次的节点时 tag 比较有用。
> 目前还暂不支持国内服务器直接进行部署，因镜像基于 `k8s.gcr.io` 地址进行下载，国内访问时可能会被墙。受影响的应用 `etcd`、`kube-apiserver-amd64`、`kube-controller-manager`、`kube-scheduler`、`kube-proxy`。

目前支持的版本:
* v1.10.0
* v1.14.x

在 v1.14.x 开始，可以支持动态的选择版本进行部署，如 v1.14.1/v1.14.2 版本，但目前只支持小版本。后续会添加集群的热更新。

## 项目部署架构
以 v1.14.x 为例：
* Kubernetes A/C/S v1.14.x
* CoreDNS: v1.5.0
* Calico: v3.7.2
* Kube Proxy: v1.14.x
* HaProxy: v1.9.6
* Etcd: v3.3.10

## 代办项目

- [ ] 支持自定义远程镜像仓库地址 `k8s.gcr.io`
- [ ] 支持 Etcd 热添加节点
- [ ] 支持 Add Ons 其他 Tools 部署, Helm、Prometheus
- [ ] 支持 Istio
- [ ] 支持操作系统预判部署 Ubuntu/Centos 更合理的安装即优化
- [ ] 支持 Harbor HTTPS 部署
- [ ] 支持 TLS 证书自定义
- [ ] 支持 OpenResty 入口的流量灰度发布


## 获取对应的版本
切记，如需要安装哪个大版本的集群，就获取相应的 tag :
```
$ git clone -b v1.14.1.0 https://github.com/slzcc/Ansible-Kubernetes.git
```

> v1.14.1.0 最末尾一位属于编写 Ansible 脚本的迭代版本，不属于 Kubernetes 自身版本。

## 使用说明
在 nodes 文件中，分为 kube-master/kube-node/etcd 第一部分，k8s-cluster-add-master/k8s-cluster-add-node 第二部分，第三部分为集群识别的 SSH 秘钥。
```
[kube-master]
35.236.167.32

[kube-node]
34.80.142.147

[etcd]
35.236.167.32

[k8s-cluster:children]
kube-node
kube-master

[k8s-cluster-add-master]

[k8s-cluster-add-node]

[all:vars]
ansible_ssh_public_key_file='/Users/shilei/.ssh/id_rsa.pub'
ansible_ssh_private_key_file='/Users/shilei/.ssh/id_rsa'
```
第一部分为部署集群所规划的集群初始节点，可自定义添加。
第二部分为后续集群需要添加的节点可分为 master/node 。
第三部分为集群内所有节点均可使用的 SSH 秘钥。
在初次部署时，应先修改基础配置文件 group_vars/all.yml 文件, 下面列出初始部署时应修改的选项：
```
# apiServer 的入口，也就是 apiServer 的负载均衡层，可支持 lvs/keepalived 组合，如第一次部署请不要开启 lvs/keepalived ，如公有云环境也不支持 lvs/keepalived 。
k8s_load_balance_ip: < SLB 或 某节点 IP >

# Ansible 使用的远程服务器用户，可使用普通用户但必须属于 Sudo 组
ssh_connect_user: < SSH USER >

# 所有节点统一的网卡名称，否则会出现环境不一致的问题，此配置被 Etcd/LVS 服务依赖。
os_network_device_name: < NetWork Name >
```

> 如有不明确的问题，请参照上方的 Wiki 链接，如果还有问题请提交 issue .

## Deploy Kubernetes Cluster
如上述修改完成后，可执行命令（v1.10.0 部署版本为例）：
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
```
$ ansible-playbook -i nodes add_master.yml -vv
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

## Add K8s Cluster Worker Node.
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

## Clean Kubernetes Cluster
```
$ ansible-playbook -i nodes remove_cluster.yml -vv
```
