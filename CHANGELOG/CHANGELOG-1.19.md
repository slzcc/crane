- [v1.19.0.0](#v11900)
  - [Updated Instructions](#updated-instructions)
    - [v1.19.0.0 更新内容](#v11900-更新内容)
    - [v1.19.0.1 更新内容](#v11901-更新内容)
    - [v1.19.0.2 更新内容](#v11902-更新内容)
    - [v1.19.1.0 更新内容](#v11910-更新内容)
    - [v1.19.2.0 更新内容](#v11920-更新内容)

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