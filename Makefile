SHELL := /bin/bash

DockerHubRepoName := "slzcc"
ProjectName := "crane"
VERSION := `awk '/^k8s_version/' ./group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`.`awk '/^build_k8s_version/{print}' ./group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`
DOCKER_VERSION := `awk '/^docker_version/' ./group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`
CRANE_ENTRANCE := "main.yml"
OPTION := "-vv"

build:
	@docker build -t ${DockerHubRepoName}/${ProjectName}:${VERSION} . --no-cache
		
push:
	@docker push ${DockerHubRepoName}/${ProjectName}:${VERSION}

run_main:
	@docker rm -f crane || true
	@docker run --name crane --rm -i -e ANSIBLE_HOST_KEY_CHECKING=true -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes ${CRANE_ENTRANCE} ${OPTION}

clean_main:
	@docker rm -f crane || true
	@docker run --name crane --rm -i -e ANSIBLE_HOST_KEY_CHECKING=true -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes remove_cluster.yml -vv

local_save_image:
	@docker pull slzcc/kubernetes:${VERSION}
	@docker save -o roles/downloads-packages/files/kubernetes.tar.gz slzcc/kubernetes:${VERSION}

local_load_image:
	@docker run --name import-kubernetes-temporary -d -v /var/run/docker.sock:/var/run/docker.sock:ro slzcc/kubernetes:${VERSION} sleep 1234567
	@until docker exec -i import-kubernetes-temporary bash /docker-image-import.sh ; do >&2 echo "Starting..." && sleep 1 ; done
	@docker rm -f import-kubernetes-temporary

local_load_dockerd:
	@docker run --rm -i -e DOCKER_VERSION=${DOCKER_VERSION} -v ${PWD}/roles/docker-install/files:/docker_bin -w /usr/local/bin docker:${DOCKER_VERSION} sh -c "tar zcf /docker_bin/docker-${DOCKER_VERSION}.tar.gz containerd  containerd-shim  ctr  docker  dockerd  docker-entrypoint.sh  docker-init  docker-proxy runc"

run_simple:
	@docker rm -f crane || true
	@docker run --name crane --net kube-simple --rm -i -e ANSIBLE_HOST_KEY_CHECKING=true -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane ${DockerHubRepoName}/${ProjectName}:${VERSION} -i kube-simple/nodes ${CRANE_ENTRANCE} ${OPTION}

clean_simple:
	@docker rm -f crane || true
	@docker run --name crane --net kube-simple --rm -i -e ANSIBLE_HOST_KEY_CHECKING=true -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane ${DockerHubRepoName}/${ProjectName}:${VERSION} -i kube-simple/nodes remove_cluster.yml -vv
