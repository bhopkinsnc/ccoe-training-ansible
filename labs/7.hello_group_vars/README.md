# Lab Number 7

## Lab Setup

*_Prerequsite_*

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)
1. Use Guide to Build Container (centos_keys) [/setup/cntr_centos_keys/README.md](/setup/cntr_centos_keys/README.md)
1. Create Docker Network (ansible-network) [/setup/docker_network/README.md](/setup/docker_network/README.md)

## Start Hosts

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.

```bash
docker run --rm -dP --network=ansible-training -h lab-cent01 --name lab-cent01 centos_keys
docker run --rm -dP --network=ansible-training -h lab-suse01 --name lab-suse01 suseos_keys
```

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v ${PWD}:/ansible/playbooks -v ${PWD}/infra_files/ssh:/root/.ssh centos_ansible:latest bash
```

## Verify Access with SUDO

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_hello_group_vars.ini all -m ping
```

```json
    "ping": "pong"
}
```

Test sudo access

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_hello_group_vars.ini all --become -m shell -a 'sudo -l'
```

Notice the rights listed for this user.  

```bash
User root may run the following commands on cent01:
    (ALL) ALL
```

## The Lab

This lab will be using group_vars with inventory groups.  Inventory groups are a collection of host in the inventory file.

## Summary

> During this LAB 

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop lab-cent01 lab-suse01
```

Stop conntainers, note that if you did not do the extra credit cent02.

```bash
lab-cent01
lab-suse02
```

What's next learn about connecting to an external client

* [hello_host_vars](../7.hello_group_vars/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)