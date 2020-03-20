# 代办项目

- [x] 支持自定义远程镜像仓库地址, 默认 `k8s.gcr.io`, 可修改为 `slzcc` 自定义镜像仓库, 在使用自定义镜像仓库时, 请确保已经执行过 `script/PublishK8sRegistryImages.sh` 脚本。
- [x] 支持 `Etcd` 热添加节点。
- [x] 支持 `Add Ons` 其他 `Tools` 部署, 包括 `Helm`、`Prometheus`、`Ingress-Nginx`、`Ingress-Example`、`DNS-Tools`。
- [x] 支持 `Istio`。在 `roles/add-ons/defaults/main.yml` 中开启配置项。
- [x] 支持操作系统预判部署 `Ubuntu/Centos` 更合理的安装即优化, `v1.14.2.6` 中优化.
- [x] 支持 `Harbor HTTPS` 部署, `v1.16.1.7` 中添加。(暂支持空数据卷,请自行修改挂载点)
- [x] 支持 `TLS` 证书自定义。`v1.15.0.2` 中更新。在 `roles/kubernetes-default/defaults/main.yml` 中自定义配置。
- [ ] 支持 `OpenResty` 入口流量的灰度发布。
- [x] 支持 `Kubernetes` 热更新 `TLS`, `v1.15.0.3` 版本更新。对集群中 `Master/Node/Kubelet` 等组件的所有 `TLS` 服务进行证书更新, 主要解决 `CFSSL` 默认申请 `CA` 证书 5 年时效问题, 以及后续可能存在的证书泄露问题。（Beta Version）
- [x] 支持 `Etcd` 热更新 `TLS`, `v1.15.0.6` 中更新。
- [x] 支持 `Kubernetes` 镜像导入方式部署, `v1.14.2.1` 版本更新。 默认使用镜像部署, 支持的版本请参看 [slzcc/kubernetes](https://hub.docker.com/r/slzcc/kubernetes/tags)
- [x] 支持 `Proxy` 方式配置部署. 并支持 `Dockerd Proxy` 配置.
- [x] 支持离线方式部署 `Kubernetes Cluster`, 可参阅 [downloads-packages](../crane/roles/downloads-packages/files/)
- [x] 支持 `IPVS`, `v1.14.2.8` 版本更新。
- [x] 支持 `Ansible in Docker` 方式部署, 不在依赖于本地环境。`v1.15.3.0` 中更新。
- [x] 支持 `Kubernetes Cluster` 版本更新, `v1.15.0.5` 中更新。
- [x] 支持 `Dockerd` 离线安装, `v1.16.3.2` 中更新。[Dockerd install](../crane/roles/docker-install/)
- [x] 支持 `Kubernetes for Docker` Simple 方式部署。（主要解决部署前的测试） , `v1.17.0.6` 中更新。[Kubernetes Simple](../kube-simple/)