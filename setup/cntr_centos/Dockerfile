FROM centos:7

RUN \
  yum -y install openssh-clients openssh-server && \
  yum -y clean all && \
  touch /run/utmp && \
  chmod u+s /usr/bin/ping && \
  echo "root:@nsibleTra1n" | chpasswd

COPY entrypoint.sh /

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
