FROM slzcc/ansible:2.8

USER root

COPY . /crane/

WORKDIR /crane

ENV PUBLIC_KEY_DIR=/root/.ssh/id_rsa.pub \
    PRIVATE_KEY_DIR=/root/.ssh/id_rsa

ENTRYPOINT ["/usr/bin/ansible-playbook"]
