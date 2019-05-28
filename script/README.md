# Scrips

`PublishK8sRegistryImages.sh` 文件是把 `k8s.gcr.io` 中的 `etcd`、`kube-apiserver-amd64`、`kube-controller-manager`、`kube-scheduler`、`kube-proxy` 镜像 Push 到自己的镜像仓库。脚本比较简单请自行修改。
> 其中 targetRegistry: slzcc 为我的官方 Docker Hub 地址。