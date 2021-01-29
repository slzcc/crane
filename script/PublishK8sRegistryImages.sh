#!/bin/bash

########
# 删除镜像要比打包镜像优先级高, 所以要打包时不能清除本地镜像切记!
#
# 如果只想把镜像打包到本地请执行:
# CleanPullImage=false isImageExport=true isImagePush=false ./PublishK8sRegistryImages.sh
#
# 如果只想把镜像上传到自定义镜像仓库请执行:
# CleanPullImage=true isImageExport=false isImagePush=true ./PublishK8sRegistryImages.sh
#
# 如果只想把镜像 Pull 下来 请执行:
# CleanPullImage=false isImageExport=false isImagePush=false ./PublishK8sRegistryImages.sh
#########

k8sVersion=${k8sVersion:-'v1.14.2'}
etcdVersion=${etcdVersion:-'3.3.10'}
pauseVersion=${pauseVersion:-'3.2'}
calicoVersion=${calicoVersion:-'v3.7.2'}
haproxyVersion=${haproxyVersion:-'2.0.0'}
corednsVersion=${corednsVersion:-'1.5.0'}
nginxIngressVersion=${nginxIngressVersion:-''}

# Calico Source Registry
calicoRegistry=${calicoRegistry:-'calico'}

# Kubernetes Source Registry
sourceRegistry=${sourceRegistry:-'k8s.gcr.io'}

# Custom Target Registry
targetRegistry=${targetRegistry:-'slzcc'}

CleanPullImage=${CleanPullImage:-'true'}
isImageExport=${isImageExport:-'true'}
isImagePush=${isImagePush:-'true'}

# Temporary Directory
temporaryDirs=${temporaryDirs:-'/tmp'}

# OS
osDrive=${osDrive:-'linux'}
osArch=${osArch:-'amd64'}

# Kubernetes ApiServer、Controller、Scheduler
for i in kube-apiserver kube-controller-manager kube-scheduler kube-proxy; do
    docker pull ${sourceRegistry}/$i:${k8sVersion}

    [ ${isImagePush} == 'true' ] && docker tag ${sourceRegistry}/$i:${k8sVersion} ${targetRegistry}/$i:${k8sVersion} && \
                                    docker push ${targetRegistry}/$i:${k8sVersion}

    [ ${CleanPullImage} == 'true' ] && docker rmi -f ${sourceRegistry}/$i:${k8sVersion} ${targetRegistry}/$i:${k8sVersion}
done

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_kubernetes.tar.gz \
               ${sourceRegistry}/kube-apiserver:${k8sVersion} \
               ${sourceRegistry}/kube-controller-manager:${k8sVersion} \
               ${sourceRegistry}/kube-scheduler:${k8sVersion} \
               ${sourceRegistry}/kube-proxy:${k8sVersion} 

# Etcd
docker pull ${sourceRegistry}/etcd:${etcdVersion}

[ ${isImagePush} == 'true' ] && docker tag ${sourceRegistry}/etcd:${etcdVersion} ${targetRegistry}/etcd:${etcdVersion} && \
                                docker push ${targetRegistry}/etcd:${etcdVersion}

[ ${CleanPullImage} == 'true' ] && \
docker rmi -f ${sourceRegistry}/etcd:${etcdVersion} ${targetRegistry}/etcd:${etcdVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_etcd.tar.gz \
               ${sourceRegistry}/etcd:${etcdVersion}

# Pause
docker pull ${sourceRegistry}/pause:${pauseVersion}

[ ${isImagePush} == 'true' ] && docker tag ${sourceRegistry}/pause:${pauseVersion} ${targetRegistry}/pause:${pauseVersion} && \
                                docker push ${targetRegistry}/pause:${pauseVersion}
[ ${CleanPullImage} == 'true' ] && \
docker rmi -f ${sourceRegistry}/pause:${pauseVersion} ${targetRegistry}/pause:${pauseVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_pause.tar.gz \
               ${sourceRegistry}/pause:${pauseVersion} 
               
# Calico
for i in cni node kube-controllers pod2daemon-flexvol; do
    docker pull ${calicoRegistry}/$i:${calicoVersion}
    
    [ ${isImagePush} == 'true' ] && docker tag ${calicoRegistry}/$i:${calicoVersion} ${targetRegistry}/$i:${calicoVersion} && \
                                    docker push ${targetRegistry}/$i:${calicoVersion}
    [ ${CleanPullImage} == 'true' ] && docker rmi -f ${calicoRegistry}/$i:${calicoVersion} ${targetRegistry}/$i:${calicoVersion}
done

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_calico.tar.gz \
               ${calicoRegistry}/kube-controllers:${calicoVersion} \
               ${calicoRegistry}/cni:${calicoVersion} \
               ${calicoRegistry}/node:${calicoVersion}

# HaProxy
docker pull haproxy:${haproxyVersion}
[ ${CleanPullImage} == 'true' ] && docker rmi -f haproxy:${haproxyVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_haproxy.tar.gz \
               haproxy:${haproxyVersion}

# CoreDNS
docker pull coredns/coredns:${corednsVersion}
[ ${CleanPullImage} == 'true' ] && docker rmi -f coredns/coredns:${corednsVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_coredns.tar.gz \
               coredns/coredns:${corednsVersion}
# Keepalived
docker pull slzcc/keepalived:1.2.24.1
[ ${CleanPullImage} == 'true' ] && docker rmi -f slzcc/keepalived:1.2.24.1

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_keeplived.tar.gz \
               slzcc/keepalived:1.2.24.1

# Nginx Ingress
# docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${nginxIngressVersion}
# [ ${CleanPullImage} == 'true' ] && docker rmi -f quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${nginxIngressVersion}

# [ ${isImageExport} == 'true' ] && \
# docker save -o ${temporaryDirs}/image_nginxingress.tar.gz \
#                quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${nginxIngressVersion}