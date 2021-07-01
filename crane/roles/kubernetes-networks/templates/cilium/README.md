# cilium

在 Crane `v1.21.2.1` 中添加 Cilium 组件, 模板通过 HELM 生成并进行修改:

> 参照文档: https://docs.cilium.io/en/v1.10/helm-reference/

> https://docs.cilium.io/en/stable/gettingstarted/kubeproxy-free/#kubeproxy-free

```
$ helm repo add cilium https://helm.cilium.io/

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
--set hostServices.enabled=true \
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
--set nodePort.range="10\,65534" \
#--set devices="eth0" \
--set nodePort.directRoutingDevice="eth0" \
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

```
helm template hubble \
    --namespace kube-system \
    --set metrics.enabled="{dns:query;ignoreAAAA;destinationContext=pod-short,drop:sourceContext=pod;destinationContext=pod,tcp,flow,port-distribution,icmp,http}" \
    --set ui.enabled=true \
    > hubble.yaml

```

替换 kube-proxy 只需修改 `cilium_kubeProxy_replacement_type` 为 `strict` 只需 kube-proxy 移除命令:

```
$ kubectl delete -f /tmp/crane/main/kube-proxy.yml

```

清除 iptables: 

```
for i in nat filter; do
  iptables -t $i --line -nvL | grep cali- | awk '{print $2}' | xargs -i iptables -t $i -X {}
  iptables -t $i --line -nvL | grep KUBE- | awk '{print $2}' | xargs -i iptables -t $i -X {}
done
```

清除 ipset:

```
for i in flush destroy; do
  ipset list | grep -E "(KUBE|cali)" | awk '{print $2}' | xargs -i ipset $i {}
done
```

集群配置: (其中 --context 参数需要自定义配置上下文, 并且区分 name 和 id)

```
# https://docs.cilium.io/en/v1.10/gettingstarted/clustermesh/clustermesh/
cilium clustermesh enable --context kubernetes-admin@kubernetes --service-type NodePort
cilium clustermesh enable --context kubernetes-admin2@kubernetes2 --service-type NodePort --create-ca kubernetes-admin@kubernetes
cilium clustermesh connect --context kubernetes-admin@kubernetes --destination-context kubernetes-admin2@kubernetes2
cilium clustermesh status --wait

```