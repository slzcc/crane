#!/bin/bash

PUSH_OTHER_REGISTRY_CHECK_PERFORM=${PUSH_OTHER_REGISTRY_CHECK_PERFORM:-'false'}
targetRegistry=${targetRegistry:-'slzcc'}
BUILD_VERSION=${BUILD_VERSION:-''}

if [ "${PUSH_OTHER_REGISTRY_CHECK_PERFORM}" == "true" ]; then

    docker tag ${targetRegistry}/kubernetes:${BUILD_VERSION} \
               docker.pkg.github.com/${targetRegistry}/crane/kubernetes:${BUILD_VERSION}
    docker tag ${targetRegistry}/kubernetes:${BUILD_VERSION} \
               registry.cn-beijing.aliyuncs.com/slzcc/kubernetes:${BUILD_VERSION}
    docker tag ${targetRegistry}/kubernetes:${BUILD_VERSION} \
               registry.cn-hangzhou.aliyuncs.com/slzcc/kubernetes:${BUILD_VERSION}

    docker push docker.pkg.github.com/${targetRegistry}/crane/kubernetes:${BUILD_VERSION}

    docker push registry.cn-beijing.aliyuncs.com/{targetRegistry}/kubernetes:${BUILD_VERSION}

    docker push registry.cn-hangzhou.aliyuncs.com/${targetRegistry}/kubernetes:${BUILD_VERSION}

    docker rmi -f docker.pkg.github.com/${targetRegistry}/crane/kubernetes:${BUILD_VERSION}

    docker rmi -f registry.cn-beijing.aliyuncs.com/${targetRegistry}/kubernetes:${BUILD_VERSION}

    docker rmi -f registry.cn-hangzhou.aliyuncs.com/${targetRegistry}/kubernetes:${BUILD_VERSION}
fi