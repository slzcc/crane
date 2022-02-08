- [v1.23](#v123)
  - [Updated Instructions](#updated-instructions)
    - [v1.23.0.0 更新内容](#v12300)
    - [v1.23.0.1 更新内容](#v12301)
    - [v1.23.1.0 更新内容](#v12310)
    - [v1.23.2.0 更新内容](#v12320)
    - [v1.23.2.1 更新内容](#v12321)

# v1.23.0.0

Crane 以更新至 1.23.0.0 版本。

# v1.23.0.1

修复部分字符串使用单引号 `'`.

修复 crane 工具可以安装 cri.

# v1.23.1.0

Crane 以更新至 1.23.1.0 版本。

# v1.23.2.0

## 更新

修复加载 main.yaml 时，初始化 docker 时 include 会出现报错的问题。

修复 harbor Ingress 即其他新版不支持 `extensions/v1beta1` 问题。

默认 `general_network_drive` 值为 `cilium`, 默认值不再是 `calico`。

## 升级

组件升级:
  * cilium v1.10.4 => v1.10.7
  * coredns v1.8.4 => v1.8.7

# v1.23.2.1

## 升级

升级组件:
  * cri-o v1.21.2 => amd64.61748dc51bdf1af367b8a68938dbbc81c593b95d
  * cri-tool v1.22.0 => v1.23.0
  * containerd 1.5.5 => 1.5.8
  * runc 1.0.0 => 1.1.0

## 修复

修复使用 cri-o 时，由于 cri-o 目录错误导致的安装失败。