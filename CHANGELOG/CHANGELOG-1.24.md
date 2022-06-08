- [v1.24](#v124)
  - [Updated Instructions](#updated-instructions)
    - [v1.24.0.0 更新内容](#v12400)
    - [v1.24.0.1 更新内容](#v12401)
    - [v1.24.1.0 更新内容](#v12410)
    - [v1.24.1.1 更新内容](#v12411)

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


# v1.24.1.0

Crane 以更新至 1.24.1.0 版本。

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