- [v1.20](#v120)
  - [Updated Instructions](#updated-instructions)
    - [v1.20.0.0 更新内容](#v12000)
    - [v1.20.0.1 更新内容](#v12001)
    - [v1.20.1.0 更新内容](#v12010)
    - [v1.20.1.1 更新内容](#v12011)
    - [v1.20.1.2 更新内容](#v12012)
    - [v1.20.1.3 更新内容](#v12013)
    - [v1.20.1.4 更新内容](#v12014)
    - [v1.20.1.5 更新内容](#v12015)
    - [v1.20.1.6 更新内容](#v12016)
    - [v1.20.1.7 更新内容](#v12017)
    - [v1.20.1.8 更新内容](#v12018)
    - [v1.20.1.9 更新内容](#v12019)
    - [v1.20.2.0 更新内容](#v12020)

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

精简 crane/group_vars/all.yml 配置, 各配置项移动至各项目 defaults 中。
> 精简比例从大概 500 行配置, 精简至 130 +

目前主要解决了之前 download 部分的不统一问题, 由于 crane 部署使用了 image 方式进行属于半离线安装, 可能造成一部分的差异化.

废弃 `is_using_image_deploy` 参数.

## 可使用的入口配置

因 Crane 变动比较大, 默认 Crane 的 CRI 驱动已经改为 Containerd, 所以部分功能无法直接使用, 请参考后续版本的支持, 目前以基于 Containerd 可正常提供使用的功能如下:
  * main.yml
  * add_master.yml
  * add_nodes.yml
  * remove_k8s_nodes.yml
  * remove_cluster.yml

其他版本可在 docker cri 中正常使用, 目前不可在 Container cri 中使用。

## CRI

因使用 Containerd 的 CRI, 使用时命令行工具等配置会无法直接获取数据的问题, 默认会安装 `docker`、`containerd`、`crio` 3 种 cri 其中 containerd 为 kubernetes 的默认 cri, crio 附带 crictl 工具可以直接操作 containerd, 类似 docker 的命令, 但由于 `containerd` 和 `crio` 只是容器管理服务不支持 镜像的构建 则还是需要 `docker build` 的继续使用, 所以三者是互补状况, 目前不影响正常使用.

修改 cri 另外一个变动比较大的是支持离线安装部分, 因穿插了 `cri-o` 和 `containerd` 则离线安装就变得异常复杂, 目前虽然已经做到可动态调整 `version` 适配部署, 但如果一旦源码产生包文件不一致则会造成某些功能的损失, 又配置文件属于 `templates` 模式则可能存在部分差异, 后续可能围绕此问题进行不向后兼容配置.

cri 支持多种驱动共同部署, 可通过 `cri_k8s_default` 指定 k8s 默认 cri 驱动.

Docker 的安装去掉了 http_script 方式安装, 维护成本较高.

# v1.20.1.0

Crane 以更新至 1.20.1.0 版本。

# v1.20.1.1

修复:

```
@crane/roles/downloads-packages/includes/kubernetes/main.yml 中 is_using_local_files_deploy 判断问题, 此问题可能会导致离线在线安装混乱问题

  when: not is_using_local_files_deploy
```

添加:

```
@crane/group_vars/all.yml 新添加 cri_drive_install_type 中的 none 参数

cri_drive_install_type: 'none'
```

> 如果为 `none` 则不会安装 cri, kubelet 会走默认 cri 配置项。

```
@crane/roles/downloads-packages/includes/crane/crane_none.yaml 新添加 is_crane_kubernetes_deploy 参数

# 当不安装 cri 时, 则默认关闭 crane 半离线安装方式
# 此值默认同 cri_drive_install_type 一致, 值为 none 则判断不使用 crane 部署方式, 任意值都会忽略
is_crane_kubernetes_deploy: "{{ cri_drive_install_type }}"
```

> 主要解决不使用 crane 部署问题。

添加 .dockerignore 文件, 解决 Crane 发布时忽略本地大文件。

添加 `crane/roles/crane/templates/` 部分 tools 脚本, 用于手动部署。

```
@crane/roles/kubernetes-cluster-management/vars/kubelet.yaml 新添加 --resolv-conf 参数项

# resolv 配置项
kubelet_resolv_config: "--resolv-conf=/run/systemd/resolve/resolv.conf"

修复名称错误:
kubectl_gc_options => kubelet_gc_options
```

添加 Clean Cluster 时, 部分配置移动到临时数据目录中:

```
* => {{ temporary_dirs }}remove-cluster
```

清理集群时, 补充遗漏的 docker 二进制文件的清理:

```
@crane/roles/remove-cluster/includes/docker/main.yaml

# Clean Docker Binary
- name: Clean Docker Binary
  include: "roles/remove-cluster/includes/docker/binary.yaml"
  when: is_remove_all or is_remove_docker_ce
```

清理集群时, 默认 is_remove_all 选项为 true:

```
@crane/roles/remove-cluster/defaults/main.yml

# 此选项会忽略下面所有配置项
# 主要目的是恢复安装 Crane 涉及到所有组件之前的状况
# 如果此值为 false 它会清除 k8s Cluster 绝大部分数据, 方便下一次部署时避免重复安装如 kubelet、docker 等
is_remove_all: true
```

> 主要考虑初次使用的用户无法正常删除部分数据.

# v1.20.1.2

### 修复

修复如果值为 none 则 kubelet runtime 的配置走默认 cri.

```
@crane/roles/cri-install/vars/kubelet.yaml 

kubelet_containerd_cri_options: >-
  {% if cri_drive_install_type == 'none' %}
  {% elif cri_k8s_default == 'crio' %}
  --container-runtime=remote --container-runtime-endpoint=unix://{{ crio_socket_path }}
  {%- elif cri_k8s_default == "containerd" -%}
  --container-runtime=remote --container-runtime-endpoint=unix://{{ containerd_socket_path }}
  {% endif %}
```

修复 etcd_del_nodes 中存在无法获取 node 节点信息而导致的删除失败的问题。

```
@crane/roles/etcd-del-node/tasks/main.yml

- name: Delete Etcd Cluster Nodes
  shell: >
    echo -e "{{ result['stdout'] }}" | grep '{{ item[0] }}' | awk -F, '{print $1}' | xargs -i {{ kubernetes_ctl_path }}docker run --rm -i -v {{ etcd_ssl_dirs }}:{{ etcd_ssl_dirs }} -w {{ etcd_ssl_dirs }} {{ k8s_cluster_component_registry }}/etcd:{{ etcd_version }} etcdctl --cacert {{ etcd_ssl_dirs }}etcd-ca.pem --key {{ etcd_ssl_dirs }}etcd-key.pem --cert {{ etcd_ssl_dirs }}etcd.pem --endpoints {{ etcd_cluster_str }} member remove {}
  with_nested:
    - "{{ etcd_del_node_ip_list }}"
    - "-"
```

修复 etcd_add_nodes 中更新 Calico 的 Etcd Config:

```
@add_etcd.yml

- name: Update K8s Cluster Calico Network Config
  hosts: kube-master
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/crane/defaults/main.yml"
    - "roles/downloads-ssh-key/defaults/main.yml"
    - "roles/kubernetes-manifests/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
    - "roles/etcd-cluster-management/vars/main.yml"
    - "roles/kubernetes-networks/defaults/calico.yaml"
    - "roles/kubernetes-networks/defaults/main.yml"
  tasks:
    - { include: 'roles/etcd-add-node/includes/update-k8s-calico.yml' }
```

因可能会存在多次执行的问题, 但不影响使用。

> etcd_add_nodes 时需要保证 etcd 节点数在 2 个以上。

修复所有 retation 错别字 => rotation .

修复 etcd_certificate_rotation 在 containerd 下的变更问题, 如果在 containerd 下则变更必须使用 crictl 执行, 否则会报错。

### 优化

Ansible for Docker 使用 `alpine` 底层镜像, 镜像缩减至 202M+, 之前 `ubuntu` 底层镜像构建出的大小可能在 390M+ 。

> Ansible 升级 2.8 => 2.9.14.

### 可使用的入口配置

因 Crane 变动比较大, 默认 Crane 的 CRI 驱动已经改为 Containerd, 所以部分功能无法直接使用, 请参考后续版本的支持, 目前以基于 Containerd 可正常提供使用的功能如下:
  * remove_etcd_nodes.yml
  * add_etcd.yml
  * etcd_certificate_rotation.yml
  * k8s_certificate_rotation.yml

### 升级

Containerd 1.3.9 => 1.4.3。`@crane/roles/cri-install/vars/containerd.yaml`

# v1.20.1.3

## v1.20.1.3 有重大 BUG, 请使用后续版本, 此版本只标记修改过程内容的存在

此版本主要修复了 v1.20.x 版本中 Upgrade 与之前版本不兼容的问题, 因 cri 不一致可能存在的命令不一致报错问题。

> 目前版本不支持动态感知 cri, 但后续版本会进行添加.


### 文档

添加或修复文档说明:
  * docs/REMOVE_CLUSTER.md
  * docs/UPGRADE_KUBERNETES.md


### 可使用的入口配置

因 Crane 变动比较大, 默认 Crane 的 CRI 驱动已经改为 Containerd, 所以部分功能无法直接使用, 请参考后续版本的支持, 目前以基于 Containerd 可正常提供使用的功能如下:
  * upgrade_version.yml


### 增加

新增 Crane 部署的版本信息, 主要保证向后兼容的问题.

### 修复 

补之前发布的 v1.20.1.3 版本中还残留 `temporary.yaml` 执行文件, 对其进行销毁。

# v1.20.1.4

### 修复

修复 `@crane/upgrade_version.yml` 中遗漏的配置项:

```
- name: Update Kubernetes Cluster Networks
  hosts: kube-master[0]
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/crane/defaults/main.yml"
    - "roles/downloads-ssh-key/defaults/main.yml"
    - "roles/kubernetes-manifests/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
    - "roles/etcd-cluster-management/vars/main.yml"
    - "roles/kubernetes-networks/defaults/calico.yaml"
    - "roles/kubernetes-networks/defaults/main.yml"
+/+    
    - "roles/kubernetes-upgrade/defaults/main.yml"
+/+
  tasks:
    - { include: 'roles/kubernetes-upgrade/includes/update-k8s-networks.yaml' }

删除: 重叠的配置项, 会造成 bug 阻塞
-/-
- name: Initialize Update Kubernetes Cluster Operation
  hosts: kube-master[0]
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/crane/defaults/main.yml"
    - "roles/downloads-ssh-key/defaults/main.yml"
    - "roles/kubernetes-manifests/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
    - "roles/etcd-cluster-management/vars/main.yml"
    - "roles/kubernetes-networks/defaults/calico.yaml"
    - "roles/kubernetes-networks/defaults/main.yml"
    - "roles/kubernetes-upgrade/defaults/main.yml"
  tasks:
    - { include: 'roles/kubernetes-upgrade/includes/update-k8s-networks.yaml' }
-/-
```

修复 `crane/roles/cri-install/vars/docker.yaml => ```
` 的配置项, 此值是个人测试时未及时修改的问题。

```
is_mandatory_docker_install: true => false
```

修复清除 docker 时, 各组件顺序执行造成的报错问题。

修复 v1.20.1.2/3 测试时修改的 etcd.j2 文件造成 etcd 无法正常启动的 BUG:

```
@crane/roles/etcd-cluster-management/templates/etcd.j2
    - --initial-cluster-state=existing
=>
    - --initial-cluster-state=new
```

修复 containerd 启动容器删除不干净的问题。

### 优化

Containerd 可以通过 `is_mandatory_containerd_install` 参数强制安装 containerd. 强制安装可以解决 docker 默认安装 containerd 无法直接使用的问题, 但会暂存 docker 启动的服务不可用.

老版本的 docker 安装默认安装在 `/usr/bin` 与 Crane 的默认安装目录 `/usr/local/bin` 有不一样的地方, 目前已经添加 `@crane/roles/remove-cluster/defaults/main.yml => is_remove_not_crane_docker_ce` 参数, 在清除集群时, 可以清除非 Crane 安装的 docker.


### 增加

可以直接通过 crio 在线方式部署。


# v1.20.1.5

此版本对 CRI 独立安装及组合安装进行了多方面的测试.

### 修复

解决独立使用 Containerd 作为 CRI 时没有 runC 的问题.

runC 没有执行权限。

使用 CRIO 时没有配置 containers 配置文件操作的 crio 无法正常使用.

修复 crane/upgrade_version.yml 重复初始化 Crane 的配置项.

### 优化

优化判断 crio 作为 CRI 时判断不严谨的问题。

卸载 CNI 时一同清理 var/lib 目录。

优化重复测试执行时会造成大量 rc.local 重复数据注入的问题。

### 增加

安装 CRI 时 runC 独立安装, 并清除集群时独立删除 runC.

# v1.20.1.6

### 修复

修复 Crane Tools 脚本名称不统一问题。

修复 Github Actions Deploy Testing..

修复 Etcd CA 轮转时使用 kube-cluster[1] 作为 hosts 操作节点。

### 优化

如果本地存在 docker 则会默认检查并软连接到 /usr/local/bin 下.

在 Makefile 优化具有与迷惑性的配置。

docker 可以安装时区分 17/18/19/20 版本放置不同的 binray 文件。

> 但安装时一定要保证旧的 docker 通过 Crane 或自定义删除掉。

清除 Calico 时, 清除 设备和 route 。

### 增加

安装 docker 时是否先清除旧的 dockerd, 通过 `clean_up_old_before_installing` 参数判断。

卸载 docker 时清除 mount 驱动。

安装 docker 时通过 `is_docker_install_close_kubelet` 参数判断, 是否关闭当前 kubelet 以便安装 docker（这里属于强制安装）时存在脏数据无法启动成功的问题。

# v1.20.1.7

### 优化

对 k8s-del-nodes 和 kubernetes-upgrade 增加停止集群调度以及排除 node 等操作.

etcd-add-node 和 etcd-del-node 重命名 xx.nodes

### 修复

各 Tasks 中可能存在遗漏创建临时操作目录的配置, 造成无法继续执行.

删除 Etcd 节点后, 遗漏的 Etcd 启动文件进行删除.

清除 k8s node 时 遗漏配置:

```
@crane/remove_k8s_nodes.yml

- name: Clean Kubernetes Nodes DataDir
  hosts: k8s-cluster-del-node
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/crane/defaults/main.yml"
    - "roles/system-initialize/defaults/main.yml"
    - "roles/kubernetes-networks/defaults/main.yml"
    - "roles/kubernetes-manifests/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
+/+
    - "roles/downloads-ssh-key/defaults/main.yml"
+/+
  roles:
    - { role: remove-cluster, tags: [clean]}
```

修复删除 node 时, 安装 jq 时没有正常安装, 造成后续删除节点失败。

修复增加 Master 时 Haproxy etc 目录没有存在的问题。

修复 kubelet 生成的 kubelet.conf 具有 root 权限, 造成升级 Master 时无法进行修改的问题。

### 增加

因增加 cordon 和 drain 修改的执行过程:

```
@crane/roles/k8s-del-nodes/tasks/main.yml
- name: Delete Kubernetes Cluster Nodes
  shell: >
    export DELETE_NONE=`{{ kubernetes_ctl_path }}kubectl get node -o json | jq '.items[].status.addresses'| jq '{IP:.[0].address,HOSTNAME:.[1].address}' -c | jq '. | select(.IP | contains("{{ item[0] }}"))' | jq --raw-output .HOSTNAME`
    {{ kubernetes_ctl_path }}kubectl cordon $DELETE_NONE
    {{ kubernetes_ctl_path }}kubectl drain $DELETE_NONE --force --ignore-daemonsets --delete-local-data
    sleep 12
    {{ kubernetes_ctl_path }}kubectl delete node $$DELETE_NONE
  with_nested:
    - "{{ k8s_del_node_ip_list }}"
    - "-"
  ignore_errors: true
```

# v1.20.1.8

> 当前版本没有正式发版

### 优化 

因资源的增加对默认的 nf_conntrack 配置修改为如下:


```
kernel_nf_conntrack_buckets: 262144
kernel_nf_conntrack_max: 1048576

=>

kernel_nf_conntrack_buckets: 1048576
kernel_nf_conntrack_max: 4194304
```

> nf_conntrack https://opengers.github.io/openstack/openstack-base-netfilter-framework-overview/

对 nf_conntrack_buckets 开机启动不在写入 rc.local 配置为 modprobe.d 模式启动。


### 修复

修复 删除 etcd 节点时，只更新一个 k8s master 节点的 etcd 配置，并修复使用了 etcd-add-nodes 的配置项。

```
@crane/remove_etcd_nodes.yml

- name: Set Kubernetes Cluster Etcd Config
  hosts: kube-master[0] => hosts: kube-master
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/downloads-ssh-key/defaults/main.yml"
    - "roles/crane/defaults/main.yml"
    - "roles/kubernetes-manifests/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
    - "roles/etcd-cluster-management/vars/main.yml"
  tasks:
    - { include: 'roles/etcd-del-nodes/includes/update-k8s-manifests.yml' } => - { include: 'roles/etcd-add-nodes/includes/update-k8s-manifests.yml' }
...
```

> 主要问题出在 etcd.j2 文件使用 etcd-cluster, 在 etcd-del-nodes 时不适用。

修复 add etcd node 时可能存在的重复执行步骤。

修复放入 Crane 临时目录时部分文件过乱的问题。


### 移除

将部分 addons 进行了移除, 一部分以因为无法跟进时代潮流, 另一部分是没有过多精力维护, 项目配置项在 1.2x 中不会移除, 但对 `@crane/roles/kubernetes-addons/defaults/main.yml` 入口文件进行了移除。

### 增加

对 Harbor 支持 CA Rotation 只需要对 `@crane/roles/kubernetes-addons/defaults/main.yml => is_harbor_ca_rotation` 值为 `true` 即可, 它会抑制 harbor 安装只会更新当前 harbor ca 证书。

### 调整

在此版本后对 Master 与 Node 进行无差别部署, 添加节点使用 bootstraps 方式注册, 其余使用 kubelet.conf 。

对当前版本目录结构进行调整, 把重叠配置进行复用移除。（修改的内容较多）

# v1.20.1.9

### 调整

优化清除 cri 时, 清除残留启动的服务.

不在默认安装 cri-o.

添加 cri-tools 独立安装, 不在依赖 cri-o。

### 修复

修复使用 containerd 时, 如果不能清除本地残留 container 服务则会造成下一次部署时, 无法正常启动成功的问题。

### 移除

移除 add/del Etcd 时更新 Calico 网络:

```
- name: Update K8s Cluster Calico Network Config
  hosts: kube-master[0]
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/crane/defaults/main.yml"
    - "roles/downloads-ssh-key/defaults/main.yml"
    - "roles/kubernetes-manifests/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
    - "roles/etcd-cluster-management/vars/main.yml"
    - "roles/kubernetes-networks/defaults/calico.yaml"
    - "roles/kubernetes-networks/defaults/main.yml"
    - "roles/etcd-cluster-management/defaults/etcd-add-nodes.yaml"
  tasks:
    - { include: 'roles/etcd-cluster-management/includes/update-k8s-calico.yaml' }
```

移除 etcd ca rotation 时更新 Calico 网络:

```
- name: Update Kubernetes Cluster Network Server Config
  hosts: k8s-master[0]
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/crane/defaults/main.yml"
    - "roles/downloads-ssh-key/defaults/main.yml"
    - "roles/kubernetes-manifests/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
    - "roles/etcd-cluster-management/vars/main.yml"
    - "roles/kubernetes-networks/defaults/calico.yaml"
    - "roles/kubernetes-networks/defaults/main.yml"
  tasks:
    - { include: 'roles/etcd-ca-rotation/includes/update-cluster-network.yml' }
```

移除 Kubernetes ca rotation 时更新 Calico 网络:

```
# - name: Update Cluster Network
#   hosts: kube-master[0]
#   become: yes
#   become_method: sudo
#   vars:
#     ansible_ssh_pipelining: true
#   vars_files:
#     - "roles/downloads-ssh-key/defaults/main.yml"
#     - "roles/crane/defaults/main.yml"
#     - "roles/etcd-cluster-management/vars/main.yml"
#     - "roles/kubernetes-networks/defaults/calico.yaml"
#     - "roles/kubernetes-networks/defaults/main.yml"
#     - "roles/kubernetes-manifests/defaults/main.yml"
#     - "roles/kubernetes-cluster-management/defaults/configure.yaml"
#   tasks:
#     - { include: 'roles/kubernetes-ca-rotation/includes/update-cluster-network.yml' }
```

移除 Kubernetes upgrade 时更新 Calico 网络:

```
- name: Update Kubernetes Cluster Tools
  hosts: kube-master[0]
  become: yes
  become_method: sudo
  vars:
    ansible_ssh_pipelining: true
  vars_files:
    - "roles/kubernetes-upgrade/defaults/main.yml"
    - "roles/crane/defaults/main.yml"
    - "roles/kubernetes-cluster-management/defaults/configure.yaml"
    - "roles/downloads-ssh-key/defaults/main.yml"
  tasks:
    - { include: 'roles/kubernetes-upgrade/includes/update-k8s-calico.yaml', when: is_k8s_upgrade_calico }
```

Kubernetes upgrade 时取消更新 Bootstrap 创建。

```
   - { include: 'roles/kubernetes-cluster-management/includes/create-bootstrap.yaml' }
```

# v1.20.2.0

Crane 以更新至 1.20.2.0 版本。

修改了部分文档说明。
