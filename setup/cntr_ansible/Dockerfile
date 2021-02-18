FROM alpine:3.12

ENV PYTHONUNBUFFERED=1
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk update  \
    && echo "" \
    && echo "====== Install Python3 =====" \
    && apk add --no-cache python3 \
    && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && echo "" \
    && echo "====== Install PIP =====" \
    && pip3 install --no-cache --upgrade pip setuptools wheel \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
    && echo "" \
    && echo "====== Install Default Pkgs =====" \
    && apk --no-cache --update add \
      ca-certificates \
      curl \
      git \
      openssl \
      openssh-client \
      p7zip \
      py-lxml \
      rsync \
      sshpass \
      zip \
    && echo "" \
    && echo "====== Install Devlopment Pkgs =====" \
    && apk --update add --virtual \
      build-dependencies \
      python3-dev \
      libffi-dev \
      openssl-dev \
      build-base \
      autoconf \
      automake \
      vim \
      gcc \
      libc-dev \
      linux-headers \
    && echo "" \
    && echo "====== Install Ansible Pkgs =====" \
    && pip install \
      ansible==2.10.2 \
      ansible-lint==4.3.7 \
    && echo "" \
    && echo "====== Install Kerbrose Pkgs =====" \
    && apk --no-cache --update add \
      krb5 \
      krb5-dev \
    && pip install \
      virtualenv==20.1.0 \
      pywinrm==0.4.1 \
      pykerberos==1.2.1 \
    && echo "====== Install Ansible Galaxy Community.General =====" \
    && ansible-galaxy collection install community.general

RUN mkdir -p /ansible/playbooks

WORKDIR /ansible/playbooks

VOLUME [ "/ansible/playbooks" ]

# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
