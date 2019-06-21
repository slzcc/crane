#!/bin/bash

_k8sVersion=`awk '/k8s_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed -r "s/'//g"`
_cni_version=`awk '/cni_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed -r "s/'//g"`
_etcdVersion=`awk '/etcd_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed -r "s/'//g"`
_pauseVersion=`awk '/pause_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed -r "s/'//g"`
_calicoVersion=`awk '/calico_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed -r "s/'//g"`
_haproxyVersion=`awk '/haproxy_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed -r "s/'//g"`
_corednsVersion=`awk '/dns_version/{print}' ../group_vars/all.yml | awk -F': ' '{print $2}' | sed -r "s/'//g"`

export dockercliVersion=18.09

export k8sVersion=${_k8sVersion:-'v1.14.2'}
export cniVersion=${_cni_version:-'v0.7.5'}

export etcdVersion=${_etcdVersion:-'3.3.10'}
export pauseVersion=${_pauseVersion:-'3.1'}
export calicoVersion=${_calicoVersion:-'v3.7.2'}
export haproxyVersion=${_haproxyVersion:-'2.0.0'}
export corednsVersion=${_corednsVersion:-'1.5.0'}

export targetRegistry=${targetRegistry:-'slzcc'}

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
    wget -qO- "https://github.com/containernetworking/plugins/releases/download/${cniVersion}/cni-plugins-amd64-${cniVersion}.tgz" | tar zx -C /cni

RUN wget -qO- "https://pkg.cfssl.org/R1.2/cfssl_linux-amd64" > /cfssl && \
    wget -qO- "https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64" > /cfssljson && \
    chmod +x /cfssl*

COPY ./image_*.tar.gz /

COPY docker-image-import.sh /docker-image-import.sh

EOF

cd ${temporaryDirs} && docker build -t ${targetRegistry}/kubernetes:${k8sVersion} .

docker push ${targetRegistry}/kubernetes:${k8sVersion}