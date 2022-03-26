#!/bin/bash
set -x
# 如果需要部署到自己的私有仓库，请修改此项名称
export targetRegistry=${targetRegistry:-'slzcc'}

_cni_os_drive='linux-amd64'
_IstioVersion=`awk '/^istio_version/{print}' ../crane/group_vars/k8s_cluster/k8s-addons.yaml | awk -F': ' '{print $2}' | sed "s/'//g"`
_dockerVersion=`awk '/^docker_version/{print}' ../crane/roles/cri-install/vars/docker.yaml | awk -F': ' '{print $2}' | sed "s/'//g"`

# Docker Version
export dockercliVersion=${_dockerVersion:-'19.03'}

# Istio Version
export IstioVersion=${_IstioVersion:-'1.8.1'}

# 数据打包临时路径
export temporaryDirs=${temporaryDirs:-'/tmp'}

# Proxy
http_proxy=`awk '/^http_proxy/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}'`
https_proxy=`awk '/^https_proxy/{print}' ../crane/group_vars/all.yml | awk -F': ' '{print $2}'`

# Clean old files
rm -rf  ${temporaryDirs}/image_*.tar.gz | true

CleanPullImage=false isImageExport=true isImagePush=false bash -c ./PublishIstioRegistryImages.sh

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
FROM docker:${dockercliVersion} as DockerCli

FROM slzcc/ansible:demo4 as Packages

ENV http_proxy=${http_proxy} \ 
    https_proxy=${https_proxy}

RUN wget -qO- "https://github.com/istio/istio/releases/download/${IstioVersion}/istio-${IstioVersion}-linux-amd64.tar.gz" | tar zx -C ${temporaryDirs} && \
    mv ${temporaryDirs}/istio-${IstioVersion} ${temporaryDirs}/istio

FROM ubuntu:18.04

COPY --from=DockerCli /usr/local/bin/docker /usr/local/bin
COPY --from=DockerCli /usr/local/bin/ctr /usr/local/bin
COPY --from=Packages ${temporaryDirs}/istio /istio

COPY ./image_*.tar.gz /

COPY docker-image-import.sh /docker-image-import.sh
COPY containerd-image-import.sh /containerd-image-import.sh

EOF

sudo docker build -t ${targetRegistry}/istio:${IstioVersion} ${temporaryDirs}

# Push Images
sudo docker push ${targetRegistry}/istio:${IstioVersion}

if [ $? -ne 0 ]; then
    echo 
    echo "Failure.."
    echo "Please log on to Docker Hub and push to your image warehouse!"
    echo "docker login ..."
    echo
fi
