# Local Binary

离线安装 Docker 支持, 但需要本地存在 Docker Binary 包, 可以通过如下方式创建:
```
$ docker run --rm -it -v ${PWD}/roles/docker-install/files:/docker_bin -v /usr/bin docker:{{ docker_version }} sh -c 'tar zcf /docker_bin/docker-{{ docker_version }}.tar.gz containerd  containerd-shim  ctr  docker  dockerd  docker-entrypoint.sh  docker-init  docker-proxy  modprobe  runc'
$ 
```