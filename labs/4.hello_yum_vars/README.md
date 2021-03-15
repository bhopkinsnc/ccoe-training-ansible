# Lab Number 4

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
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v "${PWD}:/ansible/playbooks" -v "${PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
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

### Yum Vars

Before you run the playbook lets check if the package is installed.

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m shell -a 'rpm -qa | grep rsync'
```

If the package is already installed remove it before next step.

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m yum -a "name=rsync state=absent" -b --become-method=sudo
```

> NOTE: During this lab if you need to start-over can use the command above to remove a package or just stop/start the docker container.

Use vi or nano to create _lab_hello_yum.yml file

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum_vars.yml
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
           name: "{{ yum_package_name }}"
           state: present
```


```bash
[root@ansibleserver playbooks]# ansible-playbook -i cent01, _lab_hello_yum_vars.yml -e yum_package_name=rsync 
```

Check if package is installed

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m shell -a 'rpm -qa | grep rsync'
```

```bash
cent01 | CHANGED | rc=0 >>
rsync-3.1.2-10.el7.x86_64
```

This installed one package on remote server using a varable -e "{{ yum_pakage_name }}" at command line using the -e | --extra-vars

## Vars in inv file

You can add a vars in the inventory file and not on the command line. 

```bash
[root@ansibleserver playbooks]# vi _lab_hello_clients.ini
```

Add to file

```ini
[all]
cent01

[all:vars]
yum_package_name=nmap
```

Run the ansible playbook but now will pull the var from the inv file.

> NOTE: the -e option is not needed because the package name has been added to the variable yum_package_name=nmap in the ini file.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i _lab_hello_clients.ini _lab_hello_yum_vars.yml 
```

Check if package is installed from the inventory file.

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m shell -a 'rpm -qa | grep nmap'
```

> GET BACK ON TRACK:

Run if having issues with the above lab.

Copy INI file or Playbook as needed

```bash
[root@ansibleserver playbooks]# cp labs/4.hello_yum_vars/_lab_hello_clients.ini _lab_hello_clients.ini
[root@ansibleserver playbooks]# cp labs/4.hello_yum_vars/lab_hello_yum_vars.yml _lab_hello_yum_vars.yml
```

## Vars in Playbook

Use vi or nano to edit _lab_hello_yum.yml file adding a vars to the playbook.

```bash
[root@ansibleserver playbooks]# vi _lab_hello_yum_vars.yml
```

Add the vars infomariton to the playbook.

```yaml
   vars:
     yum_package_name: lsof

```

The finished playbook should look like below.

```yaml
---
   - hosts: all 
     gather_facts: no
     become: yes
     become_method: sudo

     vars:
       yum_package_name: lsof

     tasks:
       - name: yum package install
         yum:
           name: "{{ yum_package_name }}"
           state: present
```

Run the ansible playbook the "lsof" package will get loaded not the "nmap" that is assigned to the yum_package_name var from the inv file.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i _lab_hello_clients.ini _lab_hello_yum_vars.yml 
```

Check if package "lsof" package is installed from the vars added to the playbook file.

```bash
[root@ansibleserver playbooks]# ansible -i cent01, all -m shell -a 'rpm -qa | grep lsof'
```

```bash
cent01 | CHANGED | rc=0 >>
lsof-4.87-6.el7.x86_64
```

> GET BACK ON TRACK:

Run if having issues with the above lab.

```bash
[root@ansibleserver playbooks]# cp labs/4.hello_yum_vars/lab_hello_yum_vars_vars.yml _lab_hello_yum_vars.yml
[root@ansibleserver playbooks]# ansible-playbook -i _lab_hello_clients.ini lab_hello_yum_vars.yml 
```

### Change the package in Inventory File

Let's say you want to change the package that you want to load. Where do you change it? Let's try to change the package name in the inventory file. 

```bash
[root@ansibleserver playbooks]# vi _lab_hello_clients.ini
```

Change the nmap to the application mutt

```ini
[all]
cent01

[all:vars]
yum_package_name=mutt
```

```bash
[root@ansibleserver playbooks]# ansible-playbook -i _lab_hello_clients.ini _lab_hello_yum_vars.yml -v
```

What package was loaded the one in the inventory file or in the playbook and why?

> GET BACK ON TRACK:

Run if having issues with the above lab.

```bash
[root@ansibleserver playbooks]# cp labs/4.hello_yum_vars/lab_hello_yum_vars.yml _lab_hello_yum_vars.yml
```

## Extra Credit

### To override the ini vars and playbook vars

To add another package can run the command again with a different name on the command line.

```bash
[root@ansibleserver playbooks]# ansible-playbook -i _lab_hello_clients.ini _lab_hello_yum_vars.yml -e yum_package_name=mutt -v
```

What package got installed answer (mutt). Why because passing vars at command line has precedences's over inventory files are playbooks.

## Summary

> During this LAB you have leaned how to pass vars using three different methods (commandline,inventoryfile, playbook) host to use an ansible module like yum to install a package. Then add more packages using list to loop for more than one package.  There is an order that variables are pulled from inventory

https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#understanding-variable-precedence

Take-away: if you are going to use variables in your inventory files then try not to use vars in the playbook because they have precedence.

1. CommandLine Values
2. Playbook Vars
3. Inventory Group_Vars

> NOTE: the ansible website list least to greater with command line the greatest. Above just reversed order.

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

```bash
docker stop cent01
```

Stop containers note that if you did not do the extra credit cent02

```bash
cent01
```

What's next learn about connecting to an external client

* [hello_yum_vars_list](../5.hello_yum_vars_list/README.md)

or

Go back to hello world home where it all began

* [hello_world](/)