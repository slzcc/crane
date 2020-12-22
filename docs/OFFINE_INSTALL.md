## 离线安装

离线安装围绕着 OCI Image 部署方式进行, 当前 docker 以及 containerd 支持标准的镜像导出, 但 crio 当前版本(1.20.0.1)不支持, 其需要通过 crictl 工具对接。

默认 `is_using_local_files_deploy: false`, 当需要离线安装时则改为 `true` 但需要保证 crane/roles/downloads-packages/files 有所需的二进制文件。

> 废弃 is_using_image_deploy 参数：
> 默认 `is_using_image_deploy: true`, 则表示通过 OCI Image 方式部署, 如果为 `false` 并且 `is_using_local_files_deploy: false` 则通过在线下载官方二进制包以及镜像部署(当前版本不会检测当前服务器是否存在相应的文件会直接覆盖), 因是官方下载则可能需要配置 http/https_proxy 的配置项, 请自行解决。

使用离线安装首先准备 CRI 本地文件, 执行命令:

```
$ make local_load_cri
```

> 如果出现网络问题请自行解决.
> 离线 cri 可以通过 `crane/group_vars/all.yml` 中的 `cri_driver` 定义, 默认是全部安装 (docker、containerd、crio), 如需要独立安装, 请执行:
> `make local_load_dockerd` 或 `make local_load_contained` 或 `make local_load_crio`

然后准备 k8s 离线安装文件:

```
$ make local_save_image
```