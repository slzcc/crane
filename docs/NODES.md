# NODES

nodes 文件简易说明.

```
# 如需要添加 master 节点则开启此选项, 主入口 add_master.yml
# [k8s-cluster-add-master]

# 如需要移除 master 节点则开启此选项, 主入口 remove_k8s_master.yml
# [k8s-cluster-del-master]

# 如需要添加 node 节点则开启此选项, 主入口 add_nodes.yml
# [k8s-cluster-add-node]

# 如需要移除 node 节点则开启此选项, 主入口 remove_k8s_nodes.yml
# [k8s-cluster-del-node]

# 如需要添加 etcd 节点则开启此选项, 主入口 add_etcd.yml
# [etcd-cluster-add-node]

# 如需要移除 etcd 节点则开启此选项, 主入口 remove_etcd_nodes.yml
# [etcd-cluster-del-node]

# 如需要新建 etcd 集群则开启此选项, 主入口 etcd_new_cluster.yml
# 如需重新指向 etcd 集群开启此选项, 主入口 migration_k8s_to_new_etcd_cluster.yml
# [etcd-new-cluster]

# 如需要删除 etcd 集群则开启此选项, 主入口 remove_etcd_cluster.yml
# [etcd-del-cluster]

```