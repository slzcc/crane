#!/bin/bash

k8sVersion=${K8sVersion:-'v1.14.1'}
etcdVersion=${EtcdVersion:-'3.3.10'}
pauseVersion=${PauseVersion:-'3.1'}

sourceRegistry=${SourceRegistry:-'k8s.gcr.io'}
targetRegistry=${TargetRegistry:-'slzcc'}

# Kubernetes ApiServer、Controller、Scheduler
for i in kube-apiserver-amd64 kube-controller-manager kube-scheduler kube-proxy; do
	docker pull ${sourceRegistry}/$i:${k8sVersion}
	docker tag ${sourceRegistry}/$i:${k8sVersion} ${targetRegistry}/$i:${k8sVersion}
	docker push ${targetRegistry}/$i:${k8sVersion}
	docker rmi -f ${sourceRegistry}/$i:${k8sVersion} ${sourceRegistry}/$i:${k8sVersion}
done

# Etcd
docker pull ${sourceRegistry}/etcd:${etcdVersion}
docker tag ${sourceRegistry}/etcd:${etcdVersion} ${targetRegistry}/etcd:${etcdVersion}
docker push ${targetRegistry}/etcd:${etcdVersion}
docker rmi -f ${sourceRegistry}/etcd:${etcdVersion} ${sourceRegistry}/etcd:${etcdVersion}

# Pause
docker pull ${sourceRegistry}/pause:${pauseVersion}
docker tag ${sourceRegistry}/pause:${pauseVersion} ${targetRegistry}/pause:${pauseVersion}
docker push ${targetRegistry}/pause:${pauseVersion}
docker rmi -f ${sourceRegistry}/pause:${pauseVersion} ${sourceRegistry}/pause:${pauseVersion}