FROM slzcc/ansible:2.8

USER root

COPY . /crane/

COPY crane/ansible.cfg /etc/ansible/ansible.cfg

WORKDIR /crane/crane

ENTRYPOINT ["/usr/bin/ansible-playbook"]
