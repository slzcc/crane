#!/bin/bash
set -x

{{ kubernetes_ctl_path }}docker rm -f import-kubernetes-temporary | true && {{ kubernetes_ctl_path }}docker run --name import-kubernetes-temporary -d -v /var/run/docker.sock:/var/run/docker.sock:ro {{ k8s_image_deploy_repo }}:{{ k8s_version }}.{{ build_k8s_version }} sleep 1234567

{{ kubernetes_ctl_path }}docker exec -i import-kubernetes-temporary bash /docker-image-import.sh

{{ kubernetes_ctl_path }}docker rm -f import-kubernetes-temporary
