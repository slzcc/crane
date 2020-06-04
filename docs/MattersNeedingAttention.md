# 注意事项

当前 Kubernetes 部署过程中遇到的问题可以通过如下描述进行解决：

### 无法通过 nodePort 访问服务

如发生此类问题时修改 Kube-Proxy 中 node_port_address 地址即可，或通过 crane 的 kube_proxy_node_port_addresses 修改。

### 不要对 pause 进行升级

如果集群是正在使用的不要对 pause 进行更新，它会重启所有的 Pod。

### 使用 Calico IPIP 更换 BGP

使用 Calico 时默认是 IPIP 协议，如果需要修改 BGP 只需要对 Crane 的 calico_type 改为 Off 即可生效。

> 但如果是正在使用的集群，启动后删除 tunl0 网卡后才会生效，这里面存在网络冲突。
