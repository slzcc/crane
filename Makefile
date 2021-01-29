SHELL := /bin/bash

DockerHubRepoName := "slzcc"
ProjectName := "crane"
VERSION := `awk '/^k8s_version/' ./crane/group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`.`awk '/^build_k8s_version/{print}' ./crane/group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`
DOCKER_VERSION := `awk '/^docker_version/' ./crane/roles/cri-install/vars/docker.yaml | awk -F': ' '{print $$2}' | sed "s/'//g"`
CRIO_VERSION := `awk '/^crio_version/' ./crane/roles/cri-install/vars/crio.yaml | awk -F': ' '{print $$2}' | sed "s/'//g"`
CONTAINERD_VERSION := `awk '/^containerd_version/' ./crane/roles/cri-install/vars/containerd.yaml | awk -F': ' '{print $$2}' | sed "s/'//g"`
CRITOOLS_VERSION := `awk '/^cri_tools_version/' ./crane/roles/cri-install/vars/cri-tools.yaml | awk -F': ' '{print $$2}' | sed "s/'//g"`
OS_DRIVE := `awk '/^os_drive/' ./crane/group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`
OS_ARCH := `awk '/^os_arch/' ./crane/group_vars/all.yml | awk -F': ' '{print $$2}' | sed "s/'//g"`

ifeq ($(OS_ARCH), amd64)
OS_ARCH_NAME := 'x86_64'
else
OS_ARCH_NAME := 'aarch64'
endif

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
OPTION :=

build:
	@docker build -t ${DockerHubRepoName}/${ProjectName}:${VERSION} . --no-cache --pull
	
push:
	@docker push ${DockerHubRepoName}/${ProjectName}:${VERSION}

push_other:
	@docker tag ${DockerHubRepoName}/${ProjectName}:${VERSION} docker.pkg.github.com/${DockerHubRepoName}/${ProjectName}/${ProjectName}:${VERSION}
	@docker push docker.pkg.github.com/${DockerHubRepoName}/${ProjectName}/${ProjectName}:${VERSION}
	@docker rmi -f docker.pkg.github.com/${DockerHubRepoName}/${ProjectName}/${ProjectName}:${VERSION}

run_main:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes ${CRANE_ENTRANCE} ${OPTION}

run_main_cri:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes main.yml --tags cri ${OPTION}

run_main_crane:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes main.yml --tags crane ${OPTION}

run_addons:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes main.yml --tags k8s-addons

run_add_etcd:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes add_etcd.yml ${OPTION}

run_add_master:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes add_master.yml ${OPTION}

run_add_nodes:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg -w /crane/crane  ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes add_nodes.yml ${OPTION}

run_k8s_upgrade:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes upgrade_version.yml ${OPTION}

run_test:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net host --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes test.yml -vv

run_simple:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net kube-simple --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i ../kube-simple/nodes ${CRANE_ENTRANCE} ${OPTION}

clean_simple:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --net kube-simple --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i ../kube-simple/nodes remove_cluster.yml ${OPTION}

clean_main:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes remove_cluster.yml ${OPTION}

remove_k8s_nodes:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes remove_k8s_nodes.yml ${OPTION}

remove_etcd_nodes:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes remove_etcd_nodes.yml ${OPTION}

rotation_k8s_ca:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes k8s_certificate_rotation.yml ${OPTION}

rotation_etcd_ca:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes etcd_certificate_rotation.yml ${OPTION}

local_load_dockerd: local_load_containerd
	@wget -qO- https://download.docker.com/linux/static/stable/${OS_ARCH_NAME}/docker-${DOCKER_VERSION}.tgz > ${PWD}/crane/roles/downloads-packages/files/docker-${DOCKER_VERSION}.tar.gz

# Ready to scrap
local_load_dockerd_old:
	@docker run --rm -i -e DOCKER_VERSION=${DOCKER_VERSION} -v ${PWD}/crane/roles/docker-install/files:/docker_bin -w /usr/local/bin docker:${DOCKER_VERSION} sh -c "tar zcf /docker_bin/docker-${DOCKER_VERSION}.tar.gz containerd  containerd-shim  ctr  docker  dockerd  docker-entrypoint.sh  docker-init  docker-proxy runc"

local_save_image:
	@docker pull slzcc/kubernetes:${VERSION}
	@docker save -o crane/roles/downloads-packages/files/kubernetes.tar.gz slzcc/kubernetes:${VERSION}

local_load_image:
	@docker run --name import-kubernetes-temporary -d -v /var/run/docker.sock:/var/run/docker.sock:ro slzcc/kubernetes:${VERSION} sleep 1234567
	@until docker exec -i import-kubernetes-temporary bash /docker-image-import.sh ; do >&2 echo "Starting..." && sleep 1 ; done
	@docker rm -f import-kubernetes-temporary

local_load_crio: local_load_runc
	@wget -qO- https://storage.googleapis.com/k8s-conform-cri-o/artifacts/crio-${CRIO_VERSION}.tar.gz > ${PWD}/crane/roles/downloads-packages/files/crio-${CRIO_VERSION}.tar.gz

local_load_containerd: local_load_runc
	@wget -qO- https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-${OS_DRIVE}-${OS_ARCH}.tar.gz > ${PWD}/crane/roles/downloads-packages/files/containerd-${CONTAINERD_VERSION}-${OS_DRIVE}-${OS_ARCH}.tar.gz

local_load_runc: local_load_critools
	@wget -qO- https://github.com/opencontainers/runc/releases/download/v1.0.0-rc92/runc.amd64 > ${PWD}/crane/roles/downloads-packages/files/runc

local_load_critools: 
	@wget -qO- https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRITOOLS_VERSION}/crictl-${CRITOOLS_VERSION}-${OS_DRIVE}-${OS_ARCH}.tar.gz > ${PWD}/crane/roles/downloads-packages/files/crictl-${CRITOOLS_VERSION}.tar.gz

local_load_cri: local_load_dockerd local_load_crio

test_main:
	@docker rm -f crane > /dev/null 2>&1 || true
	@docker run --name crane --rm -it -e ANSIBLE_HOST_KEY_CHECKING=false -e TERM=xterm-256color -e COLUMNS=238 -e LINES=61 -v ~/.ssh:/root/.ssh -v ${PWD}:/crane -w /crane/crane -v ${PWD}/crane/ansible.cfg:/etc/ansible/ansible.cfg ${DockerHubRepoName}/${ProjectName}:${VERSION} -i nodes test.yml ${OPTION}

	