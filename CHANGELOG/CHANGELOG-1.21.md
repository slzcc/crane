- [v1.21](#v121)
  - [Updated Instructions](#updated-instructions)
    - [v1.21.0.0 更新内容](#v12100)
    - [v1.21.0.1 更新内容](#v12101)
    - [v1.21.1.0 更新内容](#v12110)
    - [v1.21.1.1 更新内容](#v12111)
    - [v1.21.1.2 更新内容](#v12112)
    - [v1.21.1.3 更新内容](#v12113)
    - [v1.21.2.0 更新内容](#v12120)
    - [v1.21.2.1 更新内容](#v12121)
    - [v1.21.2.2 更新内容](#v12122)
    - [v1.21.2.3 更新内容](#v12123)

# v1.21.0.0

Crane 以更新至 1.21.0.0 版本。

更新组件版本:
 * coredns:    1.8.3
 * cni:        v0.9.1
 * etcd:       3.4.9
 * calico:     v3.18.1
 * containerd: 1.4.4
 * cri_tools:  v1.21.0
 * crio:       v1.20.2
 * docker:     20.10.5
 * haproxy:    2.3.9

[Kubernetes](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.21.md) 1.21.0 版本官方更新说明.


# v1.21.0.1

dockerd 删除 aliyun 的加速器配置, 因 aliyun 加速器存在超时的问题。


# v1.21.1.0

Crane 以更新至 1.21.0.0 版本。

# v1.21.1.1

## 修复

修复 etcd Backup 时, 备份文件丢失的问题。

修复 calico 网络在通过 `upgrade_version.yml` 时执行删除顺序的报错。

关闭 `upgrade_version.yml` 中自动关闭集群 `node` 节点的调度, 移除独立操作文件 `k8s_setup_close_schedule.yml` 和 `k8s_setup_open_schedule.yml`, 提倡人为执行。

修复 Makefile 不下载 crictl 工具问题。

修复如不想默认安装 cri 时, 还会安装 runC 和 crictl 的问题。

修复添加或删除节点时, labels 不会变更的问题。

修复添加 node 节点时, 无法找到 cri-tools 版本的问题。

## 新增

`k8s_setup_close_schedule.yml` 关机集群 `node` 节点调度。

`k8s_setup_open_schedule.yml` 开启集群 `node` 节点调度。

> 上述功能主要是人为维护集群时手动批量操作功能。

`etcd_backup_cluster.yml` 备份当前 `etcd` 集群, 备份文件默认在第一个 `etcd` 节点的 `/tmp/crane/etcdb` 中。

`etcd_new_cluster.yml` 新建一组 `etcd` 集群通过 `nodes` 文件中的 `[etcd-del-cluster]` 适配。

`etcd_restore_cluster.yml` 新建一组 `etcd` 集群通过 `nodes` 文件中的 `[etcd-new-cluster]` 适配, 

并且支持指定文件恢复, 可通过 `roles/etcd-cluster-management/defaults/etcd-new-cluster.yaml` 配置支持 `http` 和本地文件方式进行恢复。

`migration_k8s_to_new_etcd_cluster.yml` 让 apiServer 服务指向指定的新 `etcd` 集群, 通过 `[etcd-new-cluster]` 适配。

`remove_etcd_cluster.yml` 删除指定的 `etcd` 集群数据及配置, 不要与 `remove_etcd_nodes.yml` 混淆, `remove_etcd_nodes.yml` 主要是移除集群中的一个或多个节点, `remove_etcd_cluster.yml` 是删除一整组集群。

> 上述功能主要操作 etcd。

`remove_k8s_master.yml` 对 `master` 节点降级为 `node` 节点, 并同步 `haproxy` 配置信息。

# v1.21.1.2

## 修复

修复 `upgrade version` 过程中先 `kube-proxy` 先删除在启动的逻辑, 改成升级策略。

修复 `calico` 3.18.x 版本初始安装时, `CRD` 不全的问题。

修复 `remove cluster` 中 `calico` 配置残留的问题。

修复 `calico` 默认为 `IPIP` 模式, 因绝大多数纯 `BGP` 模式无法正常启动。

## 新增

升级 `kube-proxy` 之前会先备份集群中的 `kube-proxy`。

新增 `k8s_mainifests_rotation.yml` 对 `/etc/kubernetes/manifests/kube-apiserver.yml`、`kube-controller-manager.yml`、`kube-scheduler.yml`、`haproxy.yml` 配置进行更新, 并默认备份到 `/tmp/crane/kubernetes-mainifests-rotation`。

新增 `k8s_kubelet_rotation.yml` 对 `/etc/systemd/system/kubelet.service.d`、 `/var/lib/kubelet/config.yaml`、 `/var/lib/kubelet/kubernetes-flags.env`、`/lib/systemd/system/kubelet.service` 进行更新并默认被放到 `/tmp/crane/kubernetes-kubelet-rotation`。

# v1.21.1.3

## 更新

更新 `istio` 到 [v1.10.0](https://github.com/istio/istio/releases/tag/1.10.0)

更新 `harbor` 到 [2.1.5](https://github.com/goharbor/harbor/releases/tag/v2.1.5)

## 修复

第一次执行 `etcd_backup_cluster.yml` 存在无法找到环境变量的问题, 初步修复完毕, 后续进行优化处理。

修复 `etcd_restore_cluster.yml` 中证书使用的 bug, 如果新集群中使用原有的证书会出现 x509 问题。

修复 `upgrade_version.yml` 中, 不必要的 `kubelet` 停止服务操作。

# v1.21.2.0

Crane 以更新至 1.21.2.0 版本。

## 修复

修复 `calico` 部署时, 配置中因 `FELIX_LOGSEVERITYSCREEN` 存在引起的服务无法正常启动的问题。

修复 Calico `v3.18.1` 版本 `bug` 升级到 `v3.19.1` 解决。

# v1.21.2.1

## 更新

从 v1.21.2.1 版本开始, 引入 `cilium` 它使用 eBPF 方式截取并操作 L3/L4/L7 的网络。在当前版本中 `calico` 作为默认使用, 因 `cilium` 对内核版本需求较高需要 4.10.x 即以上版本。

## 移除

移除所有步骤过程中操作 `calico` 的更新操作。

# v1.21.2.2

## 更新

添加是否安装 kube-proxy, 由 `is_kube_proxy` 参数控制。

在 `cilium` 中添加 `cilium-ca` 的初始化, 方便后续集群通信实现可能, 默认证书时间 `20` 年。

# v1.21.2.3

## 更新

添加是否安装 kube-dns, 由 `is_kube_dns` 参数控制。主要目的是对只更新 `--tags k8s-networks` 时, 避免冲掉 CoreDNS 配置.

添加清理集群时, 清除 `sysctl` 配置项。添加文件: `roles/remove-cluster/includes/kernel.yaml`.

## 优化

cilium 配置进行优化。

清除集群时, 清除已知所有 `network` 插件。
配置内核参数时, 添加 `ip_local_reserved_ports` 配置项, 主要目的是端口保护。
