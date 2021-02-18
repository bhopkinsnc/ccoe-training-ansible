FROM opensuse/leap:latest 

RUN \
  zypper install --no-confirm openssh python3 && \
  zypper clean -a && \
  echo "root:@nsibleTra1n" | chpasswd

COPY entrypoint.sh /

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]

