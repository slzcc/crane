# ETCD BACKUP CLUSTER

主要作用备份集群数据为 snapshot 文件。

## Configure

在 `nodes` 文件中, 备份至涉及到 `[etcd]` 中的第一个。

```
[etcd]
35.200.23.39
...

```

备份时, 备份文件会归档到默认 `/tmp/crane/etcdb` 以时间戳的形式保存。

## 执行

上述配置准备好后准备执行命令:

```
$ make run_etcd_backup
```

## 检测

登入到 `etcd[0]` 示例查看:

```
$ ls -l /tmp/crane/etcdb/
total 75124
-rw------- 1 root root  9674784 May 14 06:49 snapshot-20210514064901.db
-rw------- 1 root root  9674784 May 14 09:18 snapshot-20210514091829.db
-rw------- 1 root root  5693472 May 14 09:57 snapshot-20210514095751.db
-rw------- 1 root root  8777760 May 14 10:26 snapshot-20210514102620.db
-rw------- 1 root root  5832736 May 14 12:36 snapshot-20210514123649.db
-rw------- 1 root root  8032288 May 14 13:01 snapshot-20210514130154.db
-rw------- 1 root root  3760160 May 14 13:09 snapshot-20210514130918.db
-rw------- 1 root root  3682336 May 14 13:23 snapshot-20210514132324.db
-rw------- 1 root root 10367008 May 17 02:17 snapshot-20210517021734.db
-rw------- 1 root root 11391008 May 17 07:07 snapshot-20210517070708.db
...
```