- [v1.22](#v122)
  - [Updated Instructions](#updated-instructions)
    - [v1.22.0.0 更新内容](#v12200)
    - [v1.22.1.0 更新内容](#v12210)
    - [v1.22.1.1 更新内容](#v12211)
    - [v1.22.1.2 更新内容](#v12212)
    - [v1.22.1.3 更新内容](#v12213)
    - [v1.22.1.4 更新内容](#v12214)

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

1、修改 `/etc/resole.conf` 文件为空或者只保留 nameserver.(关闭 systemd-resolved => systemctl stop systemd-resolved)

2、去掉 kube-apiserver 中的 `--service-node-port-range` 配置或改为 `30000-32767`, 走默认项.

3、开启 `CoreDNS` 访问 `log` 以便查看错误.

4、各机器安装 `socat`.

5、移除 `kube-proxy` 中的 `nodePortAddresses` 配置, 因一致性测试会有 `127.0.0.1` 请求测试.

6、使用 cilium v1.10.3, 需修改 cilium_hostPort 为 [portmap](https://github.com/cilium/cilium/blob/master/Documentation/gettingstarted/cni-chaining-portmap.rst#portmap-hostport)网络, calico 在测试时有问题无法多集群访问, 可能由于使用 `GoogleCloud` 环境造成。

> https://github.com/cilium/cilium/issues/14287

> https://github.com/rancher/rke2/issues/935

8、集群实例必须 2 个以上, 否则无法通过 `[sig-apps] Daemon set` 测试.

## 更新

1、CoreDNS 配置文件中对反向解析进行更改, 并添加 `ttl 30`.

2、修改 cilium 中 `cilium_hostPort` 选项, 之前的配置项不准确.

# v1.22.1.4

## 修复

cri 创建 docker 配置文件目录 `/etc/docker/certs.d`.

修复 cilium metrics 端口不一致问题。

修复下载 cfssl 时无法跳转 301 造成无法下载的问题。

修复默认安装时只允许 kube-master 安装 cfssl 的判定。

## 更新

更新 cilium 1.10.3 ~ 4 版本的 template 文件内容。

更新 crane logo, 准备 cncf k8s 一致性检测使用.