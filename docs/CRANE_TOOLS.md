# Crane Tools

此工具主要是方便 Local 等环境下使用的工具, 比如直接安装 docker 等, 方便后续操作.

# CRI install

当前主机可以通过脚本直接安装 CRI.

### Docker install

此方式安装的 docker 适用属于默认安装，唯一不同的是 containerd 使用的是 default 模式.

> 此脚本只能在当前目录下执行, 因为需要加载 crane_env 环境变量

```
$ ./crane docker install
```

# Not Ansible in Docker

因默认使用 Ansible in Docker 模式部署, 如果不需要则执行 .crane_env 文件后本地使用 Makefile 中的 ansibe-playbook 命令执行即可.