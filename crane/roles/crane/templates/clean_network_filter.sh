#!/bin/bash
set -x

for i in nat filter; do
  iptables -t $i --line -nvL | grep cali- | awk '{print $2}' | xargs -i iptables -t $i -X {}
  iptables -t $i --line -nvL | grep KUBE- | awk '{print $2}' | xargs -i iptables -t $i -X {}
done

for i in flush destroy; do
  ipset list | grep -E "(KUBE|cali)" | awk '{print $2}' | xargs -i ipset $i {}
done