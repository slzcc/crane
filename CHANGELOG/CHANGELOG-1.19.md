- [v1.19.0.0](#v11900)
  - [Updated Instructions](#updated-instructions)
    - [v1.19.0.1 更新内容](#v11900-更新内容)

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