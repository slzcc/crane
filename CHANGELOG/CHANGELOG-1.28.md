- [v1.28](#v128)
  - [Updated Instructions](#updated-instructions)
    - [v1.28.0.0 更新内容](#v12800)


# Updated Instructions

# v1.28.0.0

Crane 以更新至 1.28.0.0 版本。

更新组件:
  * cni v1.2.0 > 1.3.0
  * coredns 1.10.0 > 1.11.1
  * haproxy 2.6.6 > 2.8.2
  * cilium 1.3.5 > 1.4.1
  * etcd 3.5.5-0 > 3.5.9-0
  * containerd 1.6.9 > 1.6.23
  * cri-docker 0.3.1 > 0.3.4
  * cri-tools 1.25.0 > 1.28.0
  * crio 1.25.1 > 1.26.4
  * docker 20.10.18 > 23.0.6
  * runC 1.1.4 > 1.1.9
  * pause 3.7 > 3.9

从 1.28.0 版本开始, 修改 `cri_k8s_default` 使用 docker 为默认 cri, 因使用太不习惯, 如果有特殊需求使用前修改 `cri_k8s_default`。

# v1.28.0.1

升级 cilium 客户端二进制文件为 1.14.1。

