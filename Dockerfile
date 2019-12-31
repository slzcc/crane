FROM slzcc/ansible:2.8

USER root

COPY . /crane/

COPY ansible.cfg /etc/ansible/ansible.cfg

WORKDIR /crane

ENTRYPOINT ["/usr/bin/ansible-playbook"]
