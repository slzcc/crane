# Crane
![language](https://img.shields.io/badge/language-Ansible-green.svg) [![Wiki](https://img.shields.io/badge/docs-94%25-green.svg)](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster)

![logo](logo/new-crane-logo-no-text_w177_h160.png)
---

Please refer to the documentation for detailed configuration: [Wiki Docs URL](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster)。

Crane 使用半离线安装, 解决国内无法使用 `k8s.gcr.io` 源问题。

使用 Ansible 基于容器化部署 Kubernetes Cluster（非 Kubeadm）, 并支持 Master/Node/Etcd 节点的添加。

部署全局基于 TLS, 并区分 K8s Cluster CA、Etcd CA 证书, 并支持证书轮转。

部署时支持半离线(默认)、离线 和 在线 kubernetes 和 CRI 的安装。

CRI 支持多种服务共存部署模式, 可同时部署 docker/containerd, 方便用户自定义 RuntimeClass 运行时。

部署 Crane 时可查看注意事项, 避免无效操作:

> 部署之前请认真读取可能会发现的问题这其中不包含 Crane 本身的问题. [Crane for Kubernetes 使用注意事项](docs/MattersNeedingAttention.md)

每一个 [Release](https://github.com/slzcc/crane/releases) 版本都严格按照 [Crane for Github Actions](https://github.com/slzcc/crane/actions) 进行检测, 保证服务的稳定性。

# 部署说明

默认部署示例请参照 [Crane Install](./docs/INSTALL.md) 文件进行部署。( Crane 默认属于半离线安装 )

离线部署示例请参照 [Crane Offine Install](./docs/OFFINE_INSTALL.md) 文件进行部署。

在线部署示例请参照 [Crane Online Install](./docs/ONLINE_INSTALL.md) 文件进行部署。

各功能示例参照 [Crane Other Features](./docs/FunctionalSpecifications.md) 文件进行部署。

kubernetes-addons 参照 [kubernetes-addons Install](./crane/roles/kubernetes-addons) 文件进行部署。

---
# 架构

Crane 的架构简述:

```
|------ Keepalived(Master) or ELB
|               |
|               |
|       Haproxy(Master)
|               |
|               |
|       Kube-ApiServer(Master)
```
在 Crane 架构中, 可以自由使用 Keepalived 或 ELB, 如果需要使用 Keepalived 则需要事先准备好 VIP 且网络可达, 否则无法正常启动。

> 使用 Keepalived 一般属于物理环境而 ELB 则属于 Cloud 环境, 请按照需求自行配置。

# 模拟部署

通过 Kubernetes in Docker 方式测试演练，所有操作都包含在 Docker 镜像中，不会涉及其他环境依赖，方便快捷进行测试。

部署示例请参照 [Kube Simple](./kube-simple/README.md) 文件进行部署。

---

## 推荐亮点

- [x] 支持集群后续 `Kubernetes Cluster` 扩容, 支持添加 `Master/None` 节点。
- [x] 支持集群后续 `Etcd Cluster` 扩容 (只添加节点, 对现有集群无感知)。
- [x] 支持自定义镜像仓库地址。
- [x] 支持 `kubernetes-addons` 等应用部署。
- [x] 支持自定义 TLS 。
- [x] 支持 `Kubernetes Cluster CA` 根证书更新。
- [x] 支持 `Kubernetes Cluster` 版本升级。
- [x] 支持 `Etcd Cluster CA` 根证书更新。
- [x] 支持 `Ansible in Docker` 方式进行部署。
- [x] 支持 `Dockerd`、`Containerd` 离线安装。
- [x] 支持 `Kubernetes` 离线安装。
- [x] 支持 `Dockerd`、`Containerd`、`CRIO` 的容器运行环境部署。
- [x] 支持新建 `Etcd` 集群并支持恢复。

## 安装过程示例

通过[Kube Simple](./kube-simple/README.md) 部署演练安装过程.

[![asciicast](https://asciinema.org/a/uyVFgcNEUiv9AciahaTFCRvM6.svg)](https://asciinema.org/a/uyVFgcNEUiv9AciahaTFCRvM6)

> 如有不明请参照 [Kube Simple](./kube-simple/README.md) 文档进行补充.

> 使用 GoogleCloud 4C 8GB 单节点部署无任何干预初始化安装最高耗时 `7m13.958s` 如有镜像安装包最高耗时 `2m4.153s`, 如多节点安装需要增加推送安装包耗时.
