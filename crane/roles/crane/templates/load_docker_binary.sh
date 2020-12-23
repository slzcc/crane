#!/bin/bash
set -x

{{ kubernetes_ctl_path }}docker rm -f import-kubernetes-temporary | true && {{ kubernetes_ctl_path }}docker run --name import-kubernetes-temporary -d -v /var/run/docker.sock:/var/run/docker.sock:ro {{ k8s_image_deploy_repo }}:{{ k8s_version }}.{{ build_k8s_version }} sleep 1234567

{{ kubernetes_ctl_path }}docker cp import-kubernetes-temporary:/cni/. {{ kubernetes_cni_dirs }}

{{ kubernetes_ctl_path }}docker cp import-kubernetes-temporary:/cfssl {{ kubernetes_ctl_path }}

{{ kubernetes_ctl_path }}docker cp import-kubernetes-temporary:/cfssljson {{ kubernetes_ctl_path }}

{{ kubernetes_ctl_path }}docker cp import-kubernetes-temporary:/kubernetes/node/bin/kubelet {{ kubernetes_ctl_path }}

{{ kubernetes_ctl_path }}docker cp import-kubernetes-temporary:/kubernetes/node/bin/kubectl {{ kubernetes_ctl_path }}

{{ kubernetes_ctl_path }}docker rm -f import-kubernetes-temporary