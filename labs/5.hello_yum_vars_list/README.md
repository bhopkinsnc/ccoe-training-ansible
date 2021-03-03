# Lab Number 5

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
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v ${PWD}:/ansible/playbooks -v ${PWD}/infra_files/ssh:/root/.ssh centos_ansible:latest bash
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

In the previous examples a varable was used however in that example can only pass one varable to the package. This method will pass a list of files.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum_vars_list.yml
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
           name: "{{ item }}"
           state: present
         with_items: 
            - rsync 
            - mutt
```

Run to install packages from list.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, _lab_hello_yum_vars_list.yml 
```

### Run a list

Update the playbook to switching to a yum_packages_names var file.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum_vars_list.yml
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
           name: "{{ item }}"
           state: present
         with_items: 
           - "{{ yum_package_names_list }}"
```

## Create Inventory file

```bash
[root@ansibleserver playbooks]# vi _lab_yum_packages_names_list.yml
```

```yaml
yum_package_names_list:
  - rsync 
  - mutt
```

Run to install packages from list file passwd at the command line.  The var_package_names_list in the file is the same name as the with_items.  

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, _lab_hello_yum_vars_list.yml -e @_lab_yum_packages_names_list.yml
```

You should see not change because a list is a list weather it is from a vars file or a list inside the playbook.

## Add another package to list

```bash
[root@ansibleserver playbooks]# vi _lab_yum_packages_names_list.yml
```

```yaml
yum_package_names_list:
  - rsync
  - mutt
  - nmap
```

Run again to install nmap packages from list.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, _lab_hello_yum_vars_list.yml -e @_lab_yum_packages_names_list.yml
```

The new package nmap will install.

## Extra Credit

### Add another host

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
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v ${PWD}:/ansible/playbooks -v ${PWD}/infra_files/ssh:/root/.ssh centos_ansible:latest bash
```

Add vars to the playbook.

Update the playbook to switching to a yum_packages_names var file.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum_vars_list.yml
```

```yaml
     vars:
       yum_package_names_list_vars: 
         - vim
         - nano
```

```yaml
        with_items: 
           - "{{ yum_package_names_list }}"
           - "{{ yum_package_names_list_vars }}"
```

The final playbook should look like.

```yaml
---
   - hosts: "{{ variable_hosts | default('clients') }}"
     gather_facts: no
     become: yes
     become_method: sudo
     
     vars:
       yum_package_names_list_vars: 
         - vim
         - nano

     tasks:
       - name: yum package install
         yum:
           name: "{{ item }}"
           state: present
         with_items: 
           - "{{ yum_package_names_list }}"
           - "{{ yum_package_names_list_vars }}"
```

Use the same playbook but this time use call both cent01 and cent02. 

```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01,cent02 _lab_hello_yum_vars_list.yml -e @_lab_yum_packages_names_list.yml
```

What packages got installed. List can be combined from inventory inside of playbook and listed under with_items. 

## Summary

> During this LAB you created var list of files.  A vars file _lab_yum_packages_names_list.yml was created that is passed with the -e on commandline. Add a package to the list and then added a new another server to update two hosts. Multiple variables of list can be combined and used with_items.  

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop cent01 cent02
```

Stop conntainers, note that if you did not do the extra credit cent02.

```bash
cent01
Error response from daemon: No such container: cent02
```

What's next learn about connecting to an external client

* [hello_host_vars](../6.hello_host_vars/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)
