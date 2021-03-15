# Lab Number 8

## Lab Setup

*_Prerequisite_*

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)
1. Use Guide to Build Container (centos_keys) [/setup/cntr_centos_keys/README.md](/setup/cntr_centos_keys/README.md)
1. Create Docker Network (ansible-network) [/setup/docker_network/README.md](/setup/docker_network/README.md)

## Start Hosts

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.

```bash
docker run --rm -dP --network=ansible-training -h lab8-cent01 --name lab8-cent01 centos_keys
docker run --rm -dP --network=ansible-training -h lab8-suse01 --name lab8-suse01 suseos_keys
```

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v "${PWD}:/ansible/playbooks" -v "${PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
```

Remove lab8 all file if exists.

```bash
[root@ansibleserver playbooks]# if [ -f inventory/group_vars/lab8/_lab_all.yml ] ; then rm -f inventory/group_vars/lab8/_lab_all.yml; fi
```

## Verify Access with SUDO

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini all -m ping
```

```json
    "ping": "pong"
}
```

Test sudo access

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini all --become -m shell -a 'sudo -l'
```

Notice the rights listed for this user.  

```bash
User root may run the following commands on cent01:
    (ALL) ALL
```

## The Lab

Adding users to host is a common tasks for an admin.  Ansible modules for user creation has many options to add groups and users. Howerver just adding a user is just one tasks to managing users.  In this lab will be creating also adding sudo rights and ssh_keys for extra credit.

### Add user to Host

Will be creating a playbook to add a user.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_user.yml
```

```yaml
---
   - hosts: all 
     gather_facts: no
     become: yes
     become_method: sudo

     tasks:
       - name: add group
         group:
           name: lxadmins00
           gid: 7000
           state: present

       - name: add users
         user:
           name: lxadmin00
           shell: /bin/bash
           comment: "Linux Admin 00"
           uid: 7000
           group: 7000
           groups: 7000
           state: present
```

This lab uses a different inventory file in one group lab8.

```ini
[lab8]
lab8-cent01
lab8-suse01
```

Run playbook to add group and user.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_8_hosts.ini _lab_hello_user.yml
```

See if user was installed

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini all -m shell -a "id -a lxadmin00"
```

### Add SUDO Rights

Add the following code to add a file into the sudoers.d directory.

> PRO_TIP: adding sudo commands to sudoers.d is easier that updating the sudoers file located in /etc.  

Will be using the copy module.  The module has a cool feature you can add content to the file just like using (echo "lxadmin00 ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/lxadmin00).

```yaml
       - name: add sudoers
         copy:
           dest: /etc/sudoers.d/lxadmin00
           content: "lxadmin00 ALL=(ALL) NOPASSWD: ALL"
           owner: root
           group: root
           mode: '0440'
         validate: /usr/sbin/visudo -cf %s

```

> Also, Notice the validate option. This allows to run commands after the tasks in this case checks the if the file syntex is correct.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_user.yml
```

The updated file 

```yaml
---
   - hosts: all 
     gather_facts: no
     become: yes
     become_method: sudo

     tasks:
       - name: add group
         group:
           name: lxadmins00
           gid: 7000
           state: present

       - name: add users
         user:
           name: lxadmin00
           shell: /bin/bash
           comment: "Linux Admin 00"
           uid: 7000
           group: 7000
           groups: 7000
           state: present

       - name: add sudoers
         copy:
           dest: /etc/sudoers.d/lxadmin00
           content: "lxadmin00 ALL=(ALL) NOPASSWD: ALL"
           owner: root
           group: root
           mode: '0440'
           validate: /usr/sbin/visudo -cf %s
```

Run playbook to add sudo rights.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_8_hosts.ini _lab_hello_user.yml
```

Verify access to sudo as lxadmin00

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini all -m shell -a "sudo -l" -b --become-method=sudo --become-user=lxadmin00 
```

Should have output of (ALL) NOPASSWD: ALL if not review steps above until you get correct output

```bash
User lxadmin00 may run the following commands on lab-cent01:
    (ALL) NOPASSWD: ALL
```

> GET BACK ON TRACK:

Run if having issues with the above lab.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_8_hosts.ini labs/8.hello_user/lab_hello_user.yml 
```

### Extra Credit

Will be creating a playbook to add a ssh key for the user and how to use a different private key.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_user_key.yml
```

```yaml
---
   - hosts: all 
     gather_facts: no
     become: yes
     become_method: sudo

     tasks:
       - name: add ssh key 
         authorized_key:
           user: lxadmin00 
           state: present
           exclusive: true
           key: |
             ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDz30xdbIwkoun78xO64u3ipVJsSE0zLe0WYEVxsbCHyOgz9oRQuLhYdpBVmqiY7IUIHKFSuhYxnZHgQUjz37ODZmQSqssUpwciNFSUMpnZXoBt3YZVuzvy5GTVA2LWA4bwNHkeIQn3ZZaBpY0Tj5L5+2VNcQEqJIg9j6LULQ/gco593OcQHm71DTolupqIgjjbCt8Dq7VmHpI4Qx58+XeluBpuLFrZoyCaLbgc0/6fxYkRVzZ6yzr1nqPb74J8gv07KTHu0ErRUz8UDPrMQIu3Hnfydq2x8S0MuGJbSFSYLMuEKUwSv2T10rP58FehCFx5wCB0Ax7KvkhdDIB6Tyz

```

> NOTE: The key pipe "|" used allows to format the next lines.  Ensure that all the lines are two spaces in from the "key:" with no line breaks.

Now that the user is add run play created above to add key.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_8_hosts.ini _lab_hello_user_key.yml 
```

See if user was installed

Verify access

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini  all -m shell -a "cat /home/lxadmin00/.ssh/authorized_keys" -b --become-method=sudo
```

See that the keys are now added they should look like below.

```bash
lab8-cent01 | CHANGED | rc=0 >>
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDz30xdbIwkoun78xO64u3ipVJsSE0zLe0WYEVxsbCHyOgz9oRQuLhYdpBVmqiY7IUIHKFSuhYxnZHgQUjz37ODZmQSqssUpwciNFSUMpnZXoBt3YZVuzvy5GTVA2LWA4bwNHkeIQn3ZZaBpY0Tj5L5+2VNcQEqJIg9j6LULQ/gco593OcQHm71DTolupqIgjjbCt8Dq7VmHpI4Qx58+XeluBpuLFrZoyCaLbgc0/6fxYkRVzZ6yzr1nqPb74J8gv07KTHu0ErRUz8UDPrMQIu3Hnfydq2x8S0MuGJbSFSYLMuEKUwSv2T10rP58FehCFx5wCB0Ax7KvkhdDIB6Tyz 

lab8-suse01 | CHANGED | rc=0 >>
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDz30xdbIwkoun78xO64u3ipVJsSE0zLe0WYEVxsbCHyOgz9oRQuLhYdpBVmqiY7IUIHKFSuhYxnZHgQUjz37ODZmQSqssUpwciNFSUMpnZXoBt3YZVuzvy5GTVA2LWA4bwNHkeIQn3ZZaBpY0Tj5L5+2VNcQEqJIg9j6LULQ/gco593OcQHm71DTolupqIgjjbCt8Dq7VmHpI4Qx58+XeluBpuLFrZoyCaLbgc0/6fxYkRVzZ6yzr1nqPb74J8gv07KTHu0ErRUz8UDPrMQIu3Hnfydq2x8S0MuGJbSFSYLMuEKUwSv2T10rP58FehCFx5wCB0Ax7KvkhdDIB6Tyz 
```

### Use private key as ansible var

Test ssh connection using ssh command with the command "uname -a" at the end.  What this does is ssh into the host and returns the command uname -a. If you are unable to login double check the playbook above and verify that the key is entered correctly.

> HELP: if you have problems getting the ssh public key for lxadmin00 see below Back on Track below.

```bash
root@ansibleserver playbooks]# ssh -i infra_files/ssh_lxadmin00/id_rsa lxadmin00@lab8-cent01 uname -a
```

```bash
Linux lab8-cent01 4.19.121-linuxkit #1 SMP Tue Dec 1 17:50:32 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

```bash
[root@ansibleserver playbooks]# ssh -i infra_files/ssh_lxadmin00/id_rsa lxadmin00@lab8-suse01 uname -a
```

```bash
Linux lab8-suse01 4.19.121-linuxkit #1 SMP Tue Dec 1 17:50:32 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

Now that we know we can login using the ssh key for lxadmin now we can switch from using the local ssh config file to control access to host to and ansible var file.

> GET BACK ON TRACK:

Run if having issues with the above lab.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_8_hosts.ini labs/8.hello_user/lab_hello_user_key.yml 
```

### Add key file to client vars

Will be changing the user that is used by ansible which is currently notroot.

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini  all -m shell -a 'whoami' 
```

```bash
lab8-cent01 | CHANGED | rc=0 >>
notroot
lab8-suse01 | CHANGED | rc=0 >>
notroot
```

Add a vars file in group_vars ansible_ssh_user and ansible_ssh_private_key_file. The var ansible_ssh_user are ansible predefined variables used to select user.

```bash
cat <<EOF> inventory/group_vars/lab8/_lab_all.yml
ansible_ssh_user: lxadmin00 
ansible_ssh_private_key_file: /ansible/playbooks/infra_files/ssh_lxadmin00/id_rsa
EOF
```

### Test ping using lxadmin00 key

Test ping which uses the ansible_ssh_user variable that has been defined in group_vars.

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini all -m ping
```

```json
    "ping": "pong"
}
```

Run the linux command whoami to check if you are now using the lxadmin00 user.

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_8_hosts.ini  all -m shell -a 'whoami' 
```

Question:
  - Who are you now logged in as?

## Summary

> During this lab created a user and group with sudo rights. Then for extra credit add a ssh key and changed group_vars to use the new user lxadmin00 to run Ansible playbooks.

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop lab8-cent01 lab8-suse01
```

Stop containers note that if you did not do the extra credit cent02.

```bash
lab8-cent01
lab8-suse01
```

What's next learn about connecting to an external client

* [hello_dict](../9.hello_dict/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)
