# 离线安装

Crane 的离线安装与普通的离线安装有独特之处, 实际上 Crane 的离线安装与默认安装的差异很小, 因为 Crane 部署的 Kubernetes 使用 kubelet 的 StatusPod 模式启动所需的 Master 各个组件, 则都会通过镜像的方式启动则 Crane 默认会把 Kubernetes、Etcd、Haproxy、Calico、Keepalived 等镜像打包成一个镜像[更多请参照](../script/PublishK8sRegistryImages.sh)并放置到 docker.io 中, 这样既可以使用 docker 也可以使用 containerd 方式部署。(crio 目前还不支持)

Crane 的离线安装分两部分:
  * cri
  * kubernetes

区分两部分的原因是可以独立通过 ansible 特性在某些机器上独立安装 cri .

> 离线安装的本质是把包文件下载到 ansible 执行节点, 通过 ansible 执行节点传输到各个被操作节点中.

### CRI install

> 默认 Crane 安装 CRI 属于在线安装。

离线安装围绕着 OCI Image 部署方式进行, 当前 docker 以及 containerd 支持标准的镜像导出, 但 crio 当前版本(1.20.0.1)不支持, 其需要通过 crictl 工具对接。

默认 `is_using_local_files_deploy: false`, 当需要离线安装时则改为 `true` 但需要保证 crane/roles/downloads-packages/files 有所需的二进制文件。

使用离线安装首先准备 CRI 本地文件, 执行命令:

```
$ make local_load_cri
```

然后修改参数:

```
@crane/group_vars/all.yml

cri_drive_install_type: 'local_binary'
```

> 如果 cri_drive_install_type 的值为 'none' 则不安装任何 cri。 同时 kubernetes 由半离线安装转为在线安装。

> 离线 cri 可以通过 `crane/group_vars/all.yml` 中的 `cri_driver` 定义, 默认是全部安装 (docker、containerd、crio), 如需要独立安装, 请执行:

> `make local_load_dockerd` 或 `make local_load_contained` 或 `make local_load_crio`

### Kubernetes install

> 默认 Crane 安装 Kubernetes 属于半离线安装。

准备 k8s 离线安装文件:

```
$ make local_save_image
```

然后修改参数:

```
@crane/group_vars/all.yml

is_using_local_files_deploy: true
```

其他配置项请参考 [Crane Install](./INSTALL.md) 解决。