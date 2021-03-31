# Lab Number 2

## Lab Setup

*_Prerequisite_*

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)
1. Use Guide to Build Container (centos_keys) [/setup/cntr_centos_keys/README.md](/setup/cntr_centos_keys/README.md)
1. Create Docker Network (ansible-network) [/setup/docker_network/README.md](/setup/docker_network/README.md)

## Start Hosts

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.


```bash
docker run --rm -dP --network=ansible-training -h cent01 --name cent01 centos_keys
```

```bash
docker run --rm -dP --network=ansible-training -h cent02 --name cent02 centos_keys
```

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v "${PWD}:/ansible/playbooks" -v "${PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
```

## Verify Access with SUDO

```bash
[root@ansibleserver playbooks]# ansible -i cent01,cent02 all -m ping 
```

```json
cent02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
cent01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

## The Lab

### Setup Inventory INI 

We have only targeted two host cent01 and cent02.  What if you have a lot of servers that are different versions are operating systems. Inventory files will save the day.  There are two formats for inventory files ini and yaml.  We will be using the ini format in the labs because of their simplicity.

An inventory file has already been created so this in just an introduction to them to get you ready for future labs.

```bash
[root@ansibleserver playbooks]# cat inventory/cent_hosts.ini 
```

The output show the two servers cent01 and cent02 but what is that [cent] in brackets?

```ini
[cent]
cent01
cent02
```

The [cent] is the group the belong to

For example cat out this file 

```bash
[root@ansibleserver playbooks]# cat inventory/cent_suse_hosts.ini 
```

```ini
[suse]
suse01
suse02

[cent]
cent01
cent02
```

This file hast two groups one for the CentOS [cent] servers and the other group for SUSE [suse] servers. 

Let's see how this works using the ping command.

Above you checked ping using the -i cent01,cent02, but lets use the inventory file now.

```bash
[root@ansibleserver playbooks]# ansible -i cent01,cent02, all -m ping 
```

The above is the same as using the inventory file below.

```bash
[root@ansibleserver playbooks]# ansible -i inventory/cent_hosts.ini all -m ping 
```

```json
cent01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
cent02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

See it works the same as listed above.  

> TRICK:  the --limit option or (-l) for short can be used to limit one host in the list.

```bash
[root@ansibleserver playbooks]# ansible -i inventory/cent_hosts.ini all -m ping -l cent01
```

```json
cent01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

### Inventory Groups

Lets build some suse systems by closing the ansible session and on the docker workstation build some suse docker images and running them.

```bash
[root@ansibleserver playbooks]# exit
```

Use Guide to Build Container (centos_keys) [/setup/cntr_opensuse_keys/README.md](/setup/cntr_opensuse_keys/README.md)

Start the suse host

```bash
docker run --rm -dP --network=ansible-training -h suse01 --name suse01 centos_keys
```

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v "${PWD}:/ansible/playbooks" -v "${PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
```

Now lets use the inventory file that has both cent and suse.  

```bash
[root@ansibleserver playbooks]# ansible -i inventory/cent_suse_hosts.ini all -m ping 
```


```bash
docker run --rm -dP --network=ansible-training -h suse01 --name suse01 centos_keys
```

```json
[root@ansibleserver playbooks]# ansible -i inventory/cent_suse_hosts.ini all -m ping 
suse02 | UNREACHABLE! => {
    "changed": false, 
    "msg": "Failed to connect to the host via ssh: ssh: Could not resolve hostname suse02: Name or service not known", 
    "unreachable": true
}
cent01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
cent02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
suse01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

You will see that the suse02 is not reachable you have two options. 

    1. remove from inventory file
    1. exclude from run on command line with -l '!host_name'

```bash
[root@ansibleserver playbooks]# ansible -i inventory/cent_suse_hosts.ini all -m ping -l '!suse02'
```

```json
cent01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
cent02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
suse01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

### Extra Credit

Host groups are cool but lets get an idea how that can be used.

let look at the ansible command and focus on the 'all' in the command after the inventory file.  What is all? That is a built-in default group for all host. However, what if it is changed to cent. 

```bash
[root@ansibleserver playbooks]# ansible -i inventory/cent_suse_hosts.ini cent -m ping 
```

```json
cent02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
cent01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
``` 

Changing the 'cent' to 'suse'

```bash
[root@ansibleserver playbooks]# ansible -i inventory/cent_suse_hosts.ini suse -m ping 
```

```json
suse02 | UNREACHABLE! => {
    "changed": false, 
    "msg": "Failed to connect to the host via ssh: ssh: Could not resolve hostname suse02: Name or service not known", 
    "unreachable": true
}
suse01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

 Changing hosts section the playbook from "all" to "cent" or "suse" will only run the host listed in the inventory file.

```yaml
---
   - hosts: all
     gather_facts: no

```

## Summary

> During this LAB you have learned about inventory files and groups. The all group is always there but creating groups help organize your inventory.  See https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html 


## Lab Cleanup 

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop cent01 cent02 suse01
```

Stop containers note that if you did not do the extra credit cent02

```bash
cent01
cent02
suse01
```

What's next learn about connecting to an external client

* [hello_yum](../3.hello_yum/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)
