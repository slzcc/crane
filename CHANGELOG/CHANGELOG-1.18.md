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