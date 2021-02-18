FROM centos:7

RUN \
  yum -y install epel-release && \
  yum -y install openssh-clients ansible nano && \
  yum -y clean all && \
  touch /run/utmp && \
  chmod u+s /usr/bin/ping && \
  echo "root:@nsibleRocks1" | chpasswd

RUN mkdir -p /ansible/playbooks

WORKDIR /ansible/playbooks

VOLUME [ "/ansible/playbooks" ]

CMD [ "ansible-playbook", "--version" ]
