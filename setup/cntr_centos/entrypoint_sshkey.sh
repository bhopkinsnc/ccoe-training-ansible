#!/bin/sh

# generate host keys if not present
ssh-keygen -A

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"

groupadd notroot
useradd -a -g notroot notroot


su - notroot -c "mkdir .ssh; echo "SSH_PUBLIC_KEY >> .ssh/authorized_keys && chmod 0600 .ssh/authorized_keys"
