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

IstioVersion=${IstioVersion:-'1.8.1'}
GrafanaVersion=${GrafanaVersion:-'7.0.5'}
JaegertracingVersion=${JaegertracingVersion:-'1.18'}
kialiVersion=${kialiVersion:-'v1.22'}
PrometheusVersion=${PrometheusVersion:-'v2.19.2'}

# Kubernetes Source Registry
sourceRegistry=${sourceRegistry:-'istio'}

# Custom Target Registry
targetRegistry=${targetRegistry:-'slzcc'}

CleanPullImage=${CleanPullImage:-'true'}
isImageExport=${isImageExport:-'false'}
isImagePush=${isImagePush:-'true'}

# Temporary Directory
temporaryDirs=${temporaryDirs:-'/tmp'}

# Istio
for i in proxyv2 pilot; do
    docker pull ${sourceRegistry}/$i:${IstioVersion}
    
    # [ ${isImagePush} == 'true' ] && docker tag ${sourceRegistry}/$i:${IstioVersion} ${targetRegistry}/$i:${IstioVersion} && \
    #                                 docker push ${targetRegistry}/$i:${IstioVersion}

    # [ ${CleanPullImage} == 'true' ] && docker rmi -f ${sourceRegistry}/$i:${IstioVersion} ${targetRegistry}/$i:${IstioVersion}
done

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_istio.tar.gz \
               ${sourceRegistry}/proxyv2:${IstioVersion} \
               ${sourceRegistry}/pilot:${IstioVersion} \

# Grafana
docker pull grafana/grafana:${GrafanaVersion}

# [ ${isImagePush} == 'true' ] && docker tag grafana/grafana:${GrafanaVersion} ${targetRegistry}/grafana:${GrafanaVersion} && \
#                                 docker push ${targetRegistry}/grafana:${GrafanaVersion}

# [ ${CleanPullImage} == 'true' ] && \
# docker rmi -f ${sourceRegistry}/grafana:${GrafanaVersion} ${targetRegistry}/grafana:${GrafanaVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_grafana.tar.gz \
               ${sourceRegistry}/grafana:${GrafanaVersion}
               
# Jaegertracing
docker pull jaegertracing/all-in-one:${JaegertracingVersion}

# [ ${isImagePush} == 'true' ] && docker tag jaegertracing/all-in-one:${JaegertracingVersion} ${targetRegistry}/all-in-one:${JaegertracingVersion} && \
#                                 docker push ${targetRegistry}/all-in-one:${JaegertracingVersion}
# [ ${CleanPullImage} == 'true' ] && \
# docker rmi -f jaegertracing/all-in-one:${JaegertracingVersion} ${targetRegistry}/all-in-one:${JaegertracingVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_jaegertracing.tar.gz \
               jaegertracing/all-in-one:${JaegertracingVersion} 
                  
# Kiali
docker pull quay.io/kiali/kiali:${kialiVersion}
# [ ${CleanPullImage} == 'true' ] && docker rmi -f quay.io/kiali/kiali:${kialiVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_kiali.tar.gz \
               quay.io/kiali/kiali:${kialiVersion}

# Prometheus
docker pull prom/prometheus:${PrometheusVersion}
# [ ${CleanPullImage} == 'true' ] && docker rmi -f prom/prometheus:${PrometheusVersion}

[ ${isImageExport} == 'true' ] && \
docker save -o ${temporaryDirs}/image_prometheus.tar.gz \
               prom/prometheus:${PrometheusVersion}
