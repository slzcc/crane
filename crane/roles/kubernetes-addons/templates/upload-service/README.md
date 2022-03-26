# UploadServer Deploy

安装 Harbor 需要注意 `/crane/crane/group_vars/k8s_cluster/k8s-addons.yaml` 中 `is_deploy_upload_service` 为 `true`, 并且修改 Domain:

```
is_deploy_upload_service: true

upload_service_ingress_domain: 'upload.example.com'
```

其余默认即可, 如果是后续进行安装则可以修改 Makefile 中:

```
OPTION := --tags k8s-addons
```

然后执行即可部署 UploadServer 。

如果我们通过 UploadServer 维护 Client 证书, 则可以通过该命令上传证书:

```
$ UploadServerIP=`kubectl get pods -l app=upload-service -o jsonpath='{.items[*].status.podIP}'`
$ DownloadURL=`curl -sSfL --form 'file=@/etc/kubernetes/harbor/cert/harbor.example.com.tar.gz' http://${UploadServerIP}/upload -H 'Host:upload.example.com' | jq --raw-output '.account_url'`
$ echo $DownloadURL
```

按照上述列出的 URL 进行下载, 可通过脚本进按照:

```
#!/bin/bash

mkdir -p /etc/docker/certs.d/
rm -rf /etc/docker/certs.d/harbor.example.com
wget -qO- http://${DownloadURL} | tar zx -C /etc/docker/certs.d/
```

可以把脚本放入 UploadServer 进行远程执行。

> 注意部署 UploadServer 一定要跟 Ingress 一同使用以上配置才会准确无误执行成功。