# Harbor Deploy

安装 Harbor 需要注意 [main.yml](../../defaults/main.yml) 中 `is_deploy_harbor` 为 `true`, 并且修改 Domain:

```
is_deploy_harbor: true

harbor_ingress_default_domain: 'harbor.example.com'
harbor_ingress_notary_domain: 'notary.example.com'
```

其余默认即可, 如果是后续进行安装则可以修改 Makefile 中:

```
OPTION := --tags k8s-addons
```

然后执行即可部署 Harbor 。

> Harbor Deploy 不支持离线安装, 所有节点都需要通过外网下载镜像。

Harbor 部署完毕启动配置后会在第一个 Master 节点的 `/etc/kubernetes/harbor` 中生成。目录结构如下:

```
$ tree /etc/kubernetes/harbor/
/etc/kubernetes/harbor/
├── 00_namespace.yaml                # Deploy Kubernetes Yarm Config 
├── 0_postgresql.yaml
├── 1_redis.yaml
├── 2_registry.yaml
├── 3_ingress.yaml
├── 4_portal.yaml
├── 5_jobservice.yaml
├── 6_core.yaml
├── 7_clair.yaml
├── 8_notary.yaml
├── 9_chartmuseum.yaml
├── 10_trivy.yaml
├── cert                             # Cert Config, 默认 20 年证书有效期
│   ├── ca-config.json
│   ├── ca.crt -> ca.pem
│   ├── ca.csr
│   ├── ca-csr.json
│   ├── ca-key.pem                   # Harbor CA 证书
│   ├── ca.pem
│   ├── client.csr
│   ├── client-csr.json
│   ├── client-key.pem               # Harbor Client 证书, 由 docker 使用
│   ├── client.pem
│   ├── harbor.csr
│   ├── harbor-csr.json
│   ├── harbor-key.pem               # Harbor Server 证书
│   ├── harbor.example.com           # Harbor Client 证书目录
│   │   ├── ca.crt
│   │   ├── client.cert
│   │   └── client.key
│   ├── harbor.example.com.tar.gz    # Harbor Client 证书压缩包
│   ├── harbor.pem
│   ├── tls.crt -> harbor.pem        # 创建 Ingress 使用, 可忽略
│   └── tls.key -> harbor-key.pem    # 创建 Ingress 使用, 可忽略
├── config                           # Harbor 所需部分配置
│   ├── config.yaml
│   ├── server.json
│   └── signer.json
└── secret.sh
```

> 部署完成后把对应服务创建的数据目录放置到 分布式存储 或者 hostPath 中, 数据目录为临时数据目录。

因 Client 证书存在后期维护问题, 所以这里准备一个 upload server 进行维护(默认启动后也是临时数据目录请自行维护)。

> 注意部署 Harbor 一定要跟 Ingress 一同使用以上配置才会准确无误执行成功。

# UploadServer Deploy

安装 Harbor 需要注意 `/crane/crane/roles/add-ons/defaults/main.yml` 中 `is_deploy_upload_service` 为 `true`, 并且修改 Domain:

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