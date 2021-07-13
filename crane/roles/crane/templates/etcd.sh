#!/bin/bash

{{ kubernetes_ctl_path }}docker run --net host --rm -it \
            -e ETCDCTL_ENDPOINTS=https://127.0.0.1:2379 \
            -e ETCDCTL_CACERT={{ etcd_ssl_dirs }}etcd-ca.pem \
            -e ETCDCTL_KEY={{ etcd_ssl_dirs }}etcd-key.pem \
            -e ETCDCTL_CERT={{ etcd_ssl_dirs }}etcd.pem \
            -e ETCDCTL_API=3 \
            -v {{ etcd_ssl_dirs }}:{{ etcd_ssl_dirs }} \
            -w {{ etcd_ssl_dirs }} \
            {{ k8s_cluster_component_registry }}/etcd:{{ etcd_version }} sh

{{ kubernetes_ctl_path }}docker run --name crane-etcd-backup-to-clean --rm -i -v {{ etcd_ssl_dirs }}:{{ etcd_ssl_dirs }} -v {{ temporary_dirs }}:{{ temporary_dirs }} -w {{ temporary_dirs }}etcdb {{ k8s_cluster_component_registry }}/etcd:{{ etcd_version }} \
    etcdctl --cacert {{ etcd_ssl_dirs }}etcd-ca.pem \
            --key {{ etcd_ssl_dirs }}etcd-key.pem \
            --cert {{ etcd_ssl_dirs }}etcd.pem \
            --endpoints {{ etcd_cluster_str.split(",")[0] }} \
            snapshot save snapshot-`date +%Y%m%d%H%M%S`.db