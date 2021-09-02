- [v1.22](#v122)
  - [Updated Instructions](#updated-instructions)
    - [v1.22.0.0 更新内容](#v12200)
    - [v1.22.1.0 更新内容](#v12210)
    - [v1.22.1.1 更新内容](#v12211)
    - [v1.22.1.2 更新内容](#v12212)
    - [v1.22.1.3 更新内容](#v12213)

# v1.22.0.0

Crane 以更新至 1.22.0.0 版本。

更新组件版本:
 * pause:      3.5
 * coredns:    1.8.4
 * cni:        v0.9.1
 * etcd:       3.4.9
 * calico:     v3.20.0
 * cilium:     v1.10.3
 * containerd: 1.5.5
 * cri_tools:  v1.22.0
 * crio:       v1.21.2
 * docker:     20.10.8
 * haproxy:    2.4.2

[Kubernetes](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.22.md) 1.22.0 版本官方更新说明.

# v1.22.1.0

Crane 以更新至 1.22.1.0 版本。

# v1.22.1.1

拆分 k8s_addons 到 k8s_addons.yml 中, 不在放入默认 main.yml 文件中。

修改 `rbac.authorization.k8s.io/v1beta1` 为 `rbac.authorization.k8s.io/v1` 。

优化 crane 方式部署时使用 cri 执行不必要命令。`crane/roles/downloads-packages/tasks/main.yml`

优化 crane 方式部署时使用 cri 获取镜像时执行不必要命令。`crane/roles/downloads-packages/includes/crane/containerd/main.yml` and `crane/roles/downloads-packages/includes/crane/docker/main.yml`

# v1.22.1.2

优化 kube-apiserver、kube-controller-manager、kube-scheduler 健康检查以及启动命令。

更新 logo.

## 修复

修复 crane 初始化脚本引发的 `etcd_ssl_dirs` 环境变量丢失问题。


# v1.22.1.3

按照 kubernetes 一致性测试 [sonobuoy](https://github.com/vmware-tanzu/sonobuoy) 进行初始化配置。

1、需要部署 `ingress-nginx`.
2、修改 `/etc/resole.conf` 文件为空或者只保留 nameserver.(关闭 systemd-resolved => systemctl stop systemd-resolved)
3、去掉 kube-apiserver 中的 `--service-node-port-range` 配置, 走默认项.
4、开启 `CoreDNS` 访问 `log` 以便查看错误.
5、各机器安装 `socat`.