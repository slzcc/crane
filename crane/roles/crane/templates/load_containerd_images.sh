#!/bin/bash
set -x

{{ kubernetes_ctl_path }}ctr -n k8s.io tasks kill -a --signal 9 import-kubernetes-temporary

{{ kubernetes_ctl_path }}ctr -n k8s.io tasks rm import-kubernetes-temporary

{{ kubernetes_ctl_path }}ctr -n k8s.io c rm import-kubernetes-temporary

rm -rf /run/containerd/runc/k8s.io/import-kubernetes-temporary

ctr -n k8s.io run --null-io --net-host -d \
       --label name=import-kubernetes-temporary \
       --mount type=bind,src=/var/run,dst=/var/run,options=rbind:ro \
       --mount type=bind,src=/run,dst=/run,options=rbind:ro \
       {{ k8s_image_deploy_repo }}:{{ k8s_version }}.{{ build_k8s_version }} import-kubernetes-temporary sleep 1234567

{{ kubernetes_ctl_path }}ctr -n k8s.io tasks exec --exec-id $({{ kubernetes_ctl_path }}ctr -n k8s.io tasks list | grep 'import-kubernetes-temporary'| awk '{print $2}') import-kubernetes-temporary bash /containerd-image-import.sh
                            
{{ kubernetes_ctl_path }}ctr -n k8s.io snapshot mounts {{ temporary_dirs }}import-kubernetes-temporary import-kubernetes-temporary | xargs sudo

umount -l {{ temporary_dirs }}import-kubernetes-temporary