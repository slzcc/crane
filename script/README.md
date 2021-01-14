# Scrips

`PublishK8sRegistryImages.sh` 文件是把 `k8s.gcr.io` 中的 `etcd`、`kube-apiserver-amd64`、`kube-controller-manager`、`kube-scheduler`、`kube-proxy` 镜像 Push 到自己的镜像仓库。脚本比较简单请自行修改。
> 其中 targetRegistry: slzcc 为我的官方 Docker Hub 地址。[slzcc/kubernetes](https://hub.docker.com/r/slzcc/kubernetes)

如果需要单独部署镜像可使用如下命令, 以 1.15.0 版本为例：
```
$ docker run --name import-kubernetes-temporary -d -v /var/run/docker.sock:/var/run/docker.sock:ro slzcc/kubernetes:v1.15.0 sleep 1234567

$ until docker exec -i import-kubernetes-temporary bash /docker-image-import.sh ; do >&2 echo "Starting..." && sleep 1 ; done
Loaded image: calico/kube-controllers:v3.7.2
Loaded image: calico/cni:v3.7.2
Loaded image: calico/node:v3.7.2
Loaded image: coredns/coredns:1.5.0
Loaded image: k8s.gcr.io/etcd:3.3.10
Loaded image: haproxy:2.0.0
Loaded image: slzcc/keepalived:1.2.24
Loaded image: k8s.gcr.io/kube-proxy:v1.15.0
Loaded image: k8s.gcr.io/kube-apiserver-amd64:v1.15.0
Loaded image: k8s.gcr.io/kube-controller-manager:v1.15.0
Loaded image: k8s.gcr.io/kube-scheduler:v1.15.0
Loaded image: k8s.gcr.io/pause:3.1

$ docker rm -f import-kubernetes-temporary
```

如果是 containerd 则执行:
```
$ ctr -n k8s.io tasks kill -a --signal 9 import-kubernetes-temporary
$ ctr -n k8s.io tasks rm import-kubernetes-temporary
$ ctr -n k8s.io c rm import-kubernetes-temporary
$ rm -rf /run/containerd/runc/k8s.io/import-kubernetes-temporary
$ ctr -n k8s.io run --null-io --net-host -d \
       --label name=import-kubernetes-temporary \
       --mount type=bind,src=/var/run,dst=/var/run,options=rbind:ro \
       --mount type=bind,src=/run,dst=/run,options=rbind:ro \
       slzcc/kubernetes:v1.20.0 import-kubernetes-temporary sleep 1234567

$ ctr -n k8s.io tasks exec --exec-id $(ctr -n k8s.io tasks list | grep 'import-kubernetes-temporary'| awk '{print $2}') import-kubernetes-temporary bash /containerd-image-import.sh

$ ctr -n k8s.io tasks kill -a --signal 9 import-kubernetes-temporary
$ ctr -n k8s.io tasks rm import-kubernetes-temporary
$ ctr -n k8s.io c rm import-kubernetes-temporary
$ rm -rf /run/containerd/runc/k8s.io/import-kubernetes-temporary
```


镜像包含如下：
```
$ docker images
REPOSITORY                                                       TAG                 IMAGE ID            CREATED             SIZE
slzcc/kubernetes                                                 v1.15.0             fd133aeeb8fc        4 hours ago         1.64GB
k8s.gcr.io/kube-proxy                                            v1.15.0             d235b23c3570        45 hours ago        82.4MB
k8s.gcr.io/kube-apiserver-amd64                                  v1.15.0             201c7a840312        45 hours ago        207MB
k8s.gcr.io/kube-controller-manager                               v1.15.0             8328bb49b652        45 hours ago        159MB
k8s.gcr.io/kube-scheduler                                        v1.15.0             2d3813851e87        45 hours ago        81.1MB
haproxy                                                          2.0.0               7856fff2a391        2 days ago          73.6MB
calico/node                                                      v3.7.2              5ea1d6f6f9b4        6 weeks ago         156MB
calico/cni                                                       v3.7.2              dab36d1b271e        6 weeks ago         135MB
calico/kube-controllers                                          v3.7.2              b1b1263f4e17        6 weeks ago         46.8MB
coredns/coredns                                                  1.5.0               7987f0908caf        2 months ago        42.5MB
k8s.gcr.io/etcd                                                  3.3.10              2c4adeb21b4f        6 months ago        258MB
k8s.gcr.io/pause                                                 3.1                 da86e6ba6ca1        18 months ago       742kB
slzcc/keepalived                                                 1.2.24              0dda87440f93        2 years ago         15.9MB
```

> 脚本说明:

> 不支持单独使用 tag 方式部署, 因全部使用 Kubelet 的静态方式部署启动 Pod, 如删除集群某一批次的节点时 tag 比较有用。

> 目前还暂不支持国内服务器直接进行部署, 如果不使用镜像方式部署, 则部署时镜像基于 `k8s.gcr.io` 地址进行下载, 国内访问时可能会被墙。受影响的应用 `etcd`、`kube-apiserver-amd64`、`kube-controller-manager`、`kube-scheduler`、`kube-proxy`、`pause` 。

> 可修改参数 `k8s_cluster_component_registry` 值为 `slzcc` 自定义镜像仓库地址, 在使用自定义镜像仓库时, 请确保已经执行过 `script/PublishK8sRegistryImages.sh` 脚本。(可支持的镜像版本参阅 [slzcc/kubernetes](https://hub.docker.com/r/slzcc/kubernetes))

> 默认 Etcd 需要跟随 Master 进行部署, 暂不支持 Etcd 部署在 Node 中 (后期会优化, 在添加  节点时支持 Node 节点部署)。