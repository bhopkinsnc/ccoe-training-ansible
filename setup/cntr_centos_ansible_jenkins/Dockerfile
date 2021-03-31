FROM centos:7

RUN \
  yum -y install epel-release && \
  yum -y install openssh-clients ansible nano && \
  yum -y clean all && \
  touch /run/utmp && \
  chmod u+s /usr/bin/ping && \
  echo "root:@nsibleRocks1" | chpasswd

# Jenkins Setup
RUN \
  yum install -y git && \
  yum install -y wget && \
  yum install -y java-1.8.0-openjdk && \
  yum install -y sudo && \
  yum clean all

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_HOME /home/${user}

RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
RUN chown -R ${user}:${user} /home/${user}
RUN echo "${user}    ALL=(ALL)    ALL" >> etc/sudoers

RUN mkdir -p /ansible/playbooks

WORKDIR /ansible/playbooks

VOLUME [ "/ansible/playbooks" ]

