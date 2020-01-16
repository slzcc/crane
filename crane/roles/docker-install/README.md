# Dockerd install

支持三种模式:
* http_script
* http_binary
* local_binary

## Http Script

通过官方脚本执行 https://get.docker.com

## Http Binary

通过已经封装好的 Dockerd 压缩包部署, 压缩方式是通过 local binary 获取的。

> 需要注意的是 http_binary 需要通过某个地址下载, 则这个地址通过 docker_install_http_binary_source 传入

## Local Binary

离线安装 Docker 支持, 但需要本地存在 Docker Binary 包, 可以通过如下方式创建:
```
$ DOCKER_VERSION=`awk '/^docker_version/' ./group_vars/all.yml | awk -F': ' '{print $2}' | sed "s/'//g"`
$ docker run --rm -i -e DOCKER_VERSION=${DOCKER_VERSION} -v ${PWD}/roles/docker-install/files:/docker_bin -w /usr/local/bin docker:${DOCKER_VERSION} sh -c 'tar zcf /docker_bin/docker-${DOCKER_VERSION}.tar.gz containerd  containerd-shim  ctr  docker  dockerd  docker-entrypoint.sh  docker-init  docker-proxy  runc'
```

然后修改 `docker_install_type` 为 `local_binary` 即可。