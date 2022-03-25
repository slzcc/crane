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
    - [v1.23.4.2 更新内容](#v12342)
    - [v1.23.4.3 更新内容](#v12343)
    - [v1.23.4.4 更新内容](#v12344)
    - [v1.23.4.5 更新内容](#v12345)
    - [v1.23.4.6 更新内容](#v12346)
    - [v1.23.5.0 更新内容](#v12350)
    - [v1.23.5.1 更新内容](#v12351)
    - [v1.23.5.2 更新内容](#v12352)
    - [v1.23.5.3 更新内容](#v12353)

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
  * Cilium v1.10.7 => v1.10.8
  * dockerd 20.10.8 => 20.10.9
  * Jenkins 2.238 => 2.317
  * Harbor 2.1.5 => 2.4.1

## 修复

修复 webmin 没有自定义版本问题。

修复 gitlab 没有自定义版本问题。

修复 Nexus 没有自定义版本问题。

修复 openldap 没有自定义版本问题。

修复 Ingress-nginx 启动项与官方 v1.1.1 版本一致。[详情参照](crane/roles/kubernetes-addons/templates/ingress-nginx/README.md)

修复 Upload 没有自定义版本问题。

部署 Harbor 时移除 clair 服务部署策略, 因已废弃。

# v1.23.4.3

Crane 以更新至 1.23.4.3 版本。

## 修复

修复初始化时, 没有 wget 和 curl 造成的错误。

修复 `openldap-ui` 部署时没有自定义 `namespace` 问题。

添加 `Metrics-Server`, 根据官方配置提供进行修改. [High Availability](https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yaml)


# v1.23.4.4

## 修复

测试发现 20.10.9 dockerd 版本与 Containerd 在一定程度上有兼容问题, 会经常出现:

```
unknown method AddResource for service containerd.services.leases.v1.Leases:
```

类似问题, 已经降级到 20.10.8 版本。

修复部署 k8s 时可能引发低内核的报错。

# v1.23.4.5

Crane 添加到 [Cilium 用户](https://github.com/cilium/cilium/blob/master/USERS.md) 清单中。

修复 1.23 不存在 upgrade 时 1.22 版本的支持.

# v1.23.4.6

## 新增

新增 cilium 1.11.x 版本支持, 1.11.2 已经过测试。

# v1.23.5.0

Crane 以更新至 1.23.5.0 版本。


# v1.23.5.1

Crane 以更新至 1.23.5.1 版本。

## 新增

部署 etcd 时可以部署类型为 systemd, 则通过 systemd 方式部署，默认通过 staticPod 方式进行部署。

systemd 部署的 etcd 目前只能提供部署, 不能提供扩容缩容功能即其他功能。


# v1.23.5.2

Crane 以更新至 1.23.5.2 版本。

## 新增

部署 etcd 时可以选择 external 模式部署, 值为 external 时则使用外部的 etcd 则需要额外配置 tls 和 endpoint 配置项，请通过 crane/roles/etcd-cluster-management/defaults/tls.yaml 进行配置。

当移除集群时，添加判断是否移除 etcd 配置策略可通过 crane/roles/remove-cluster/defaults/main.yml 中的 is_remove_etcd 修改生效。

etcd systemd 方式支持离线安装。


## 修复

修复 cfssl 离线安装时无法正常安装的问题。

修复使用镜像部署时, 不使用最新镜像版本, 加入获取最新镜像。

修复清除集群时, 没有清理 cilium 以及 etcd 二进制文件。

修复 deploy crane status 长期不更新问题。

修复使用 proxy 下载 package 造成的执行命令错误。

修复执行 `make local_load_cri` 时下载过多无用组件。


# v1.23.5.3

Crane 以更新至 1.23.5.3 版本。

## 新增

当不需要 haproxy 时, 可以通过 `crane/group_vars/all.yml` 的 `is_haproxy` 值进行忽略部署, 默认会启用。