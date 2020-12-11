SHELL := /bin/bash

DockerHubRepoName := "slzcc"
ProjectName := "crane"
VERSION := `awk '/^k8s_version/' ./crane/group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`.`awk '/^build_k8s_version/{print}' ./crane/group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`
DOCKER_VERSION := `awk '/^docker_version/' ./crane/roles/cri-install/vars/docker.yaml | awk -F': ' '{print $$2}' | sed "s/'//g"`
CRIO_VERSION := `awk '/^crio_version/' ./crane/roles/cri-install/vars/crio.yaml | awk -F': ' '{print $$2}' | sed "s/'//g"`
CONTAINERD_VERSION := `awk '/^containerd_version/' ./crane/roles/cri-install/vars/containerd.yaml | awk -F': ' '{print $$2}' | sed "s/'//g"`

# Tasks: add_etcd.yml
#        add_nodes.yml
#        k8s_certificate_rotation.yml
#        remove_cluster.yml
#        remove_k8s_nodes.yml
#        remove_etcd_nodes.yml
#        upgrade_version.yml
#        add_master.yml
#        etcd_certificate_rotation.yml
#        main.yml
#        test.yml
CRANE_ENTRANCE := main.yml
OPTION := -vv --tags cri

build:
	@docker build -t ${DockerHubRepoName}/${ProjectName}:${VERSION} . --no-cache
	
push:
	@docker push ${DockerHubRepoName}/${ProjectName}:${VERSION}

push_other:
	@docker tag ${DockerHubRepoName}/${ProjectName}:${VERSION} docker.pkg.github.com/${DockerHubRepoName}/${ProjectName}/${ProjectName}:${VERSION}
	@docker push docker.pkg.github.com/${DockerHubRepoName}/${ProjectName}/${ProjectName}:${VERSION}
	@docker rmi -f docker.pkg.github.com/${DockerHubRepoName}/${ProjectName}/${ProjectName}:${VERSION}

run_main:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes ${CRANE_ENTRANCE} ${OPTION}

run_test:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes test.yml -vv

local_load_dockerd:
	@wget -qO- https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz > ${PWD}/crane/roles/cri-install/files/docker-${DOCKER_VERSION}.tar.gz

# Ready to scrap
local_load_dockerd_old:
	@docker run --rm -i -e DOCKER_VERSION=${DOCKER_VERSION} -v ${PWD}/crane/roles/docker-install/files:/docker_bin -w /usr/local/bin docker:${DOCKER_VERSION} sh -c "tar zcf /docker_bin/docker-${DOCKER_VERSION}.tar.gz containerd  containerd-shim  ctr  docker  dockerd  docker-entrypoint.sh  docker-init  docker-proxy runc"

run_simple:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net kube-simple --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i ../kube-simple/nodes ${CRANE_ENTRANCE} ${OPTION}

clean_simple:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net kube-simple --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i ../kube-simple/nodes remove_cluster.yml ${OPTION}

clean_main:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes remove_cluster.yml ${OPTION}

local_save_image:
	@docker pull slzcc/kubernetes:${VERSION}
	@docker save -o crane/roles/downloads-packages/files/kubernetes.tar.gz slzcc/kubernetes:${VERSION}

local_load_image:
	@docker run --name import-kubernetes-temporary -d -v /var/run/docker.sock:/var/run/docker.sock:ro slzcc/kubernetes:${VERSION} sleep 1234567
	@until docker exec -i import-kubernetes-temporary bash /docker-image-import.sh ; do >&2 echo "Starting..." && sleep 1 ; done
	@docker rm -f import-kubernetes-temporary

local_load_crio: local_load_containerd
	@wget -qO- https://storage.googleapis.com/k8s-conform-cri-o/artifacts/crio-${CRIO_VERSION}.tar.gz > ${PWD}/crane/roles/cri-install/files/crio-${CRIO_VERSION}.tar.gz

local_load_containerd: local_load_crio
	@wget -qO- https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz > ${PWD}/crane/roles/cri-install/files/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
