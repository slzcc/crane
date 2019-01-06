# Ansible-Kubernetes
Please refer to the documentation for detailed configuration: [Wiki Docs URL](https://wiki.shileizcc.com/display/CASE/Ansible+Kubernetes+Cluster).

The Kubernetes Version currently supported:
* v1.10.0

## Create Kubernetes Cluster
```
$ ansible-playbook -i nodes main.yml -vv
```
Cluster Status
```
$ kubectl get csr
NAME                                                   AGE       REQUESTOR                 CONDITION
csr-5hl64                                              11m       system:node:instance-3    Approved,Issued
csr-758h6                                              11m       system:node:instance-4    Approved,Issued
csr-fdf9g                                              11m       system:node:instance-2    Approved,Issued
node-csr-4PjnAlcpExzHYlotBexV1yaev40khyc3RjIlWj-JFMU   10m       system:bootstrap:b53294   Approved,Issued
node-csr-9qRs7kA959MOtQHx-5XXuMvmwl3vT6M1QkmmzUgvteQ   10m       system:bootstrap:b53294   Approved,Issued
node-csr-GJqCuRzlL6KzLvxLRgNo1fEswguU6RLaETPjw2SNzs4   10m       system:bootstrap:b53294   Approved,Issued

$ kubectl get nodes
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    11m       v1.10.0
instance-3   Ready      master    11m       v1.10.0
instance-4   Ready      master    11m       v1.10.0
instance-5   NotReady   node      10m       v1.10.0
instance-6   NotReady   node      10m       v1.10.0
instance-7   NotReady   node      10m       v1.10.0

$ kubectl -n kube-system get pod -o wide
NAME                                       READY     STATUS              RESTARTS   AGE       IP            NODE
calico-kube-controllers-7779fd5f4c-v95ps   1/1       Running             0          34m       10.30.0.204   instance-4
calico-node-6fcbj                          2/2       Running             0          34m       10.30.0.204   instance-4
calico-node-9tzx9                          0/2       ContainerCreating   0          34m       10.30.0.205   instance-5
calico-node-hhd5b                          2/2       Running             0          34m       10.30.0.202   instance-2
calico-node-hjzx7                          2/2       Running             0          34m       10.30.0.203   instance-3
calico-node-nfqqs                          0/2       ContainerCreating   0          34m       10.30.0.207   instance-7
calico-node-sm454                          0/2       ContainerCreating   0          34m       10.30.0.206   instance-6
etcd-instance-2                            1/1       Running             0          34m       10.30.0.202   instance-2
etcd-instance-3                            1/1       Running             0          35m       10.30.0.203   instance-3
etcd-instance-4                            1/1       Running             0          35m       10.30.0.204   instance-4
haproxy-instance-2                         1/1       Running             0          35m       10.30.0.202   instance-2
haproxy-instance-3                         1/1       Running             0          35m       10.30.0.203   instance-3
haproxy-instance-4                         1/1       Running             0          35m       10.30.0.204   instance-4
keepalived-instance-2                      1/1       Running             0          35m       10.30.0.202   instance-2
keepalived-instance-3                      1/1       Running             0          35m       10.30.0.203   instance-3
keepalived-instance-4                      1/1       Running             0          35m       10.30.0.204   instance-4
kube-apiserver-instance-2                  1/1       Running             0          35m       10.30.0.202   instance-2
kube-apiserver-instance-3                  1/1       Running             0          35m       10.30.0.203   instance-3
kube-apiserver-instance-4                  1/1       Running             0          35m       10.30.0.204   instance-4
kube-controller-manager-instance-2         1/1       Running             0          35m       10.30.0.202   instance-2
kube-controller-manager-instance-3         1/1       Running             0          35m       10.30.0.203   instance-3
kube-controller-manager-instance-4         1/1       Running             0          35m       10.30.0.204   instance-4
kube-dns-654684d656-jkprr                  0/3       Pending             0          34m       <none>        <none>
kube-proxy-4dtr6                           1/1       Running             0          34m       10.30.0.204   instance-4
kube-proxy-4lc6x                           1/1       Running             0          34m       10.30.0.203   instance-3
kube-proxy-84vzq                           0/1       ContainerCreating   0          34m       10.30.0.207   instance-7
kube-proxy-cxkdl                           0/1       ContainerCreating   0          34m       10.30.0.206   instance-6
kube-proxy-h2vgj                           0/1       ContainerCreating   0          34m       10.30.0.205   instance-5
kube-proxy-w9rxj                           1/1       Running             0          34m       10.30.0.202   instance-2
kube-scheduler-instance-2                  1/1       Running             0          35m       10.30.0.202   instance-2
kube-scheduler-instance-3                  1/1       Running             0          35m       10.30.0.203   instance-3
kube-scheduler-instance-4                  1/1       Running             0          35m       10.30.0.204   instance-4
```

## Add K8s Cluster Manager Node.
```
$ ansible-playbook -i nodes add_master.yml -vv
```
Cluster Status
```
$ kubectl get node
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    46m       v1.10.0
instance-3   Ready      master    46m       v1.10.0
instance-4   Ready      master    46m       v1.10.0
instance-5   Ready      node      45m       v1.10.0
instance-6   Ready      node      45m       v1.10.0
instance-7   Ready      node      45m       v1.10.0
instance-8   Ready      master    7m        v1.10.0

$ kubectl get csr
NAME                                                   AGE       REQUESTOR                 CONDITION
csr-hs7lr                                              46m       system:node:instance-3    Approved,Issued
csr-kc46g                                              46m       system:node:instance-4    Approved,Issued
csr-nz8h2                                              7m        system:node:instance-8    Approved,Issued
csr-xbbg2                                              46m       system:node:instance-2    Approved,Issued
node-csr-DBuvqHT_-wjeb4DBGiovuWr3Y6t3MjywFj1kRpOIIhc   45m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-e-yBfiDSbcDTxJM8wloZLHsOStlO7TWiKDGX29dnm6I   45m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-xk3fBmT4OOHNAtbYJq4IXtLLpFlfyXLeX2PWFMNsrjk   45m       system:bootstrap:ed3fd7   Approved,Issued
```

## Add K8s Cluster Worker Node.
```
$ ansible-playbook -i nodes add_nodes.yml -vv
```
Cluster Status
```
$ kubectl get node
NAME         STATUS     ROLES     AGE       VERSION
instance-2   Ready      master    46m       v1.10.0
instance-3   Ready      master    46m       v1.10.0
instance-4   Ready      master    46m       v1.10.0
instance-5   Ready      node      45m       v1.10.0
instance-6   Ready      node      45m       v1.10.0
instance-7   Ready      node      45m       v1.10.0
instance-8   Ready      master    7m        v1.10.0
instance-9   NotReady   node      10s       v1.10.0

$ kubectl get csr
NAME                                                   AGE       REQUESTOR                 CONDITION
csr-hs7lr                                              47m       system:node:instance-3    Approved,Issued
csr-kc46g                                              47m       system:node:instance-4    Approved,Issued
csr-nz8h2                                              8m        system:node:instance-8    Approved,Issued
csr-xbbg2                                              47m       system:node:instance-2    Approved,Issued
node-csr-DBuvqHT_-wjeb4DBGiovuWr3Y6t3MjywFj1kRpOIIhc   46m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-GztgEuKzz0eVw77CDPzvxnkuhvYE8jucK_xA_tBkJCA   1m        system:bootstrap:ed3fd7   Approved,Issued
node-csr-e-yBfiDSbcDTxJM8wloZLHsOStlO7TWiKDGX29dnm6I   46m       system:bootstrap:ed3fd7   Approved,Issued
node-csr-xk3fBmT4OOHNAtbYJq4IXtLLpFlfyXLeX2PWFMNsrjk   46m       system:bootstrap:ed3fd7   Approved,Issued
```

## Clean Kubernetes Cluster
```
$ ansible-playbook -i nodes add_nodes.yml -vv
```
