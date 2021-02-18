FROM opensuse/leap:latest 

RUN \
  zypper install --no-confirm openssh python3 sudo && \
  zypper clean -a && \
  echo "root:@nsibleRocks1" | chpasswd

RUN  \
  groupadd notroot && \
  useradd -g notroot -m notroot && \
  su - notroot -c "mkdir /home/notroot/.ssh && chmod 750 /home/notroot/.ssh"

COPY notroot_id_rsa.pub /home/notroot/.ssh/authorized_keys
COPY notroot_sudo.file /etc/sudoers.d/notroot

RUN \
  chmod 0600 /home/notroot/.ssh/authorized_keys && \
  chown notroot:notroot /home/notroot/.ssh/authorized_keys

COPY entrypoint.sh /

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]

