# DEPLOYMENT RECORD

## v1.20.1.6

从 v1.18.6.8 的 19.03.12 docker 版本将至 docker 17.12.1-ce 版本, 并使用 containerd 1.4.3 Crane 方式安装。docker 配置文件未删除, 数据目录未删除。

//2020年12月30日 星期三 16时52分40秒 CST

执行命令:

```
$ make run_main_cri
```

修改参数:

```
@crane/roles/remove-cluster/defaults/main.yml

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

并回退成功:

```
$ kubectl get node -o wide
NAME                                              STATUS   ROLES    AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION           CONTAINER-RUNTIME
ip-10-200-1-127.ap-southeast-1.compute.internal   Ready    master   145d   v1.18.6   10.200.1.127   <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
ip-10-200-1-154.ap-southeast-1.compute.internal   Ready    <none>   35d    v1.18.6   10.200.1.154   <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
ip-10-200-1-206.ap-southeast-1.compute.internal   Ready    master   145d   v1.18.6   10.200.1.206   <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
ip-10-200-1-60.ap-southeast-1.compute.internal    Ready    master   145d   v1.18.6   10.200.1.60    <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
```

```
@crane/roles/kubernetes-networks/defaults/calico.yaml
-calico_type: 'Off'
+calico_type: 'Always'
```

执行升级 1.18.6.8 => 1.20.1.6 版本时因内核版本过旧没有升级成功:

```
$ make run_k8s_upgrade

$ kubectl get node -o wide
NAME                                              STATUS     ROLES    AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION           CONTAINER-RUNTIME
ip-10-200-1-127.ap-southeast-1.compute.internal   NotReady   master   145d   v1.18.6   10.200.1.127   <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
ip-10-200-1-154.ap-southeast-1.compute.internal   Ready      <none>   35d    v1.18.6   10.200.1.154   <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
ip-10-200-1-206.ap-southeast-1.compute.internal   Ready      master   145d   v1.18.6   10.200.1.206   <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
ip-10-200-1-60.ap-southeast-1.compute.internal    Ready      master   145d   v1.18.6   10.200.1.60    <none>        CentOS Linux 7 (Core)   3.10.0-1127.el7.x86_64   docker://17.12.1-ce
```

```
$ uname -a
Linux ip-10-200-1-154.ap-southeast-1.compute.internal 3.10.0-1127.el7.x86_64 #1 SMP Tue Mar 31 23:36:51 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

又重新从 1.18.6.8 版本回滚。