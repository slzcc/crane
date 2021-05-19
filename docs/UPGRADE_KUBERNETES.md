# UPGRADE KBERNETES

> 由于 Crane 在 1.20.x 版本之前的 Upgrade 操作可能存在与当前版本不太一样的地方, 请根据错误出现的提示自行解决。

目前升级集群不会做任何升级 cri 的操作, 这可能造成整个集群出现异常的风险造成不必要的损失。

[CRI Install](./CRI_INSTALL.md) 部署方式依赖 CRI 类型的安装, 以便后续维护 离线 或 半离线安装.

## Configure

升级版本是以当前 Crane 部署的版本升级至 `{{ k8s_version }}.{{ build_k8s_version }}` 版本, 请根据需求自定义此版本号, 比如当前版本为:

```
k8s_version: 'v1.18.6'

build_k8s_version: '9'
```

需要升级的版本为:

```
k8s_version: 'v1.20.1'

build_k8s_version: '2'
```

默认是 1.20.x 之前版本中使用 docker 作为 CRI 的则 `cri_k8s_default` 值一定要改为 `docker`。 虽然在一定程度上是可以正常执行的但由于 docker 关闭了 containerd 的部分功能导致使用 ctr 或 crictl 等工具无法正常获取数据可能导致不必要的中断一定要保证升级前后的 cri 属于一致性问题。

```
# 1.20 以前的版本请设为 docker (如果 cri 使用的 docker)
cri_k8s_default: docker
```

升级时 `cri_drive_install_type` 值最好为 `none` 因避免集群中存在 CRI 不一致而导致集群配置信息混乱的问题。

> 但由于 `cri_drive_install_type` 值为 `none`, 则 Kubernetes 的安装默认为 在线 安装, 所以需要通过自身解决科学上网问题。否则查看 [CRI Install](./CRI_INSTALL.md) 解决思路。 

> 升级之前请阅读 Crane 部署的逻辑过程, 以极大程度避免与自身环境不一致遇到的问题造成集群无法正常使用, 虽然在执行所有操作之前都会备份至 `/tmp/crane` 目录中, 但有些执行策略是不可逆的。

## 执行

执行时是根据所有 `nodes` 定义的各个 实例 对应的角色实行的, 所以信息一定要准确, 否则出现问题无法定位或恢复:

```
$ make run_k8s_upgrade
```

## 注意事项

升级前请执行停止调度配置:

```
$ make run_close_schedule
```

升级过程中不会升级 CoreDNS。但会把 CordDNS 配置脚本默认放在 `kube-master[0]` 的 `/tmp/crane/kubernetes-upgrade/` 中。

升级时会更新 kube-proxy, 旧的 kube-proxy 会放在 `kube-master[0]` 的 `/tmp/crane/kubernetes-upgrade/` 中, 以时间戳结尾。

升级时会备份 `/etc/kubernetes` 和 `/var/lib/kubelet` 配置文件到 `/tmp/crane/kubernetes-upgrade/` 中。