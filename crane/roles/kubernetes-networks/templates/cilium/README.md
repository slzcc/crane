# cilium

在 Crane `v1.21.2.1` 中添加 Cilium 组件, 模板通过 HELM 生成并进行修改:

> 参照文档: https://docs.cilium.io/en/v1.10/helm-reference/


```
$ helm template cilium cilium/cilium --version 1.10.1 \
--namespace kube-system \
--set cluster.name="cilium-a" \
--set cluster.id=1 \
--set cni.binPath="/opt/cni/bin" \
--set cni.confPath="/etc/cni/net.d" \
--set daemon.runPath="/var/run/cilium" \
--set debug.enabled=false \
--set datapathMode="veth" \
--set nodeinit.enabled=true \
--set externalIPs.enabled=true \
--set nodePort.enabled=true \
--set hostPort.enabled=true \
--set pullPolicy=IfNotPresent \
--set config.ipam=cluster-pool \
--set prometheus.enabled=true \
--set prometheus.port=9990 \
--set peratorPrometheus.enabled=true \
--set hubble.enabled=true \
--set hubble.listenAddress=":4244" \
--set hubble.relay.enabled=true \
--set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
--set hubble.ui.enabled=true \
--set hubble.tls.enabled=false \
--set kubeProxyReplacement=strict \
--set k8sServiceHost=192.168.122.86 \
--set ipam.operator.clusterPoolIPv4PodCIDR=10.0.0.0/8 \
--set ipam.operator.clusterPoolIPv4MaskSize=24 \
--set k8sServicePort=6443
```

CLI 工具可通过如下方式安装:

```
$ curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
$ sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
$ sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
$ rm cilium-linux-amd64.tar.gz{,.sha256sum}
```

外部 ETCD 可通过如下方式生成:

```
$ helm template cilium cilium/cilium --version 1.10.1 \
--namespace kube-system \
--set cluster.name="cilium-a" \
--set cluster.id=1 \
--set cni.binPath="/opt/cni/bin" \
--set cni.confPath="/etc/cni/net.d" \
--set daemon.runPath="/var/run/cilium" \
--set debug.enabled=false \
--set datapathMode="veth" \
--set nodeinit.enabled=true \
--set externalIPs.enabled=true \
--set nodePort.enabled=true \
--set hostPort.enabled=true \
--set pullPolicy=IfNotPresent \
--set config.ipam=cluster-pool \
--set prometheus.enabled=true \
--set prometheus.port=9990 \
--set peratorPrometheus.enabled=true \
--set hubble.enabled=true \
--set hubble.listenAddress=":4244" \
--set hubble.relay.enabled=true \
--set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
--set hubble.ui.enabled=true \
--set hubble.tls.enabled=false \
--set kubeProxyReplacement=strict \
--set k8sServiceHost=192.168.122.86 \
--set ipam.operator.clusterPoolIPv4PodCIDR=10.0.0.0/8 \
--set ipam.operator.clusterPoolIPv4MaskSize=24 \
--set k8sServicePort=6443 \
--set etcd.enabled=true \
--set etcd.endpoints[0]="https://etcd-endpoint1:2379" \
--set etcd.endpoints[1]="https://etcd-endpoint2:2379" \
--set etcd.endpoints[2]="https://etcd-endpoint3:2379" \
--set etcd.clusterDomai="cluster.local" \
--set identityAllocationMode=kvstore
 
$ kubectl create secret generic -n kube-system cilium-etcd-secrets \
    --from-file=etcd-client-ca.crt=ca.crt \
    --from-file=etcd-client.key=client.key \
    --from-file=etcd-client.crt=client.crt
```