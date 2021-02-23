# Lab Number 0

## Lab Setup

*_Prerequsite_*

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)
1. Use Guide to Build Container (centos_keys) [/setup/cntr_centos_keys/README.md](/setup/cntr_centos_keys/README.md)
1. Create Docker Network (ansible-network) [/setup/docker_network/README.md](/setup/docker_network/README.md)

## Start Hosts

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.

```bash
docker run --rm -dP --network=ansible-training -h cent01 --name cent01 centos_keys
```

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v ${PWD}:/ansible/playbooks -v ${PWD}/infra_files/ssh_config:/root/.ssh/config centos_ansible:latest bash
```

## The Lab

### Login Using SSH Password 

Login to cent01 client docker container using a passwd.  Without any options ansible will connect using the current user "root" and ask for the password "--ask-pass".

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m ping --ask-pass
SSH password: @nsibleRocks1
```

The output from the ping will show success.

```json
centos02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

The connect uses ssh to connect to the host. If there are issues connecting using ssh -v command

```bash
[root@ansibleserver playbooks]# ssh cent01 -v
```

Exit out of ansible server

```bash
[root@ansibleserver playbooks]# exit
```

### Login using SSH Keys

You are able to connect using a password but that is no fun exit out of the ansibleserver and attach the volume during the next docker run.

This time will be attaching the an ssh directory that has an config file and ssh private key.  The ssh config file is set to a non-root user named "notroot"

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v ${PWD}:/ansible/playbooks -v ${PWD}/infra_files/ssh:/root/.ssh centos_ansible:latest bash
```

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m ping 
```

```bash
cent01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

The ssh config directory sets up the connection method and user for this server.

```bash
[root@ansibleserver playbooks]# ls /root/.ssh/
```

```bash
config  id_rsa  id_rsa.pub  known_hosts
```

```bash
[root@ansibleserver playbooks]# cat /root/.ssh/config
```

```bash
Host *
   StrictHostKeyChecking no
   UpdateHostKeys yes
   UserKnownHostsFile /dev/null 
   User notroot
```

```bash
1. Host * ( Host that will this config "*" == all )
2.   StrictHostKeyChecking no (ingore host key checking) 
3.   UpdateHostKeys no (update host key in known host)
4.   UserKnownHostsFile /dev/null ( if update know host will update a null file)
5.   User notroot ( the user name that will be connecting to the client )
```

### Verify SUDO Access

Test sudo access 

```bash
ansible -i cent01, all --become -m shell -a 'sudo -l'
```

```bash
[WARNING]: Consider using 'become', 'become_method', and 'become_user' rather than running sudo
cent01 | CHANGED | rc=0 >>
Matching Defaults entries for root on cent01:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS", env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE", env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES", env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY", secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

User root may run the following commands on cent01:
    (ALL) ALL
```

Notice the rights listed for this user.  

```bash
User root may run the following commands on cent01:
    (ALL) ALL
```

This indicates that the notroot user has rights to run ALL commands on all (ALL) hosts.

### Run A Playbook

In this LAB will be connecting to a remote host using ssh.  The -i option is used to connect to a hostname or an inventory file.  More on inventory files later.  The important thing to not is that the single comma after the hostname ',' tells ansible that this is a host.  

> NOTE: ip address can also be used

Run the playbook from the ansibleserver to the client named cent01.  This is the docker container that is running on your local workstation. 

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, playbooks/lab_hello_world_file.yml -v
```

```bash
Using /etc/ansible/ansible.cfg as config file

PLAY [all] **********************************************************************************************************************************

TASK [Echo Hello World] *********************************************************************************************************************
changed: [cent01] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": true, "checksum": "22596363b3de40b06f981fb85d82312e8c0ed511", "dest": "/tmp/hello_world_test.txt", "gid": 1000, "group": "notroot", "md5sum": "6f5902ac237024bdd0c176cb93063dc4", "mode": "0664", "owner": "notroot", "size": 12, "src": "/home/notroot/.ansible/tmp/ansible-tmp-1614024837.18-1649-96181922472341/source", "state": "file", "uid": 1000}

PLAY RECAP **********************************************************************************************************************************
cent01                     : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

To verify that everything is working connect to remote client using the ansbile command shell module and cat the file see the content that was created. 

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m shell -a 'cat /tmp/hello_world_test.txt'
```

```bash
cent01 | CHANGED | rc=0 >>
hello world
```

### Extra Credit

Start a second container then run the playbook again. 

```bash
[root@ansibleserver playbooks]# exit 
```

Start a second client server 

```bash
docker run --rm -dP --network=ansible-training -h cent02 --name cent02 centos_keys
```

Start the Ansible Server

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v ${PWD}:/ansible/playbooks -v ${PWD}/infra_files/ssh:/root/.ssh centos_ansible:latest bash
```

Run the playbook again but add in the command the new server cent02 (-i cent01,cent02, )

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01,cent02, playbooks/lab_hello_world_file.yml -v
```

```bash
Using /etc/ansible/ansible.cfg as config file

PLAY [all] **********************************************************************************************************************************

TASK [Hello World File] *********************************************************************************************************************
ok: [cent01] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "checksum": "22596363b3de40b06f981fb85d82312e8c0ed511", "dest": "/tmp/hello_world_test.txt", "gid": 1000, "group": "notroot", "mode": "0664", "owner": "notroot", "path": "/tmp/hello_world_test.txt", "size": 12, "state": "file", "uid": 1000}
changed: [cent02] => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": true, "checksum": "22596363b3de40b06f981fb85d82312e8c0ed511", "dest": "/tmp/hello_world_test.txt", "gid": 1000, "group": "notroot", "md5sum": "6f5902ac237024bdd0c176cb93063dc4", "mode": "0664", "owner": "notroot", "size": 12, "src": "/home/notroot/.ansible/tmp/ansible-tmp-1614025768.83-56-230297983267282/source", "state": "file", "uid": 1000}

PLAY RECAP **********************************************************************************************************************************
cent01                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
cent02                     : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Notice that the new server add cent02 was changed during that run.


## Summary

> During this LAB you have learned to connect to another host using the -i option and run a playbook.  

## Lab Cleanup 

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop cent01 cent02
```

Stop conntainers, note that if you did not do the extra credit cent02

```bash
cent01
Error response from daemon: No such container: cent02
```

What's next learn about connecting to an external client

* [hello_inventory](../2.hello_inventory/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)
