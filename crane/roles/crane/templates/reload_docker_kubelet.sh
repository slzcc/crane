#!/bin/bash

systemctl stop docker kubelet

ps aux | egrep 'containerd-shim*' | grep -v grep | awk '{print $2}' | xargs -i kill -9 {}

for i in `cat /proc/mounts | grep '{{ docker_data_root }}' | awk '{print $2}'`;do umount -l $i; done
for i in `cat /proc/mounts | grep '{{ kubelet_work_dirs }}' | awk '{print $2}'`;do umount -l $i; done

ip route | grep cali | awk '{print $1}' | xargs -i ip route delete {}

ip neigh | grep cali | awk '{print $3}' | xargs -i ip link delete {}

for i in nat filter; do iptables -F -t $i ; done

for i in tunl0 kube-ipvs0; do ip a flush dev $i ; done

systemctl restart containerd

systemctl start docker
systemctl start kubelet