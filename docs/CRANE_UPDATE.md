# CRANE UPDATE

Crane 更新简要说明。


## 功能组件更新

Crane 从 v1.20 版本开始在后续的版本更新中除非使用的组件有重大 Bug 否则不会在大版本中更新组件的版本, 这样保证的 Crane 在同一个大版本中升级或稳定性上不会有较大的变动保证稳定性。


执行命令:

```
$ make run_main_cri
```

修改参数:

```
@crane/roles/clean-install/defaults/main.yml

-is_remove_all: true
+is_remove_all: false

-is_remove_docker_ce: false
+is_remove_docker_ce: true

-is_remove_not_crane_docker_ce: false
+is_remove_not_crane_docker_ce: true

-is_remove_containerd: false
+is_remove_containerd: true

-is_remove_not_crane_containerd: false
+is_remove_not_crane_containerd: true

-is_remove_iptables_rule: false
+is_remove_iptables_rule: true
```

```
@crane/roles/cri-install/vars/containerd.yaml
-containerd_data_root: '/var/lib/containerd'
+containerd_data_root: '/data/containerd'

-is_mandatory_containerd_install: false
+is_mandatory_containerd_install: false
```

```
@crane/roles/cri-install/vars/docker.yaml

-clean_up_old_before_installing: false
+clean_up_old_before_installing: true

-is_docker_install_close_kubelet: false
+is_docker_install_close_kubelet: true
```

```
@crane/roles/kubernetes-manifests/defaults/main.yml
-k8s_cluster_ip: '10.16.0.1'
+k8s_cluster_ip: '10.32.0.1'

-k8s_cluster_ip_range: '10.16.0.0/12'
+k8s_cluster_ip_range: '10.32.0.0/12'

-k8s_cluster_ipv4_pool_cidr: '172.208.0.0/12'
+k8s_cluster_ipv4_pool_cidr: '172.224.0.0/12'

-dns_cluster_ip: '10.16.0.10'
+dns_cluster_ip: '10.32.0.10'
```

```
@crane/roles/kubernetes-networks/defaults/calico.yaml
-calico_type: 'Off'
+calico_type: 'Always'
```