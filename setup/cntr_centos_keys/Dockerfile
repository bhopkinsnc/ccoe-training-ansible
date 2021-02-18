FROM centos:7

RUN \
  yum -y install openssh-clients openssh-server sudo && \
  yum -y clean all && \
  touch /run/utmp && \
  chmod u+s /usr/bin/ping && \
  echo "root:@nsibleRocks1" | chpasswd

RUN  \
  groupadd notroot && \
  useradd -g notroot notroot && \
  su - notroot -c "mkdir /home/notroot/.ssh && chmod 750 /home/notroot/.ssh"

COPY notroot_id_rsa.pub /home/notroot/.ssh/authorized_keys
COPY notroot_sudo.file /etc/sudoers.d/notroot

RUN \
  chmod 0600 /home/notroot/.ssh/authorized_keys && \
  chown notroot:notroot /home/notroot/.ssh/authorized_keys

COPY entrypoint.sh /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
