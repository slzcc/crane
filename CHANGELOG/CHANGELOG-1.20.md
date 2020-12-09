- [v1.20.0.0](#v11900)
  - [Updated Instructions](#updated-instructions)
    - [v1.20.0.0 更新内容](#v12000-更新内容)

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
