FROM slzcc/ansible:2.9.14-alpine

USER root

COPY . /crane/

COPY crane/ansible.cfg /etc/ansible/ansible.cfg

WORKDIR /crane/crane

ENTRYPOINT ["/usr/bin/ansible-playbook"]
