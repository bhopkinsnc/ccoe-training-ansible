# Lab Number 3

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
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v $"{PWD}:/ansible/playbooks" -v $"{PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
```

## Verify Access with SUDO

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m ping 
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

Test sudo access 

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all --become -m shell -a 'sudo -l'
```

Notice the rights listed for this user.  

```bash
User root may run the following commands on cent01:
    (ALL) ALL
```

## The Lab

### Using ansible yum module to install packages

Use vi or nano to create _lab_hello_yum.yml file

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum.yml
```

```yaml
---
   - hosts: all 
     gather_facts: no
     become: yes
     become_method: sudo

     tasks:
       - name: yum package install
         yum:
           name: rsync
           state: present
```

Before you run the playbook lets check if the package is installed.

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m shell -a 'rpm -qa | grep rsync'
```

Run new playbook created to install git package using yum package manager.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, _lab_hello_yum.yml
```

Run the check again it should be installed.

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m shell -a 'rpm -qa | grep rsync'
```

```bash
cent01 | CHANGED | rc=0 >>
rsync-3.1.2-10.el7.x86_64
```

This installed one package on remote server but what about more than one package?

### Install more than one package

Edit the playbook and add additional packages. You will notice that we are adding a few more packages each with a dash "-" in front of the name.  This indicates these are a list. More list in feature labs.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum.yml
```

```yaml
---
   - hosts: "{{ variable_hosts | default('clients') }}"
     gather_facts: no
     become: yes
     become_method: sudo

     tasks:
       - name: yum package install
         yum:
           name:
            - rsync
            - nmap
           state: present
```

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, _lab_hello_yum.yml
```

By changing the name: git to an array list ansible will loop through and install packages.

```yaml
yum:
  name: rsync

yum:
  name:
   - rsync
   - namp
```

> GET BACK ON TRACK:

Run if having issues with the above lab.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, labs/3.hello_yum/lab_hello_yum.yml
```

### Extra Credit 

Exit out of ansible server to start another docker container.

```bash
[root@ansibleserver playbooks]# exit
```

Start cent02 

```bash
docker run --rm -dP --network=ansible-training -h cent02 --name cent02 centos_keys
```

Start the ansible workstation

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v $"{PWD}:/ansible/playbooks" -v $"{PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
```

Use the same playbook but this time use the inventory file which has both cent01 and cent02 listed in the cent group.

### Removing packages

Change the state to absent in the playbook.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum.yml
```

```yaml
           state: absent
```

Now run the playbook with a --check option  

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/cent_hosts.ini _lab_hello_yum.yml -v --check
```

The --check command will show that it will delete the packages

Run again to delete without the --check to delete.  Think about the --check as a way to see what the playbook will do.  

> NOTE: not all ansible module can support --check

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/cent_hosts.ini _lab_hello_yum.yml -v
```

## Summary

> During this LAB you have leaned host to use an ansible module like yum to install a package. Then add more packages using list to loop for more than one package.

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop cent01 cent02
```

Stop containers note that if you did not do the extra credit cent02

```bash
cent01
Error response from daemon: No such container: cent02
```

What's next learn about connecting to an external client

* [hello_yum_vars](../4.hello_yum_vars/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)
