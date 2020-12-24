# REMOVE CLUSTER

清除当前 Crane 安装的项目。

默认会清除所安装的所有项目, 但不会清除临时目录 `/tmp/crane`, 参照 `@crane/roles/clean-install/defaults/main.yml` 。

如果不需要清除所有项目, 修改:

```
is_remove_all: false
```

并根据其他选项自定义删除即可。

启动清除命令为:

```
$ make clean_main
```