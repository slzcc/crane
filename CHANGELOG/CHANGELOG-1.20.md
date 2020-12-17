- [v1.20.0.0](#v11900)
  - [Updated Instructions](#updated-instructions)
    - [v1.20.0.0 更新内容](#v12000-更新内容)
    - [v1.20.0.1 更新内容](#v12001-更新内容)

# v1.20.0.0

Crane 以更新至 1.20.0.0 版本。

Update 各组件版本:
  * kubernetes 1.19.4 => [1.20.0](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md)
  * kubernetes cni 0.8.6 => [0.8.7](https://github.com/containernetworking/plugins/releases/tag/v0.8.7)
  * docker 19.03.12 => [20.10.0](https://github.com/docker/docker-ce/blob/master/CHANGELOG.md#20100)
  * etcd 3.4.7 => [3.4.9](https://github.com/etcd-io/etcd/blob/master/CHANGELOG-3.4.md)
  * haproxy 2.2.0 => [2.3.2](http://www.haproxy.org/download/2.3/src/CHANGELOG)
  * calico 3.15.1 => [3.17.0](https://docs.projectcalico.org/v3.17/release-notes/)
  * coredns 1.7.0 => [1.8.0](https://coredns.io/2020/10/22/coredns-1.8.0-release/)

kubernetes 1.20.0 升级之前请先阅读: [Urgent Upgrade Notes](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.20.md#urgent-upgrade-notes)

Docker Install 同步官方: https://download.docker.com/linux/static/stable/x86_64/
> 不再使用 https://mirror.shileizcc.com/Docker/bin/ 此地址由个人维护可能出现不必要的问题。

修改 Dockerd 安装步骤:

```
- name: Get Docker Binary File
  shell: "export http_proxy={{ http_proxy }} ; export https_proxy={{ https_proxy }} ; wget -qO- '{{ docker_install_http_binary_source }}/docker-{{ docker_version }}.tar.gz' | tar zx -C {{ docker_ctl_path }}"

=>

- name: Stop DockerD
  service:
    name: "{{ item }}"
    state: stopd
  ignore_errors: true
  when: is_mandatory_docker_install
  with_items:
    - "docker"
    - "containerd"

- name: Get Docker Binary File
  shell: "export http_proxy={{ http_proxy }} ; export https_proxy={{ https_proxy }} ; wget -qO- '{{ docker_install_http_binary_source }}/docker-{{ docker_version }}.tgz' | tar zx -C {{ temporary_dirs }}"

- name: Copy Dockerd to bin Path
  shell: "cp -a {{ temporary_dirs }}docker/* {{ docker_ctl_path }}"
```

修改 Systemd Containerd.service Configure：
```
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin//containerd
KillMode=process
Delegate=yes
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target

=>

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStartPre=/sbin/modprobe br_netfilter
ExecStart={{ docker_ctl_path }}containerd
Restart=always
RestartSec=5
KillMode=process
OOMScoreAdjust=-999
Delegate=yes
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target

```

修改临时目录:

```
temporary_dirs: '/tmp/'
 
 =>

temporary_dirs: '/tmp/crane/'
```

添加临时目录创建策略:

```
@crane/roles/system-initialize/tasks/main.yml +14

- name: Create Temporary Directory
  file:
    path: "{{ temporary_dirs }}"
    mode: 0755
    owner: "{{ ssh_connect_user }}"
    state: directory
```

[Calico Release 配置文件](https://docs.projectcalico.org/manifests/calico.yaml)

# v1.20.0.1

因 Kubernetes 在后续版本中会删除 [Docker](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/) 的支持, 特进行其他 CRI(container runtime interface) 的补充.[Dockershim 弃用说明](https://kubernetes.io/blog/2020/12/02/dockershim-faq/)

## v1.20.0.1 属于重大更新

v1.20.0.1 属于重大更新修改了相当于重构了 1/3 的部署逻辑, 实现逻辑没有变动但把所有的逻辑顺序进行的合理的拆分.

添加以下支持:
  * CRIO
  * Containerd

1.20.0.1 最大的改动是把 docker 移动到了 cri 中, cri 默认安装 docker, 并且把 `--tags docker` 改为 `--tags cri` 需要变更 cri 类型时则通过 crane/group_vars/all.yml 中修改 `cri_driver` 实现.

> 不建议使用 1.20.0.1 之前的版本管理 Crane 集群 CRI 的驱动, 因为如 docker、Containerd 的二进制文件已经从默认的 /usr/bin/ 改为 /usr/local/bin/ 目的是为了更好的管理, 如果不涉及到 cri 请忽略此说明.

修改 cri 另外一个变动比较大的是支持离线安装部分, 因穿插了 `cri-o` 和 `containerd` 则离线安装就变得异常复杂, 目前虽然已经做到可动态调整 `version` 适配部署, 但如果一旦源码产生包文件不一致则会造成某些功能的损失, 又配置文件属于 `templates` 模式则可能存在部分差异, 后续可能围绕此问题进行不向后兼容配置.

cri 支持多种驱动共同部署, 可通过 `cri_k8s_default` 指定 k8s 默认 cri 驱动.

Docker 的安装去掉了 http_script 方式安装, 维护成本较高.

精简 crane/group_vars/all.yml 配置, 各配置项移动至各项目 defaults 中。
> 精简比例从大概 500 行配置, 精简至 130 +

目前主要解决了之前 download 部分的不统一问题, 由于 crane 部署使用了 image 方式进行属于半离线安装, 可能造成一部分的差异化.

废弃 `is_using_image_deploy` 参数.