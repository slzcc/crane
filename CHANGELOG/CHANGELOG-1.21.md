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
    - [v1.21.2.4 更新内容](#v12124)
    - [v1.21.3.0 更新内容](#v12130)
    - [v1.21.4.0 更新内容](#v12140)
    - [v1.21.5.0 更新内容](#v12150)
    - [v1.21.6.0 更新内容](#v12160)
    - [v1.21.7.0 更新内容](#v12170)
    - [v1.21.8.0 更新内容](#v12180)
    - [v1.21.9.0 更新内容](#v12190)
    - [v1.21.10.0 更新内容](#v121100)
    - [v1.21.11.0 更新内容](#v121110)
    - [v1.21.12.0 更新内容](#v121120)
    - [v1.21.13.0 更新内容](#v121130)
    - [v1.21.14.0 更新内容](#v121140)

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

# v1.21.2.4

## 更新

runC 更新至 [1.0.0](https://github.com/opencontainers/runc/releases/tag/v1.0.0)

添加部分 Etcd 脚本到初始化.

更新 github actions 出现的 Error.

cilium hubble 添加 ingress 选项.

添加系统时区更新.

添加 Chrony 安装, 默认不安装需要时, 请打开 `crane/roles/system-initialize/defaults/main.yml` 中的 `is_chrony_deploy` 即可。

## 优化

docker 配置文件加入 overlay2 检查配置:

```
{% if docker_storage_driver == 'overlay2' %}
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ],
{% endif %}
```

初始化时添加系统时区配置。

```
- name: Set Time Zone
  shell: "ln -sf /usr/share/zoneinfo/{{ time_location }} /etc/localtime"
  ignore_errors: true
```

初始化时添加 SSH 优化:

```
- name: Set SSH UseDNS
  shell: "sed -ri 's/^#(UseDNS )yes/\1no/' /etc/ssh/sshd_config"
  ignore_errors: true
```

初始化时添加 Chrony and Limit 配置: (默认不会安装 chrony)

```
- name: Initialize Chrony
  include: "roles/system-initialize/includes/system/chrony.yaml"
  when: is_chrony_deploy

- name: Initialize Limit
  include: "roles/system-initialize/includes/system/limit.yaml"
```

crictl 工具安装超时直接跳过。

清理集群时, 不在清理 crictl 。


# v1.21.3.0

Crane 以更新至 1.21.3.0 版本。

## 修复

harbor 2.1.5 之前版本中 Clair 存在一个 [Bug](https://github.com/goharbor/harbor/issues/14720):

```
Appending internal tls trust CA to ca-bundle ...
find: /etc/harbor/ssl: No such file or directory
Internal tls trust CA appending is Done.
{"Event":"running database migrations","Level":"info","Location":"pgsql.go:216","Time":"2021-07-15 03:27:28.283127"}
{"Event":"database migration ran successfully","Level":"info","Location":"pgsql.go:223","Time":"2021-07-15 03:27:28.285517"}
{"Event":"starting main API","Level":"info","Location":"api.go:52","Time":"2021-07-15 03:27:28.285597","port":6060}
{"Event":"notifier service is disabled","Level":"info","Location":"notifier.go:77","Time":"2021-07-15 03:27:28.285584"}
{"Event":"starting health API","Level":"info","Location":"api.go:85","Time":"2021-07-15 03:27:28.285705","port":6061}
{"Event":"updater service started","Level":"info","Location":"updater.go:83","Time":"2021-07-15 03:27:28.286095","lock identifier":"19af6b97-b4fb-4de6-94f5-33900625050b"}
{"Event":"updating vulnerabilities","Level":"info","Location":"updater.go:192","Time":"2021-07-15 03:37:00.125202"}
{"Event":"fetching vulnerability updates","Level":"info","Location":"updater.go:239","Time":"2021-07-15 03:37:00.125700"}
{"Event":"Start fetching vulnerabilities","Level":"info","Location":"debian.go:63","Time":"2021-07-15 03:37:00.125770","package":"Debian"}
{"Event":"Start fetching vulnerabilities","Level":"info","Location":"rhel.go:92","Time":"2021-07-15 03:37:00.125925","package":"RHEL"}
{"Event":"Start fetching vulnerabilities","Level":"info","Location":"amzn.go:84","Time":"2021-07-15 03:37:00.126289","package":"Amazon Linux 2018.03"}
{"Event":"Start fetching vulnerabilities","Level":"info","Location":"amzn.go:84","Time":"2021-07-15 03:37:00.126296","package":"Amazon Linux 2"}
{"Event":"Start fetching vulnerabilities","Level":"info","Location":"alpine.go:52","Time":"2021-07-15 03:37:00.126336","package":"Alpine"}
{"Event":"Start fetching vulnerabilities","Level":"info","Location":"oracle.go:119","Time":"2021-07-15 03:37:00.126737","package":"Oracle Linux"}
{"Event":"Start fetching vulnerabilities","Level":"info","Location":"ubuntu.go:85","Time":"2021-07-15 03:37:00.126837","package":"Ubuntu"}
{"Event":"finished fetching","Level":"info","Location":"updater.go:253","Time":"2021-07-15 03:37:00.844155","updater name":"alpine"}
{"Event":"finished fetching","Level":"info","Location":"updater.go:253","Time":"2021-07-15 03:37:01.167609","updater name":"amzn2"}
{"Event":"finished fetching","Level":"info","Location":"updater.go:253","Time":"2021-07-15 03:37:01.368121","updater name":"debian"}
{"Event":"could not pull ubuntu-cve-tracker repository","Level":"error","Location":"ubuntu.go:174","Time":"2021-07-15 03:37:01.407383","error":"exit status 128","output":"Cloning into '.'...\nfatal: unable to access 'https://git.launchpad.net/ubuntu-cve-tracker/': The requested URL returned error: 503\n"}
{"Event":"an error occured when fetching update","Level":"error","Location":"updater.go:246","Time":"2021-07-15 03:37:01.407532","error":"could not download requested resource","updater name":"ubuntu"}
{"Event":"finished fetching","Level":"info","Location":"updater.go:253","Time":"2021-07-15 03:37:02.238489","updater name":"amzn1"}
{"Event":"finished fetching","Level":"info","Location":"updater.go:253","Time":"2021-07-15 03:37:02.458890","updater name":"oracle"}
panic: runtime error: slice bounds out of range [25:24]
goroutine 319 [running]:
github.com/quay/clair/v2/ext/vulnsrc/rhel.toFeatureVersions(0xc000de99d0, 0x2, 0xc0050369a0, 0x2, 0x2, 0xc005036870, 0x1, 0x1, 0x2, 0xc0003a1060, ...)
/go/src/github.com/quay/clair/ext/vulnsrc/rhel/rhel.go:276 +0xbf8
github.com/quay/clair/v2/ext/vulnsrc/rhel.parseRHSA(0x7fe2b5144290, 0xc00831e0e0, 0xc00831e0e0, 0x7fe2b5144290, 0xc00831e0e0, 0x43, 0x0)
/go/src/github.com/quay/clair/ext/vulnsrc/rhel/rhel.go:166 +0x1c7
github.com/quay/clair/v2/ext/vulnsrc/rhel.(*updater).Update(0xca4f00, 0x9a1f00, 0xc00019a900, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, ...)
/go/src/github.com/quay/clair/ext/vulnsrc/rhel/rhel.go:133 +0x554
github.com/quay/clair/v2.fetch.func1(0x9a1f00, 0xc00019a900, 0xc00002b2c8, 0xc0002b85a0, 0x8e02a2, 0x4, 0x994ac0, 0xca4f00)
/go/src/github.com/quay/clair/updater.go:243 +0xa5
created by github.com/quay/clair/v2.fetch
/go/src/github.com/quay/clair/updater.go:242 +0x1a9 
```

解决方案, 重新生成一个镜像:

```
$ git clone -b v2.1.6 https://github.com/goharbor/harbor.git --depth 1
$ cd make/photon/clair/
$ ./builder release-2.0
$ cd ../../../
$ docker build -t slzcc/clair-golang:release-2.0 -f make/photon/clair/Dockerfile --build-arg harbor_base_namespace=goharbor --build-arg harbor_base_image_version=v2.1.6 .
```

使用此镜像替换即可。

# v1.21.4.0

Crane 以更新至 1.21.4.0 版本。

# v1.21.5.0

Crane 以更新至 1.21.5.0 版本。

# v1.21.6.0

Crane 以更新至 1.21.6.0 版本。

# v1.21.7.0

Crane 以更新至 1.21.7.0 版本。

# v1.21.8.0

Crane 以更新至 1.21.8.0 版本。

# v1.21.9.0

Crane 以更新至 1.21.9.0 版本。

# v1.21.10.0

Crane 以更新至 1.21.10.0 版本。

# v1.21.11.0

Crane 以更新至 1.21.11.0 版本。

# v1.21.12.0

Crane 以更新至 1.21.12.0 版本。

# v1.21.13.0

Crane 以更新至 1.21.13.0 版本。

# v1.21.14.0

Crane 以更新至 1.21.14.0 版本。