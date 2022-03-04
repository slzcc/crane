## Metrics-server

部署文件内容由官方提供.

```
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yaml
```

内容修改如下:

```
        - --kubelet-insecure-tls
```