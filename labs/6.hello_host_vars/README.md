# Lab Number 6

## Lab Setup

*_Prerequisite_*

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)
1. Use Guide to Build Container (centos_keys) [/setup/cntr_centos_keys/README.md](/setup/cntr_centos_keys/README.md)
1. Create Docker Network (ansible-network) [/setup/docker_network/README.md](/setup/docker_network/README.md)

## Start Hosts

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.

```bash
docker run --rm -dP --network=ansible-training -h lab-cent01 --name lab-cent01 centos_keys
docker run --rm -dP --network=ansible-training -h lab-cent02 --name lab-cent02 centos_keys
```

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v $"{PWD}:/ansible/playbooks" -v $"{PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
```

## Verify Access with SUDO

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_hello_host_vars.ini all -m ping
```

```json
    "ping": "pong"
}
```

Test sudo access

```bash
[root@ansibleserver playbooks]# ansible -i inventory/lab_hello_host_vars.ini all --become -m shell -a 'sudo -l'
```

Notice the rights listed for this user.  

```bash
User root may run the following commands on cent01:
    (ALL) ALL
```

## The Lab

### Using inventory host_vars 

Ansible variables can be also placed in file inside a directory structure.  The directory is in the working directory where the inventory file is located.

Create a playbook for testing host_vars 

```bash
[root@ansibleserver playbooks]# vi _lab_hello_host_vars.yml
```

```yaml
---
   - hosts: cent
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

Add a file in the host_vars directory that is the same name as the host in the inventory file. 

```bash
[root@ansibleserver playbooks]# vi inventory/host_vars/lab-cent01.yml
```

Will add the packages that will be installed on host.

```yaml
---
yum_package_names_list:
  - rsync 
  - mutt
```

> NOTE: to create a list in yaml set the name of the list.  In this case it is yum_package_names_list:.  Then make sure two spaces and - then the item in the list.  The format and spaces is important working with yaml. 

Run to install packages from a file with the same name as the host in the host_vars directory.   The var_package_names_list in the file is the same name as the with_items.  

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_host_vars.ini _lab_hello_host_vars.yml
```

You will notice that the variable is not defined for lab-cent02 so that host is skipped.

```bash
fatal: [lab-cent02]: FAILED! => {"msg": "'yum_package_names_list' is undefined"}
changed: [lab-cent01] => (item=[u'rsync', u'mutt'])

PLAY RECAP ******************************************************************************************************************
lab-cent01                 : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lab-cent02                 : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

Putting the package names in the host_vars directory for each host can create custom list/variables for each host. 

### Add Vars File for lab-cent02

This time will create a directory to hold the vars instead of a file.

```bash
[root@ansibleserver playbooks]# mkdir inventory/host_vars/lab-cent02
```

```bash
[root@ansibleserver playbooks]# vi inventory/host_vars/lab-cent02/_lab_all.yml
```

```yaml
---
yum_package_names_list:
  - lsof
  - nmap 
```

Notice that both hosts have two separate list of packages for each server is different.  

Host lab-cent02 list

```bash
[root@ansibleserver playbooks]# cat inventory/host_vars/lab-cent01.yml | grep " - "
```

```yaml
  - rsync 
  - mutt
```

Host lab-cent02 list

```bash
root@ansibleserver playbooks]# cat inventory/host_vars/lab-cent02/_lab_all.yml | grep " - "
```

```yaml
  - lsof
  - nmap 
```

Run the playbook again now packages will install based for the different list in each host file

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_host_vars.ini _lab_hello_host_vars.yml
```

```ini
TASK [yum package install] **************************************************************************************************
ok: [lab-cent01] => (item=[u'rsync', u'mutt'])
changed: [lab-cent02] => (item=[u'lsof', u'nmap'])
```

## Extra Credit

Add a debug task to the playbook using a feature called tags.  Tags allow you to run only the tasks that have been tagged that that value.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_host_vars.yml
```

```yaml
---
   - hosts: lab-cent
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

       - name: debug message
         debug:
           msg: "{{ debug_msg }}"
         tags:
           - debug

```

Run the playbook calling the "-t debug" to see where the variable that was create source.  

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_host_vars.ini _lab_hello_host_vars.yml -t debug -v
```

```bash
TASK [debug message] ********************************************************************************************************
ok: [lab-cent01] => {
    "msg": "inventoryfile_host-cent01"
}
ok: [lab-cent02] => {
    "msg": "inventoryfile_host-cent02"
```

If you look in the inventory file there are vars listed on the host line.

```bash
[root@ansibleserver playbooks]# cat inventory/lab_hello_host_vars.ini
```

```ini
[lab-cent]
lab-cent01 debug_msg=inventoryfile_host-cent01
lab-cent02 debug_msg=inventoryfile_host-cent02
```

Add another file to the lab-cent02 system.  

> More than one file can be added to a directory. And it can be named anything just make sure it ends with .yml or .json.  

```bash
[root@ansibleserver playbooks]# vi inventory/host_vars/lab-cent02/_lab_debug.yml
```

```yaml
---
debug_msg: host_vars_dir_file-cent02
```


```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_host_vars.ini _lab_hello_host_vars.yml -t debug -v
```

```bash
TASK [debug message] ********************************************************************************************************
ok: [lab-cent01] => {
    "msg": "inventoryfile_host-cent01"
}
ok: [lab-cent02] => {
    "msg": "host_vars_dir_file-cent02"
}
```

You can also add the variable to line to the end of the lab-cent01.yml to change the msg. 

```bash
[root@ansibleserver playbooks]# echo "debug_msg: host_vars_dir_file-cent01" >> inventory/host_vars/lab-cent01.yml 
```

Now run the playbook again see the difference.

```bash 
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_host_vars.ini _lab_hello_host_vars.yml -t debug -v
```

## Summary

> During this LAB learned how to use host_vars to create different list of packages that is used by the same playbook.  Also, host inventory files and yaml host files can be used to pass variables to the playbooks. 

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop lab-cent01 lab-cent02
```

Stop containers note that if you did not do the extra credit cent02.

```bash
lab-cent01
lab-cent02
```

What's next learn about connecting to an external client

* [hello_host_vars](../7.hello_group_vars/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)