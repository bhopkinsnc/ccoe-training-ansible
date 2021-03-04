# Lab Number 7

## Lab Setup

*_Prerequisite_*

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)
1. Use Guide to Build Container (centos_keys) [/setup/cntr_centos_keys/README.md](/setup/cntr_centos_keys/README.md)
1. Create Docker Network (ansible-network) [/setup/docker_network/README.md](/setup/docker_network/README.md)

## Start Hosts

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.

```bash
docker run --rm -dP --network=ansible-training -h lab-cent02 --name lab-cent02 centos_keys
docker run --rm -dP --network=ansible-training -h lab-suse02 --name lab-suse02 suseos_keys
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
    (ALL) ALL
```

## The Lab

This lab will be using group_vars with inventory groups.  Inventory groups are a collection of host in the inventory file.

Looking at the inventory file you will notice groups which are created in the INI format with brackets [groupname] around a name.  

```bash
[root@ansibleserver playbooks]# cat inventory/lab_hello_group_vars.ini 
```

For example [lab-cent] group are for host that are CENTOS and [lab-suse] are SUSE systems. 

```ini
[lab-cent]
lab-cent02 debug_msg=inventoryfile_host-cent02

[lab-suse]
lab-suse02 debug_msg=inventoryfile_host-suse02

[lab-linux:children]
lab-cent
lab-suse

[lab-linux:vars]
debug_msg=inventoryfile_group-lab-linux
```

The group named [lab-linux:children] which is a group of groups.

> SEE: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#inventory-basics-formats-hosts-and-groups 

> NOTE: Two default groups all and ungrouped. All host belong to two groups (all and ungrouped) or (all and [groupname] ).

## Vars in Groups

The last lab worked with vars assigned to a host in host_vars or inventory file.  The same can be done in the group_vars and inventory file.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_group_vars.yml
```

```yaml
---
   - hosts: lab-linux
     gather_facts: no
     become: yes
     become_method: sudo
     
     tasks:
       - name: debug message
         debug:
           msg: "{{ debug_msg }}"
         tags:
           - debug

```

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_group_vars.ini  _lab_hello_group_vars.yml 
```

```bash
TASK [debug message] ********************************************************************************************************
ok: [lab-cent02] => {
    "msg": "host_vars_dir_file-cent02"
}
ok: [lab-suse02] => {
    "msg": "inventoryfile_host_suse02"
```

> NOTE: Above notice that cent02 system shows the debug msg from the host_vars_dir_file not the inventory file as when created in the lab hellow_host_vars.

## Create a Group Vars File

Make group_vars directory for the group lab-suse

```bash
[root@ansibleserver playbooks]# mkdir inventory/group_vars/lab-suse
```

```bash
[root@ansibleserver playbooks]# vi inventory/group_vars/lab-suse/_lab_debug.yml
```


```yaml
---
debug_msg: group_vars_dir_file-lab-suse
```

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_group_vars.ini  _lab_hello_group_vars.yml 
```

Nothing changed? Why did the message stay the same. This is the importance of understanding 

https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#understanding-variable-precedence

In the lab hello_yum_vars taled about the precdence of vars.  Now that we have group_vars and host_vars notice that host_vars win over group_vars. 

1. CommandLine Values
2. Playbook Vars
3. Inventory Host_Vars
4. Inventory Group_Vars

So if a host var is created that will be used instead of the group_var.

### Add a host with no host_vars

Exit out and run docker command to start cent03

```bash
[root@ansibleserver playbooks]# exit
```

```bash
docker run --rm -dP --network=ansible-training -h lab-cent03 --name lab-cent03 centos_keys
docker run --rm -dP --network=ansible-training -h lab-suse03 --name lab-suse03 centos_keys
```

Restart ansible docker container

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v ${PWD}:/ansible/playbooks -v ${PWD}/infra_files/ssh:/root/.ssh centos_ansible:latest bash
```

Use a new inventory file that has cent03 added

```ini
[lab-cent]
lab-cent02 debug_msg=inventoryfile_host-cent02
lab-cent03

[lab-suse]
lab-suse02 debug_msg=inventoryfile_host-suse02
lab-cent03

[lab-linux:children]
lab-cent
lab-suse

[lab-linux:vars]
debug_msg=inventoryfile_group-lab-linux
```

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_group_vars_part2.ini  _lab_hello_group_vars.yml 
```

The output now shows that cent03 is using the inventory file var for the group lab-linux which cent servers are a child of.

```bash
ok: [lab-cent02] => {
    "msg": "host_vars_dir_file-cent02"
}
ok: [lab-cent03] => {
    "msg": "inventoryfile_group-lab-linux"
}
ok: [lab-suse02] => {
    "msg": "inventoryfile_host-suse02"
}
ok: [lab-suse03] => {
    "msg": "group_vars_dir_file-lab-suse"
}
```

The output from the debug above shows where the var debug_msg is being set.

Where you set the variable at is important and powerfull review the group_vars and host_vars files and read the ansible documentation to make sure you understand the order of precedent.

https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html

## Extra Credit

Almost a real world example: Your orginization has multipale opertations teams that support servers.  Each team as package requirments they perfer. The two teams request these packages loaded on host.

```yaml
centos_packages:
  - nano
  - vim

suseos_Packages:
  - mc
  - nano
```

Here is the inventory of serves you need to install the packages on.

```ini
[lab-cent]
lab-cent03

[lab-suse]
lab-suse03

[lab-linux:children]
lab-cent
lab-suse
```

The playbook you are provided to install packages notice the hosts is lab-linux

```yaml
---
   - hosts: lab-linux
     gather_facts: no
     become: yes
     become_method: sudo
     
     tasks:
       - name: yum package install
         yum:
           name: "{{ item }}"
           state: present
         with_items: 
           - "{{ yum_package_names_list }}
```

Create a lab-linux group directory

```bash
root@ansibleserver playbooks]# mkdir inventory/group_vars/lab-linux
```

Create package file so that all server git nano package

```bash
[root@ansibleserver playbooks]# vi inventory/group_vars/lab-linux/_lab_all.yml
```

```yaml
---

yum_package_names_list:
  - nano

...
```

Run the playbook to install nano package for all

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_group_vars_extra.ini lab_hello_group_vars_extra.yml 
```

```bash
ok: [lab-suse03] => (item=[u'nano'])
ok: [lab-cent03] => (item=[u'nano'])
```

Now let's setup the two other packages.

Create a lab-cent group directory

```bash
root@ansibleserver playbooks]# mkdir inventory/group_vars/lab-cent
```

```bash
[root@ansibleserver playbooks]# vi inventory/group_vars/lab-cent/_lab_all.yml
```

```yaml
---

yum_package_names_list:
  - vim

...
```

Run the playbook to install nano package and see if the vim package will install 

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_group_vars_extra.ini lab_hello_group_vars_extra.yml 
```

```bash
ok: [lab-suse03] => (item=[u'nano'])
changed: [lab-cent03] => (item=[u'vim'])
```

Notice that the install for cent03 add vim but did not list nano.  What happen should it have done both?  

Cent is a child of lab-linux group so it will pull the package from its base group before a children group. 

Lets add the last package for suse team.

```bash
[root@ansibleserver playbooks]# vi inventory/group_vars/lab-suse/_lab_all.yml
```

```yaml
---

yum_package_names_list:
  - mc

...
```

Run the playbook to install mc package for the suse team. 

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_group_vars_extra.ini lab_hello_group_vars_extra.yml 
```

```bash
ok: [lab-cent03] => (item=[u'vim'])
changed: [lab-suse03] => (item=[u'mc'])
```

As expected the other mc package is insalled.  But what what to do about the nano package.

There are a few options. The easist is to add the -nano to each group_vars file for the lab-cent and lab-suse. However, if you want extra extra credit see if you can get before to work.

Update the var name in the lab-linux all file.


```bash
[root@ansibleserver playbooks]# vi inventory/group_vars/lab-linux/_lab_all.yml
```

```yaml
---

linux_group_yum_package_names_list:
  - nano

...
```

The playbook uses the vars at the task level to subsitute the variable.

```yaml
---
  - hosts: lab-linux
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

      - name: yum package install for lab-linux packages
        yum:
          name: "{{ item }}"
          state: present
        with_items: 
          - "{{ yum_package_names_list }}"
        vars:
         yum_package_names_list: "{{ linux_group_yum_package_names_list }}"

```

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_hello_group_vars_extra.ini lab_hello_group_vars_extra_part2.yml  
```

## Summary

> During this LAB learned about group_vars and the presdent of group_vars and host_vars. Also, that chidren of groups vars are lower in presdent then vars defined within the parent group. 

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop lab-cent02 lab-suse02
```

Stop containers note that if you did not do the extra credit cent02.

```bash
lab-cent02
lab-suse02
```

What's next learn about connecting to an external client

* [hello_host_vars](../7.hello_group_vars/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)