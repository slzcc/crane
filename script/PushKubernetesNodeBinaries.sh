#!/bin/bash

# 如果需要部署到自己的私有仓库，请修改此项名称
export targetRegistry=${targetRegistry:-'slzcc'}

_cri_driver=`awk '/^cri_driver/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`

_cni_os_drive='linux-amd64'
_dockerVersion=`awk '/^docker_version/{print}' ../crane/roles/cri-install/vars/docker.yaml | awk -F': ' '{print $2}' | sed "s/'//g"`
_k8sVersion=`awk '/^k8s_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_cni_version=`awk '/^cni_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_etcdVersion=`awk '/^etcd_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_pauseVersion=`awk '/^pause_version/{print}' ../crane/roles/kubernetes-manifests/defaults/main.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_calicoVersion=`awk '/^calico_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_haproxyVersion=`awk '/^haproxy_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_corednsVersion=`awk '/^dns_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_nginxIngressVersion=`awk '/^ingress_nginx_version/{print}' ../crane/roles/kubernetes-addons/defaults/main.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
_ciliumVersion=`awk '/^cilium_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`

sourceRegistry=`awk '/^k8s_cluster_component_registry/{print}' ../crane/crane/roles/kubernetes-manifests/defaults/main.yml | awk -F': ' '{print $2}' | sed "s/'//g"`

# Docker Version
export dockercliVersion=${_dockerVersion:-'19.03'}
# Kubernetes Version
export k8sVersion=${_k8sVersion:-'v1.14.2'}
# CNI Version
export cniVersion=${_cni_version:-'v0.7.5'}
# Etcd Version
export etcdVersion=${_etcdVersion:-'3.3.10'}
# Pause Version
export pauseVersion=${_pauseVersion:-'3.2'}
# Calico Version
export calicoVersion=${_calicoVersion:-'v3.7.2'}
# HaProxy Version
export haproxyVersion=${_haproxyVersion:-'2.0.0'}
# CoreDNS Version
export corednsVersion=${_corednsVersion:-'1.8.3'}
# Nginx Ingress
export nginxIngressVersion=${_nginxIngressVersion:-'0.26.1'}
# Cilium Version
export ciliumVersion=${_ciliumVersion:-'v1.11.5'}
# 数据打包临时路径
export temporaryDirs=${temporaryDirs:-'/tmp'}

# Proxy
http_proxy=`awk '/^http_proxy/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}'`
https_proxy=`awk '/^https_proxy/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}'`

# Clean old files
rm -rf  ${temporaryDirs}/image_*.tar.gz | true

CleanPullImage=false isImageExport=true isImagePush=false bash -cx ./PublishK8sRegistryImages.sh

cat > ${temporaryDirs}/docker-image-import.sh <<EOF
for i in \$(ls /image_*.tar.gz); do
    docker load -i \$i
done
EOF

cat > ${temporaryDirs}/containerd-image-import.sh <<EOF
for i in \$(ls /image_*.tar.gz); do
    ctr -n k8s.io i import \$i
done
EOF

chmod +x ${temporaryDirs}/docker-image-import.sh ${temporaryDirs}/containerd-image-import.sh

cat > ${temporaryDirs}/Dockerfile << EOF
FROM quay.io/cilium/cilium:${ciliumVersion} as CiliumCli

FROM docker:${dockercliVersion} as DockerCli

FROM slzcc/ansible:demo4 as Packages

ENV http_proxy=${http_proxy} \ 
    https_proxy=${https_proxy}

RUN wget -qO- "https://dl.k8s.io/${k8sVersion}/kubernetes-server-${_cni_os_drive}.tar.gz" | tar zx -C /

RUN mkdir -p /cni && \
    wget -qO- "https://github.com/containernetworking/plugins/releases/download/${cniVersion}/cni-plugins-${_cni_os_drive}-${cniVersion}.tgz" | tar zx -C /cni

RUN wget -qO- "https://pkg.cfssl.org/R1.2/cfssl_${_cni_os_drive}" > /cfssl && \
    wget -qO- "https://pkg.cfssl.org/R1.2/cfssljson_${_cni_os_drive}" > /cfssljson && \
    chmod +x /cfssl*

RUN wget -qO- https://github.com/etcd-io/etcd/releases/download/v${etcdVersion%-*}/etcd-v${etcdVersion%-*}-${_cni_os_drive}.tar.gz | tar -zx -C / && \
    mv /etcd-v${etcdVersion%-*}-${_cni_os_drive}/etcd* /

FROM ubuntu:18.04

COPY --from=DockerCli /usr/local/bin/docker /usr/local/bin
COPY --from=DockerCli /usr/local/bin/ctr /usr/local/bin
COPY --from=Packages /kubernetes /kubernetes
COPY --from=Packages /cni /cni
COPY --from=Packages /cfssl /cfssl
COPY --from=Packages /cfssljson /cfssljson
COPY --from=Packages /etcd /etcd
COPY --from=Packages /etcdctl /etcdctl
COPY --from=CiliumCli /usr/bin/cilium /cilium

COPY ./image_*.tar.gz /

COPY docker-image-import.sh /docker-image-import.sh
COPY containerd-image-import.sh /containerd-image-import.sh

EOF

export BUILD_VERSION=`awk '/^k8s_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`.`awk '/^build_k8s_version/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`

sudo docker build -t ${targetRegistry}/kubernetes:${BUILD_VERSION} ${temporaryDirs}

# Push Images
sudo docker push ${targetRegistry}/kubernetes:${BUILD_VERSION}

if [ $? -ne 0 ]; then
    echo 
    echo "Failure.."
    echo "Please log on to Docker Hub and push to your image warehouse!"
    echo "docker login ..."
    echo
fi

# Push Other Registry
# export PUSH_OTHER_REGISTRY_CHECK_PERFORM=true
# ./PushOtherWarehouse.sh

./PushIstioNodeBinaries.sh

