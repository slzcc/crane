- [v1.24](#v124)
  - [Updated Instructions](#updated-instructions)
    - [v1.24.0.0 更新内容](#v12400)
    - [v1.24.0.1 更新内容](#v12401)
    - [v1.24.1.0 更新内容](#v12410)
    - [v1.24.1.1 更新内容](#v12411)
    - [v1.24.1.2 更新内容](#v12412)
    - [v1.24.1.3 更新内容](#v12413)
    - [v1.24.2.0 更新内容](#v12420)
    - [v1.24.3.0 更新内容](#v12430)
    - [v1.24.4.0 更新内容](#v12440)
    - [v1.24.5.0 更新内容](#v12450)
    - [v1.24.6.0 更新内容](#v12460)
    - [v1.24.7.0 更新内容](#v12470)
    - [v1.24.8.0 更新内容](#v12480)
    - [v1.24.9.0 更新内容](#v12490)
    - [v1.24.10.0 更新内容](#v124100)
    - [v1.24.11.0 更新内容](#v124110)
    - [v1.24.12.0 更新内容](#v124120)
    - [v1.24.13.0 更新内容](#v124130)

# Updated Instructions

在此版本会重构环境变量参数项统一放在 `group_vars` 内管理。

会对部分 include 文件进行整合, 避免因迭代过程中新添加的文件与老文件放置不统一以及混乱的问题。

# v1.24.0.0

Crane 以更新至 1.24.0.0 版本。

更新组件:
  * cilium 1.10.8 => 1.10.10

# v1.24.1.0

Crane 以更新至 1.24.1.0 版本。

修复部分 apiServer 组件的健康检查不完善问题。


# v1.24.1.1

Crane 以更新至 1.24.1.1 版本。

升级组件:
  * cilium 1.10.11 => 1.11.5 版本。
  * haproxy 2.5.3 => 2.6.0 版本。
  * coredns 1.9.0 => 1.9.3 版本。
  * pause 3.5 => 3.7 版本。

## 修复

修复 cri 安装时 `cri_driver` 选项不能正常生效的问题。

在 99-k8s.conf 内核文件中添加:

```
# 用户 create 文件的数量，默认 128
fs.inotify.max_user_instances = 8192
# inotify队列最大长度，默认值 16384
fs.inotify.max_queued_events = 32768

# 限制进程拥有 VMA 的总数
vm.max_map_count = 524288
```

解决 k8s-ApiServer 因重启可能内核资源不足造成的无法正常启动问题：

```
FATA[0000] failed to create fsnotify watcher: too many open files
```

修复 Etcd 相关文档说明，添加必须保证拥有 docker 才能如期运行。

修改 cri_driver 的值, 目的解决 containerd 为主 docker 为辅, 决绝 containerd 版本问题:

```
cri_driver: ['docker', 'containerd']

=>
cri_driver: ['containerd', 'docker']
```

修复在 `add_node.yml`、`add_etcd.yml`、`add_master.yml`、`remove_etcd_nodes.yml`、`remove_k8s_master.yml`、`remove_k8s_nodes.yml` 添加 nodes 列表判断保护机制，避免因输入 移除 或 新增 IP 池时造成旧数据残留引起的 BUG。

修复移除 etcd 节点时, 无法通过移除的 etcd 节点新增加 etcd 成员。


# v1.24.1.2

Crane 以更新至 1.24.1.2 版本。

升级组件
  * containerd 1.5.8 => 1.6.6
  * cri-o amd64.61748dc51bdf1af367b8a68938dbbc81c593b95d => 1.24.1
  * cilium agent v1.10.x => v1.11.x
  * etcd 3.4.9 => 3.5.3-0

## 修复

修复所有可执行 `*.yml` 文件中的判断 nodes 事件，保证系统稳定可靠且添加部署相关说明文档。

修复 cilium 下载影响的部署效率, 依规定只允许部署在 k8s master 节点中。

解决 Kube-apiServer 报错, 升级 etcd 版本:

```
...
W0609 14:30:50.802569       1 watcher.go:229] watch chan error: etcdserver: mvcc: required revision has been compacted
...
```

修复 containerd 离线安装 pause 版本错误的问题。

修复部分 .md or .yml 文件中的说明描述更新。

移除 nf_conntrack 旧版本的处理配置。

修复之前离线安装文件不统一无法完整执行离线安装的问题。


# v1.24.1.3

Crane 以更新至 1.24.1.3 版本。

升级组件:
  * calico 3.20.5 => 3.23.1
  
## 修复

修复通过 roles 方式部署 k8s-networks 时的异常报错:

```
TASK [cri-install : Install Containerd] ****************************************************************************************************************************************************************************************************************************************
fatal: [10.170.0.3]: FAILED! => {"msg": "The conditional check 'is_mandatory_containerd_install or result.stderr' failed. The error was: error while evaluating conditional (is_mandatory_containerd_install or result.stderr): 'result' is undefined\n\nThe error appears to be in '/root/crane-develop/crane/roles/cri-install/includes/containerd/main.yml': line 10, column 3, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n- name: Install Containerd\n  ^ here\n"}
...ignoring
```

修复因执行命令等待时间过长问题, 目前在文件: `crane/roles/kubernetes-cluster-management/includes/initialize-cluster-rbac.yaml` 中进行试验阶段, 当 `600` or `300` 秒中任务没有正常完成则中断整个执行。


# v1.24.2.0

Crane 以更新至 1.24.2.0 版本。


# v1.24.3.0

Crane 以更新至 1.24.3.0 版本。

# v1.24.4.0

Crane 以更新至 1.24.4.0 版本。

# v1.24.5.0

Crane 以更新至 1.24.5.0 版本。

# v1.24.6.0

Crane 以更新至 1.24.6.0 版本。

# v1.24.7.0

Crane 以更新至 1.24.7.0 版本。

# v1.24.8.0

Crane 以更新至 1.24.8.0 版本。

# v1.24.9.0

Crane 以更新至 1.24.9.0 版本。

# v1.24.10.0

Crane 以更新至 1.24.10.0 版本。

# v1.24.11.0

Crane 以更新至 1.24.11.0 版本。

# v1.24.12.0

Crane 以更新至 1.24.12.0 版本。

# v1.24.13.0

Crane 以更新至 1.24.13.0 版本。