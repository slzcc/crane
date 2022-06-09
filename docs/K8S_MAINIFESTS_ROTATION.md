# K8S MAINIFESTS ROTATION

对现有的 Master 节点更新 `haproxy`、`kube-apiserver`、`kube-controller-manager`、`kube-scheduler` 启动文件, 主要目的是对需要修改的配置进行补充更新。


执行命令如下:

```
$ make run_k8s_mainifests_rotation
```