# Local Binary

离线安装 Docker 支持, 但需要本地存在 Docker Binary 包, 可以通过如下方式创建: （19.03 version）
```
$ DOCKER_VERSION=`awk '/^docker_version/' ./group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
$ docker run --rm -i -e DOCKER_VERSION=${DOCKER_VERSION} -v ${PWD}/roles/docker-install/files:/docker_bin -w /usr/local/bin docker:${DOCKER_VERSION} sh -c 'tar zcf /docker_bin/docker-${DOCKER_VERSION}.tar.gz containerd  containerd-shim  ctr  docker  dockerd  docker-entrypoint.sh  docker-init  docker-proxy  modprobe  runc' 
```

然后修改 `docker_install_type` 为 `local_binary` 即可。