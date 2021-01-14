# CRI INSTALL

> 由于官方明确说明会在后续版本(不包含当前 v1.20.x 版本)中舍弃 docker 类型 CRI, 并推荐使用 containerd 和 crio(目前不成熟).

> 在 Crane v1.20.x 中默认安装这三种 CRI 的驱动, 可根据自身需求修改 CRI 的类型安装.

# Configure

各重点配置项说明.

### cri_drive_install_type

Crane 属于半离线安装, 但 CRI 与 kubernetes 是分开安装的, 半离线或离线安装是完全依赖于 CRI 的 `cri_drive_install_type` 是区分 CRI 的安装方式.

CRI 有两种安装方式:
  * 离线  ('local_binary')      
  * 在线  ('http_binary')
  * 忽略  ('none')

CRI 默认是 在线 安装, 并通过官方 github 或官方 storage 等地址进行二进制包的下载, 如果因自身网络问题等因素问题造成的无法下载, 可以通过梯子或 Crane 中 Http_Proxy 参数进行解决.

如果需要离线安装则修改配置项:

```
cri_drive_install_type: 'local_binary'
```

本地准备 CRI 二进制包文件, 执行命令:

```
$ make local_load_cri
```

> 此配置会把 docker/containerd/crio 都在下载到本地, 如修改了 `cri_driver` 请根据 `Makefile` 中执行所需命令:

> ```
> $ local_load_crio
> $ local_load_containerd
> $ local_load_dockerd
> ```

> 注意: 如果独立安装 CRI 首先需要执行 local_load_runc 在执行相应的本地下载, 因所有组件都依赖 runc。

如果值为 `none` 则会忽略安装 CRI, 但需要保证被操作的 实例 节点中已经安装所需的 CRI（如 docker）, 在 Kubernetes v1.20.x 以上（包含 v1.20）版本中, kubelet 的默认 CRI 还是 docker。

值为 `none` 时 Crane 默认不会修改 kubelet CRI 配置, 但如果被操作的 实例 节点没有使用 docker 而是使用的 containerd（crio v1.19.0 目前在 v1.20.x 中还不成熟, 并且不支持离线 OCI 方式安装, 不建议使用）CRI, 则需要修改 `@crane/roles/downloads-packages/defaults/main.yml => is_crane_kubernetes_deploy` 为 `crane` 或任意其他值(只有不等于 none 即可)。

一旦此值为 `none` 时, Kubernetes 的安装及不可以使用 离线 安装也不可以使用 半离线安装, 它会通过官方 Github 下载 kubernetes-node 包安装到被操作 实例 节点中.

> docker 默认是基于 containerd 的 runC 启动容器的, 但 docker 的启动的 containerd 是属于阉割配置, 部分功能无法正常使用, 如 crictl 和 ctl 等工具无法正常使用, 需要修改 containerd 的配置文件后重启才可以生效, 一旦重启 containerd 则容器会全部崩溃。

### cri_k8s_default

Crane 的安装是依赖于 CRI 的类型的, 所以 `cri_k8s_default` 是基于哪种 CRI 离线或半离线安装 Kubernetes 的依据。

此值可以是:
  * docker
  * containerd
  * crio

> 不建议使用 crio, 并且不支持半/离线安装.

如果修改了 `cri_drive_install_type` 为 `none` ,则根据需要修改 `@crane/roles/downloads-packages/defaults/main.yml => is_crane_kubernetes_deploy` 为 `crane` 或任意其他值(只有不等于 none 即可), 此时离线安装会根据 `cri_k8s_default` 的值对应进行离线安装, 并且 kubelet 的 cri 会根据 `cri_k8s_default` 进行修改。

### cri_driver

此值主要是安装那些 CRI 驱动, 默认全部安装 `["docker", "containerd", "crio"]` 配置比较灵活, 如果只选 `docker` 则 `cri_k8s_default` 值为 `containerd` 也是可以正常安装的.

> 值可以是任意其中多个或一个, 如果值为 `crio` 则使用在线方式安装。

# CRI install

CRI 可以独立安装, 它基于 `nodes` 文件使用 all 方式进行安装, 所以不需要安装的可以注释掉, 执行如下命令可以进行安装, 它所需的配置项完全基于 Crane 模式:

```
$ make run_main_cri
```

# 重点说明

docker 默认集成 containerd, 如果不是通过 Crane 安装的 Docker, 则使用 Containerd 可能会造成冲突问题(后续版本会优化), 所以默认的 CRI 可以修改为 docker 继续使用, 或卸载自定义安装 docker.

> 如果默认使用 docker 则升级版本中使用了 containerd 进行部署, 则会引发 ctr 等命令无法正常使用造成过程失败报错退出的问题, 严重可能影响集群使用, 所以执行时一定要进行检测。
> ctr 不可用是因为 docker 附带的 containerd 的配置文件中关闭了绝大部分功能造成的, 如果需要使用 ctr 删除 `/etc/containerd/config.toml => disabled_plugins = ["cri"]` 重启 containerd 生效.

# Cri-Tools

安装 CRI 时会默认安装 Cri-Tools 工具, 如:
  * crictl

它会根据 `cri_k8s_default` 判断使用 cri 驱动类型定义配置文件.