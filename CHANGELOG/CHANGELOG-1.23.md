- [v1.23](#v123)
  - [Updated Instructions](#updated-instructions)
    - [v1.23.0.0 更新内容](#v12300)
    - [v1.23.0.1 更新内容](#v12301)
    - [v1.23.1.0 更新内容](#v12310)
    - [v1.23.2.0 更新内容](#v12320)
    - [v1.23.2.1 更新内容](#v12321)
    - [v1.23.3.0 更新内容](#v12330)
    - [v1.23.4.0 更新内容](#v12340)
    - [v1.23.4.1 更新内容](#v12341)
    - [v1.23.5.0 更新内容](#v12350)

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

# v1.23.3.0

Crane 以更新至 1.23.3.0 版本。

# v1.23.4.0

Crane 以更新至 1.23.4.0 版本。

# v1.23.4.1

## 升级

升级组件:
  * CNI v0.9.1 => v1.1.0

## 修复

修复 CNI 判断错误导致无法下载 CNI 官方包。

# v1.23.4.2

Crane 以更新至 1.23.4.2 版本。

## 升级

升级组件:
  * Calico v3.20.0 => v3.20.4
  * ingress-nginx 0.33.0 => v1.1.1
  * Haproxy 2.4.2 => 2.5.3
  * CoreDNS 1.8.7 => 1.9.0
  * Etcd 3.4.9 => 3.5.2
  * Cilium v1.10.7 => v1.10.8
  * dockerd 20.10.8 => 20.10.9
  * Jenkins 2.238 => 2.317

## 修复

修复 webmin 没有自定义版本问题。

修复 gitlab 没有自定义版本问题。

修复 Nexus 没有自定义版本问题。

修复 openldap 没有自定义版本问题。

修复 Ingress-nginx 启动项与官方 v1.1.1 版本一致。[详情参照](crane/roles/kubernetes-addons/templates/ingress-nginx/README.md)

修复 Upload 没有自定义版本问题。