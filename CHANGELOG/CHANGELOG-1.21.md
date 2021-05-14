- [v1.21](#v121)
  - [Updated Instructions](#updated-instructions)
    - [v1.21.0.0 更新内容](#v12100)
    - [v1.21.0.1 更新内容](#v12101)
    - [v1.21.1.0 更新内容](#v12110)
    - [v1.21.1.1 更新内容](#v12111)

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