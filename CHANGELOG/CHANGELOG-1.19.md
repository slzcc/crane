- [v1.19.0.0](#v11900)
  - [Updated Instructions](#updated-instructions)
    - [v1.19.0.0 更新内容](#v11900-更新内容)
    - [v1.19.0.1 更新内容](#v11901-更新内容)
    - [v1.19.0.2 更新内容](#v11902-更新内容)
    - [v1.19.1.0 更新内容](#v11910-更新内容)
    - [v1.19.2.0 更新内容](#v11920-更新内容)
    - [v1.19.2.1 更新内容](#v11921-更新内容)
    - [v1.19.2.2 更新内容](#v11922-更新内容)
    - [v1.19.3.0 更新内容](#v11930-更新内容)
    - [v1.19.4.0 更新内容](#v11940-更新内容)

# v1.19.0.0

Crane 以更新至 1.19.0.0 版本。

# v1.19.0.1

添加 etcd 和 apiServer TLS Host 信息头:

```
# apiServer
k8s_master_default_ip_str: >-
  {% for host in groups['kube-master'] -%}
    {{ hostvars[host].ansible_default_ipv4.address }}
    {%- if not loop.last -%},{%- endif -%}
  {%- endfor -%}

# etcd
etcd_master_default_ip_str: >-
  {% for host in groups['etcd'] -%}
    {{ hostvars[host].ansible_default_ipv4.address }}
    {%- if not loop.last -%},{%- endif -%}
  {%- endfor -%}
```

目的是可以通过公网或者其他网卡对默认网卡集群的支持。

增加删除 cluster etcd、nodes 的功能。


# v1.19.0.2

在 v1.18.6.6 中修改的 docker daemon.json 文件没有修复成功, 此版本进行修复。

# v1.19.1.0

Crane 以更新至 1.19.1.0 版本。

# v1.19.2.0

Crane 以更新至 1.19.2.0 版本。
Del K8s 中对删除 node 添加抑制报错，主要解决远程服务器有残留数据但并没有添加到集群的问题。
CoreDNS 配置 Memory Limit 1024Mi, 旧配置 170Mi 时会触发 OOMKill 的问题目前没有解决调整内存大小可避免触发。

# v1.19.2.1

CoreDNS 修改配置如下:

```
    .:53 {
        errors
        health
        ready
        kubernetes {{ dns_domain }} in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        reload
        loadbalance
    }

# edit =>
    .:53 {
        errors
        health {
          lameduck 5s
        }
        ready
        kubernetes {{ dns_domain }} in-addr.arpa ip6.arpa {
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 3000
        }
        cache 30
        reload
        loadbalance
    }
```

> 主要加入 DNS 查询最大上限避免高内存的消耗导致服务崩溃.

CoreDNS Memory Limit 修改为:

```
1024Mi => 170Mi
```

Harbor Copy TLS in Docker Cert Config 时有权限问题，在创建目录时添加：

```
...
&& chown {{ ssh_connect_user }} /etc/docker/certs.d
```

# v1.19.2.2

在 # v1.19.2.1 中的 harbor 下发 ca 时修复的权限问题有遗漏 sudo 问题，此版本修复上个版本的问题如下：

```
...
$ chown {{ ssh_connect_user }} /etc/docker/certs.d => $ sudo chown {{ ssh_connect_user }} /etc/docker/certs.d
```

# v1.19.3.0

Crane 以更新至 1.19.3.0 版本。
添加 harbor 部署时可自定义版本，默认 v2.1.0, 可根据 [Harbor Release](https://github.com/goharbor/harbor/releases) 查看官方可部署版本。
重构 harbor 部署配置项, 之前的配置（v1.8.2）文件无法直接修改使用。

# v1.19.3.1

修复 harbor 创建证书时, 添加了重复 DNS 记录的问题。

# v1.19.4.0

Crane 以更新至 1.19.4.0 版本。

```
@crane/roles/kubernetes-addons/defaults/main.yml
添加 Domain 使用注释。

@crane/roles/kubernetes-addons/includes/harbor_create_tls.yaml
修复 Harbor 创建 TLS 有重复 DNS 记录。

@docs/MattersNeedingAttention.md
添加部分错误说明。
```