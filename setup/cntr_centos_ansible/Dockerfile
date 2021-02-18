FROM centos:7

RUN \
  yum -y install epel-release && \
  yum -y install openssh-clients ansible && \
  yum -y clean all && \
  touch /run/utmp && \
  chmod u+s /usr/bin/ping && \
  echo "root:@nsibleRocks1" | chpasswd

CMD [ "ansible-playbook", "--version" ]
