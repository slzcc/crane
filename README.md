# Crane
![language](https://img.shields.io/badge/language-Ansible-green.svg) [![Wiki](https://img.shields.io/badge/docs-94%25-green.svg)](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster)

![logo](logo/logo_size6_w200_h200.jpeg)

---

Please refer to the documentation for detailed configuration: [Wiki Docs URL](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster)。

使用 Ansible 基于容器化部署 Kubernetes Cluster（非 Kubeadm）, 并支持 Master/Node/Etcd 节点的添加。

部署全局基于 TLS, 并区分 K8s Cluster CA、Etcd CA 证书, 并支持证书轮转。

部署时支持离线、在线 kubernetes 和 CRI 的安装。

CRI 支持多种服务共存部署模式, 可同时部署 docker/containerd/crio, 用户自定义 RuntimeClass 运行时。

部署 Crane 时可查看注意事项, 避免无效操作:

> [Crane for Kubernetes 使用注意事项](docs/MattersNeedingAttention.md)

每一个 [Release](https://github.com/slzcc/crane/releases) 版本都严格按照 [Crane for Github Actions](https://github.com/slzcc/crane/actions) 进行检测, 保证服务的稳定性。

# 部署说明

部署示例请参照 [Crane Install](./docs/INSTALL.md) 文件进行部署。

各功能示例参照 [Crane Other Features](./docs/FunctionalSpecifications.md) 文件进行部署。

Add-Ons 参照 [Add-Ons Install](./crane/roles/add-ons) 文件进行部署。

---

# 模拟部署

通过 Kubernetes in Docker 方式测试演练，所有操作都包含在 Docker 镜像中，不会涉及其他环境依赖，方便快捷进行测试.

部署示例请参照 [Kube Simple](./kube-simple/README.md) 文件进行部署。

---

## 推荐亮点

- [x] 支持集群后续 `Kubernetes Cluster` 扩容, 支持添加 `Master/None` 节点。
- [x] 支持集群后续 `Etcd Cluster` 扩容 (只添加节点, 对现有集群无感知) `v1.14.1.8` 中添加。
- [x] 支持自定义镜像仓库地址。
- [x] 支持 `Add-Ons` 等应用部署。
- [x] 支持自定义 TLS 。
- [x] 支持 `Kubernetes Cluster CA` 根证书更新。
- [x] 支持 `Kubernetes Cluster` 版本升级。
- [x] 支持 `Etcd Cluster CA` 根证书更新。
- [x] 支持 `Ansible in Docker` 方式进行部署。
- [x] 支持 `Dockerd` 离线安装.
- [x] 支持 `Kubernetes` 离线安装.

## 安装过程示例

通过[Kube Simple](./kube-simple/README.md) 部署演练安装过程.

[![asciicast](https://asciinema.org/a/uyVFgcNEUiv9AciahaTFCRvM6.svg)](https://asciinema.org/a/uyVFgcNEUiv9AciahaTFCRvM6)

> 如有不明请参照 [Kube Simple](./kube-simple/README.md) 文档进行补充.

---

> Logo 图片并非商业, 本人无意侵犯版权。 前 Ansible-Kubernetes 正式更名 Crane .
