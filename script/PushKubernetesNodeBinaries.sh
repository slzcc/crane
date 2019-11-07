#!/bin/bash

# 如果需要部署到自己的私有仓库，请修改此项名称
export targetRegistry=${targetRegistry:-'slzcc'}

_cni_os_drive=`awk '/^cni_os_drive/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_k8sVersion=`awk '/^k8s_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_cni_version=`awk '/^cni_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_etcdVersion=`awk '/^etcd_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_pauseVersion=`awk '/^pause_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_calicoVersion=`awk '/^calico_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_haproxyVersion=`awk '/^haproxy_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_corednsVersion=`awk '/^dns_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_nginxIngressVersion=`awk '/^ingress_nginx_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`

# Docker Version
export dockercliVersion=18.09
# Kubernetes Version
export k8sVersion=${_k8sVersion:-'v1.14.2'}
# CNI Version
export cniVersion=${_cni_version:-'v0.7.5'}
# Etcd Version
export etcdVersion=${_etcdVersion:-'3.3.10'}
# Pause Version
export pauseVersion=${_pauseVersion:-'3.1'}
# Calico Version
export calicoVersion=${_calicoVersion:-'v3.7.2'}
# HaProxy Version
export haproxyVersion=${_haproxyVersion:-'2.0.0'}
# CoreDNS Version
export corednsVersion=${_corednsVersion:-'1.5.0'}
# Nginx Ingress
export nginxIngressVersion=${_nginxIngressVersion:-'0.26.1'}

# 数据打包临时路径
export temporaryDirs=${temporaryDirs:-'/tmp'}

# Clean old files
rm -rf  ${temporaryDirs}/image_*.tar.gz | true

CleanPullImage=false isImageExport=true isImagePush=false bash -c ./PublishK8sRegistryImages.sh

cat > ${temporaryDirs}/docker-image-import.sh <<EOF
for i in \$(ls /image_*.tar.gz); do
    docker load -i \$i
done
EOF

chmod +x ${temporaryDirs}/docker-image-import.sh

cat > ${temporaryDirs}/Dockerfile << EOF
FROM docker:${dockercliVersion} as DockerCli

FROM ubuntu:16.04

COPY --from=DockerCli /usr/local/bin/docker /usr/local/bin

RUN apt update && \
    apt install -y wget

RUN wget -qO- "https://dl.k8s.io/${k8sVersion}/kubernetes-node-linux-amd64.tar.gz" | tar zx -C /

RUN mkdir -p /cni && \
    wget -qO- "https://github.com/containernetworking/plugins/releases/download/${cniVersion}/cni-plugins-${_cni_os_drive}-${cniVersion}.tgz" | tar zx -C /cni

RUN wget -qO- "https://pkg.cfssl.org/R1.2/cfssl_linux-amd64" > /cfssl && \
    wget -qO- "https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64" > /cfssljson && \
    chmod +x /cfssl*

COPY ./image_*.tar.gz /

COPY docker-image-import.sh /docker-image-import.sh

EOF

BUILD_VERSION=`awk '/^k8s_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`.`awk '/^build_k8s_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`

cd ${temporaryDirs} && docker build -t ${targetRegistry}/kubernetes:${BUILD_VERSION} .

# Push Images
docker push ${targetRegistry}/kubernetes:${BUILD_VERSION}

if [ $? -ne 0 ]; then
    echo 
    echo "Failure.."
    echo "Please log on to Docker Hub and push to your image warehouse!"
    echo "docker login ..."
    echo
fi