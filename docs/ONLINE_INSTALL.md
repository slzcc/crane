# 在线安装

因 Crane 默认属于半离线安装, 所以可能存在部分使用者之间使用在线方式进行安装, 它比半离线安装在部署速度上更快(只限于海外服务器第一次部署时)。

Crane 的离线安装分两部分:
  * cri
  * kubernetes

区分两部分的原因是可以独立通过 ansible 特性在某些机器上独立安装 cri .

> 离线安装的本质是把包文件下载到 ansible 执行节点, 通过 ansible 执行节点传输到各个被操作节点中.

### CRI install

> 默认 Crane 安装 CRI 属于在线安装。

安装 CRI 都是通过官方 Github 等提供的地址直接下载, 如果有 Proxy 请在 `@crane/group_vars/all.yml` 中添加 Proxy 解决。

修改参数:

```
@crane/group_vars/all.yml

cri_drive_install_type: 'http_binary'
```

> 如果 cri_drive_install_type 的值为 'none' 则不安装任何 cri。 同时 kubernetes 由半离线安装转为在线安装。

> 离线 cri 可以通过 `crane/group_vars/all.yml` 中的 `cri_driver` 定义, 默认是全部安装 (docker、containerd、crio).


### Kubernetes install

> 默认 Crane 安装 Kubernetes 属于半离线安装。

修改参数:

```
@crane/roles/crane/defaults/main.yml

is_crane_kubernetes_deploy: 'none'
```

其他配置项请参考 [Crane Install](./INSTALL.md) 解决。