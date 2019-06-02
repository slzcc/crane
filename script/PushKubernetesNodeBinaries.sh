#!/bin/bash
set -xe

k8sVersion=${K8sVersion:-'v1.14.2'}
etcdVersion=${EtcdVersion:-'3.3.10'}
pauseVersion=${PauseVersion:-'3.1'}
calicoVersion=${calicoVersion:-'v3.7.2'}
haproxyVersion=${haproxyVersion:-'1.9.6'}

targetRegistry=${TargetRegistry:-'slzcc'}

CleanPullImage=false 
isImageExport=true 
isImagePush=false

exec ./PublishK8sRegistryImages.sh


cat > /tmp/Dockerfile << EOF
FROM ubuntu:16.04

RUN apt update && \
    apt install -y wget

RUN wget -qO- "https://dl.k8s.io/${k8sVersion}/kubernetes-node-linux-amd64.tar.gz" | tar zx -C /

RUN mkdir -p /cni && \
    wget -qO- "https://github.com/containernetworking/plugins/releases/download/${cniVersion}/cni-plugins-amd64-${cniVersion}.tgz" | tar zx -C /cni

COPY ./*.tar.gz /
EOF

cd /tmp && docker build -t ${targetRegistry}/kubernetes:${k8sVersion} .

docker push ${targetRegistry}/kubernetes:${k8sVersion}