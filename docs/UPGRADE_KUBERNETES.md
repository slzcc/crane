# UPGRADE KBERNETES

> 由于 Crane 在 1.20.x 版本之前的 Upgrade 操作可能存在与当前版本不太一样的地方, 请根据错误出现的提示自行解决。

目前升级集群不会做任何升级 cri 的操作, 这可能造成整个集群出现异常的风险造成不必要的损失。

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

## 执行

执行时是根据所有 `nodes` 定义的各个 实例 对应的角色实行的, 所以信息一定要准确, 否则出现问题无法定位或恢复:

```
$ make run_k8s_upgrade
```