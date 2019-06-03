# 离线部署

当需要使用离线部署方式时, 则需要保证 files 目录下有用 kubernetes.tar.gz 文件, 此文件用以下方式获得:
```
$ docker pull slzcc/kubernetes:{{ k8s_version }}
$ docker save -o roles/downloads-packages/files/kubernetes.tar.gz slzcc/kubernetes:{{ k8s_version }}
```

此时需要保证 all.yml 文件中 `is_using_local_files_deploy` 为 `true` 并且 `is_kube_master_schedule` 为 `false` 才会使用本地文件进行部署.

> 此方式会造成大量的网络 IO 阻塞, 所以非局域网环境不建议使用.