SHELL := /bin/bash

DockerHubRepoName := "slzcc"
ProjectName := "crane"
VERSION := "v1.15.0.6"

build:
	@docker build -t ${DockerHubRepoName}/${ProjectName}:$(VERSION) . --no-cache
push:
	@docker push ${DockerHubRepoName}/${ProjectName}:$(VERSION)
run:
	@docker run --rm -i -v ./node:/crane -v ./group_vars:/carne/group_vars -w /carne ${DockerHubRepoName}/${ProjectName}:$(VERSION) -i nodes ${CRANE_CMD} -vv