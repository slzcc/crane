# K8S ADDONE

可以自定义选择安装 Kubernetes 的周边。

支持的 kubernetes-addons 如下表:

|||||
:--:|:--:|:--:|:--:|
gitlab|[upload-server](templates/upload-service)|[harbor](templates/harbor)|ingress-nginx|
jenkins|openldap|istio|nexus|
metrics-server|~~prometheus-operator~~|~~nextcloud~~|webmin|
~~kafka~~|~~zookeeper~~|~~hadoop~~|~~hbase~~|

> 上述移除的服务配置项都保留, 有兴趣的可进行参考。

> 移除具体原因是根据不同环境可能部署时会产生问题, 不易于正常使用。

> 其余服务会根据稳定性进行部署检测保持 LTS 版本。

其中使用的开关请参照 [Configure](../crane/roles/kubernetes-addons/defaults/main.yml) 进行修改, 修改完成后即可执行:

```
$ make run_k8s_addons
```