SHELL := /bin/bash

DockerHubRepoName := "slzcc"
ProjectName := "crane"
VERSION := "v1.15.0.6"

build:
	@docker build -t ${DockerHubRepoName}/${ProjectName}:$(VERSION) . --no-cache
push:
	@docker push ${DockerHubRepoName}/${ProjectName}:$(VERSION)
run:
	@docker run --rm -i -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub -v ~/.ssh/id_rsa:/root/.ssh/id_rsa -v ./nodes:/crane/nodes -v ./group_vars:/carne/group_vars -w /carne ${DockerHubRepoName}/${ProjectName}:$(VERSION) -i nodes ${CRANE_CMD} -vv