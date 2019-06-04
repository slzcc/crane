#!/bin/bash

export k8sVersion=${k8sVersion:-'v1.14.2'}
export cniVersion=${cniVersion:-'v0.7.5'}

export etcdVersion=${cniVersion:-'3.3.10'}
export pauseVersion=${pauseVersion:-'3.1'}
export calicoVersion=${calicoVersion:-'v3.7.2'}
export haproxyVersion=${haproxyVersion:-'1.9.6'}
export corednsVersion=${corednsVersion:-'v1.5.0'}

export targetRegistry=${targetRegistry:-'slzcc'}

export temporaryDirs=${temporaryDirs:-'/tmp'}

export CleanPullImage=false 
export isImageExport=true 
export isImagePush=false

# Clean old files

rm -rf  ${temporaryDirs}/image_*.tar.gz | true

bash -c ./PublishK8sRegistryImages.sh


cat > ${temporaryDirs}/docker-image-import.sh <<EOF
for i in \$(ls /*.tar.gz); do
    docker load -i \$i
done
EOF

chmod +x ${temporaryDirs}/docker-image-import.sh

cat > ${temporaryDirs}/Dockerfile << EOF
FROM docker:18.09 as DockerCli

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