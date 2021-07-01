#!/bin/bash
set -x

for i in nat filter; do
  iptables -t $i -F
  iptables -t $i --line -nvL | grep cali- | awk '{print $2}' | xargs -i iptables -t $i -X {}
  iptables -t $i --line -nvL | grep KUBE- | awk '{print $2}' | xargs -i iptables -t $i -X {}
  iptables -t $i --line -nvL | grep CILIUM_ | awk '{print $2}' | xargs -i iptables -t $i -X {}
done

for i in flush destroy; do
  ipset list | grep -E "(KUBE|cali)" | awk '{print $2}' | xargs -i ipset $i {}
done


for i in kube-ipvs0 tunl0 cilium_host cilium_net cilium_vxlan; do
  ip a flush dev $i
done