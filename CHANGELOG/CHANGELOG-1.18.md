- [v1.18.0.0](#v11800)
  - [Updated Instructions](#updated-instructions)
    - [v1.18.0.0 更新内容](#v11800-更新内容)
    - [v1.18.0.1 更新内容](#v11801-更新内容)
    - [v1.18.1.0 更新内容](#v11810-更新内容)
    - [v1.18.2.0 更新内容](#v11820-更新内容)
    - [v1.18.2.1 更新内容](#v11821-更新内容)
    - [v1.18.2.2 更新内容](#v11822-更新内容)
    - [v1.18.3.0 更新内容](#v11830-更新内容)
    - [v1.18.3.1 更新内容](#v11831-更新内容)
    - [v1.18.3.2 更新内容](#v11832-更新内容)
    - [v1.18.3.3 更新内容](#v11833-更新内容)
    - [v1.18.3.4 更新内容](#v11834-更新内容)
    - [v1.18.3.5 更新内容](#v11835-更新内容)
    - [v1.18.3.6 更新内容](#v11836-更新内容)
    - [v1.18.3.7 更新内容](#v11837-更新内容)
    - [v1.18.3.8 更新内容](#v11838-更新内容)
    - [v1.18.3.9 更新内容](#v11839-更新内容)
    - [v1.18.3.10 更新内容](#v118310-更新内容)
    - [v1.18.4.0 更新内容](#v11840-更新内容)
    - [v1.18.5.0 更新内容](#v11850-更新内容)
    - [v1.18.5.1 更新内容](#v11851-更新内容)
    - [v1.18.5.2 更新内容](#v11852-更新内容)
    - [v1.18.5.3 更新内容](#v11853-更新内容)
    - [v1.18.5.4 更新内容](#v11854-更新内容)
    - [v1.18.6.0 更新内容](#v11860-更新内容)
    - [v1.18.6.1 更新内容](#v11861-更新内容)
    - [v1.18.6.2 更新内容](#v11862-更新内容)
    - [v1.18.6.3 更新内容](#v11863-更新内容)
    - [v1.18.6.4 更新内容](#v11864-更新内容)
    - [v1.18.6.5 更新内容](#v11865-更新内容)
    - [v1.18.6.6 更新内容](#v11866-更新内容)
    - [v1.18.6.7 更新内容](#v11867-更新内容)

# v1.18.0.0

Crane 以更新至 1.18.0.0 版本。

Kubernetes 更新内容请参照 [Kubernetes Update Content](https://raw.githubusercontent.com/kubernetes/kubernetes/master/CHANGELOG/CHANGELOG-1.18.md).

## Updated Instructions

各版本更新说明。

### v1.18.0.0 更新内容

同步 Kubernetes v1.18.0 版本部署。

### v1.18.0.1 更新内容

添加 kubernetes upgrade v1.18 版本。

添加 Kube-Simple 视频安装过程示例

### v1.18.1.0 更新内容

添加 kubernetes v1.18.1.0 版本支持。

### v1.18.2.0 更新内容

添加 kubernetes v1.18.2.0 版本支持。

### v1.18.2.1 更新内容

更新 calico 启动配置项与官方一致。

更新 haproxy version 为 2.1.4。

添加 nf_conntrack kernel 参数。

### v1.18.2.2 更新内容

修改 ansible sudo 配置为 become。

修改 Makefile option 自定义参数选项。

### v1.18.3.0 更新内容

添加 kubernetes v1.18.3.0 版本支持。

### v1.18.3.1 更新内容

修改 pause:3.2 版本支持。

### v1.18.3.2 更新内容

修改 CNI v0.8.6 版本支持。

修改 Etcd 3.4.7 版本支持。

修改 Calico v3.14.0 版本支持。

修改 CoreDNS 1.6.9 版本支持。

### v1.18.3.3 更新内容

修复 Upgrade 1.18 版本中的 proxy 配置与当前版本的配置不统一的问题。

### v1.18.3.4 更新内容

修复 Upgrade 离线安装找不到 离线安装包 的问题。

### v1.18.3.5 更新内容

修复 *。yml 部分存在用户权限问题（sudo）无法执行的问题。

### v1.18.3.6 更新内容

修复 calico 中 controllers 为 hostNetwork 模式，否则可能会造成 controllers 无法找到 etcd 的问题。

修复 Clean Cluster 中删除 modprobe 操作。

1.17.x 升级至 1.18.3.1 中一定要确认使用的 pause 版本，如果版本不止一次会造成原始 Pod 的重启。

### v1.18.3.7 更新内容

修复 Centos 8 只能 Script 方式安装 Dockerd。

添加 Debian 支持。

修复 Centos x 中安装 `yum-plugin-ovl` 报错的问题。

同步安装 Harbor 时默认安装 UploadServer 这样可以让其他 Node 可以远程下载 TLS 证书。（但需要自行解决 Dockerd 识别非法 HTTPS 问题）

### v1.18.3.8 更新内容

修复 harbor 创建 TLS 证书时 cfssljson 无法找到的问题。

修复 harbor 中存在的 imagePullSecrets 配置异常报错。

修复 harbor 中 0_postgresql.yaml 镜像配置错误问题。

修复 添加 kernel 参数所使用的 k8s.conf 文件，没有成功添加变量的问题。

修改 cni 默认地址池为 172.200.0.0/12。

修改 k8s_cluster_ip_pool 默认地址池 10.9.0.0/12。

修改 k8s_cluster_ip 为 10.9.0.1 地址。

修改 k8s dns address 为 10.9.0.10 地址。

添加 nf_conntrack_buckets 开机启动配置。

### v1.18.3.9 更新内容

添加 清除集群时 iptables 规则判定，默认为 false，如果清除集群时，则不清除残留 iptables 规则。

修改 Calico 启动默认 BGP 模式。

### v1.18.3.10 更新内容

修复 Deploy Harbor 生成客户端秘钥时命名错误（client.ket 改为 client.key）

添加 Deploy Harbor 执行 Create Secret 时的命令到 secret.sh 。

添加 Deploy Ingress 时 nodeSelector 参数只能 master 节点进行启动。

### v1.18.4.0 更新内容

添加 kubernetes v1.18.4 版本支持。

Crane 以更新至 1.18.0.0 版本。

修改 ingress-nginx version 0.33.0 版本。

修改 istio version 1.6.0 版本。

修改 harbor 时区问题。

### v1.18.5.0 更新内容

添加 kubernetes v1.18.5 版本支持。

### v1.18.5.1 更新内容

添加 [Add-One](/crane/crane/roles/add-ons) 说明.

添加 Harbor Client Cert 部署所有集群 Nodes 配置项。

添加 Harbor Client Cert 便捷获取方式.

### v1.18.5.2 更新内容

添加 add-ons:
  * gitlab
  * jenkins
  * nexus
  * nextcloud
  * webmin
  * openldap
  * kafka
  * hadoop
  * zookeeper
  * hbase

### v1.18.5.3 更新内容

修复 keepalived:1.2.24 为 keepalived:1.2.24.1:
  * 检测 VIP 存在不合理问题，部分 IP 无法进行识别

### v1.18.5.4 更新内容

修复 Deploy Master 节点时没有 Copy 完整的 *.pem 文件导致的其他 Master 节点无法正常启动的问题。

修改 cni 默认地址池为 172.208.0.0/12。

修改 k8s_cluster_ip_pool 默认地址池 10.16.0.0/12。

修改 k8s_cluster_ip 为 10.16.0.1 地址。

修改 k8s dns address 为 10.16.0.10 地址。

> 重新修改以上 掩码 是为了保证准确性，在自己设计掩码时一定要按照掩码的第一个网段设置 apiServer 的 clusterIP，否则它会自己计算第一个网段的第一个 IP 为 default kubernetes 的 clusterIP，在生成证书时如果错误的写入了其他值则会引起无法访问 kubernetes.default x509 问题。

### v1.18.6.0 更新内容

添加 kubernetes v1.18.6 版本支持。

修复 dockerd env 配置项格式问题，没有标准的双引号。

添加 harbor 多域名证书申请，目的解决多机房共用证书问题。

### v1.18.6.1 更新内容

所需组件升级:
  * Haproxy 2.2.0
  * Docker  19.03.12
  * Calico  3.15.1
  * CoreDNS 1.7.0

废弃参数:

```
# 获取当前需要部署的 Kubernetes Master 总数量, 配置数量在 nodes 文件中获取
k8s_master_counts: "{{ groups['kube-master'] | length }}"

# 获取当前需要部署的 Kubernetes Node 总数量, 配置数量在 nodes 文件中获取
all_nodes_counts: "{{ groups['all'] | length }}"
```

### v1.18.6.2 更新内容

由于发现 v1.18.5.2 版本中存在渲染报错，对以下版本在 git 中剔除，但不影响版本使用:
  * v1.18.5.2
  * v1.18.5.3
  * v1.18.5.4
  * v1.18.6.0
  * v1.18.6.1

经测试 Ubuntu 20.04 可以使用。

### v1.18.6.3 更新内容

修复 Copy PKI Files 时存在 bug 的问题, 会造成重复写入 etcd 目录而造成死循环的问题。

修复 addons 部分因版本造成的无法部署的问题。

Dockerd 加入强制安装项。

修复 Harbor 时区加载时配置项不识别的问题。

修复 Harbor Copy PEM 时存在权限问题。

修改 ansible.cfg SSH 连接超时 600 改为 1800.

### v1.18.6.4 更新内容

废弃参数:

```
# 如果系统开启了 Swap, 此只为 true 的情况下不做任何操作, 如果为 false 则强制关闭系统的 Swap, 不等同于 vm.swappiness = 0
# 这是关闭系统所有已经开启的 Swap 项, 如果使用 Swap 请谨慎操作.
is_swap: true
```

修改 Makefile 增加 -t 参数，主要目的通过 tty 让其显示颜色输出。

添加 Aliyun Registry，可以修改 `k8s_image_deploy_repo` 使用任意镜像仓库获取镜像。

修复 v1.18.6.3 中加入强制安装 Dockerd 选项的 bug。

### v1.18.6.5 更新内容

废弃:

``` kube-apiserver
--advertise-address={{ k8s_load_balance_ip }}
```

新增:

``` kube-apiserver
--bind-address=0.0.0.0
```

支持 AWS ELB 的 DNS 方式进行部署。

> ELB 通过 DNS 解析到两个 IP 地址进行使用保证物理上的高可用。

修复 ingress-nginx 可能存在获取 ssl 没有权限的问题:

``` crane/roles/add-ons/templates/ingress-nginx/ingress-nginx.j2
runAsUser: 33 => runAsUser: 101
```

修复通过 wget 下载 package 时 proxy 执行异常报错问题。

加入 [Github Actions](https://github.com/slzcc/crane/actions) CI 测试。

### v1.18.6.6 更新内容

修复 docker install 时, 强制写入 daemon.json 文件时无法写入的 bug。

修复 dockerd 配置文件:

``` crane/roles/docker-install/tasks/main.yml
"insecure-registry": {{ docker_insecure_registry }} => "insecure-registries": {{ docker_insecure_registry }}
```

### v1.18.6.6 更新内容

修复: ( 23 余个 )

``` 
{{ hostvars[host].ansible_default_ipv4.address }} => {{ host }}
```

> 因 ansible 获取主机 ansible_default_ipv4.address 如果在多网卡模式下存在 BUG, 可能获取错误的 IP 地址造成无法通讯的问题。