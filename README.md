# Ansible-Kubernetes
## Create Kubernetes Cluster
```
$ ansible-playbook -i nodes main.yaml -vv
```
## Add K8s Cluster Manager Node.
```
$ ansible-playbook -i nodes add_master.yml -vv
```
## Add K8s Cluster Worker Node.
```
$ ansible-playbook -i nodes add_nodes.yml -vv
```
Please refer to the documentation for detailed configuration:
[Wiki Docs URL](https://wiki.shileizcc.com/display/CASE/Ansibles+Kubernetes+Pods)
