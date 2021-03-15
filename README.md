# Introduction

The following is a training guide for ansible.  The guide requires some knowledge of GIT repository and Docker containers. Before begining please ensure you have your local enviorment setup to support this training course.

## What is ansible

Ansible is an open-source provisioning, configuration management, and deployment tool. A declarative language playbook writen in yaml describes system configuration. A controlling ansbile connects to target host using ssh for unix/linux or winrm for windows.  No agents are required on the target host using native python libarys to run the scripts. Resource: https://docs.ansible.com/ansible/latest/index.html 

## List of Prerequisite

1. GIT Client and Rights to Pull From Repo
1. Docker Install and working
1. Access to Internet

## Git Clone Repo

If you need help with git commands [help/git_commands.md](help/git_commands.md)

Clone THIS Repo on to your workstation that you will be using that has docker installed and configured.

https://VF-Cloud@dev.azure.com/VF-Cloud/vf_cloud_core/_git/ccoe-training-ansible


## Build Docker Container

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)

## Run Docker Container

Docker will be used during the training to start the ansble server and clients.

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.

```bash
ls
```

```bash
README.md	hello_world.yml	help		infra_files	inventory	labs		setup
```

LINUX Start the container 

About the docker container. The container named with ansibleserver (--name) with the same hostname (-h) will be used during the training. The container runs in interactive mode (-it ) and is destroyed/removed (--rm) when it is stopped or exited.

The command to run Docker

```bash
docker run --rm -it -h ansibleserver --name ansibleserver -v $"{PWD}:/ansible/playbooks" centos_ansible bash
```

The continer should start you will be in the /ansible/playbooks working directory which is the same directory in the repo

```bash
[root@ansibleserver playbooks]# ls
```

```bash
README.md  hello_world.yml  help  infra_files  inventory  labs  setup
```

Run the ansible help command verify if install on your local workstation.  If not install.

```bash
[root@ansibleserver playbooks]# ansible --version 
```

```bash
ansible 2.9.17
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Oct 14 2020, 14:45:30) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
```

## Run First Ansible Command

Lets run a playbook that is located in the root of the repo.

```bash
[root@ansibleserver playbooks]# ansible-playbook hello_world.yml -v
```

Look for the stdout line that has the change

```ini
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not
match 'all'

PLAY [localhost] ****************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [localhost]

TASK [Echo Hello World] *********************************************************************************************
changed: [localhost] => {"changed": true, "cmd": "echo \"hello world\"", "delta": "0:00:00.107958", "end": "2021-02-18 22:37:46.404767", "rc": 0, "start": "2021-02-18 22:37:46.296809", "stderr": "", "stderr_lines": [], "stdout": "hello world", "stdout_lines": ["hello world"]}

PLAY RECAP **********************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

If you get output like above then your ansible-playbook command worked?

The command you just ran ansible-playbook hello_world.yml -v as simple as it can get.  

1. ansible-playbook # The command
1. hello_world.yml # The playbook yaml file
1. -v # Verbose output 

Bonus:

Run the same command without the -v do you see anything different? 

```bash
[root@ansibleserver playbooks]# ansible-playbook hello_world.yml
```

Now run with -vv then -vvv then -vvvv then -vvvvv 


```bash
[root@ansibleserver playbooks]# ansible-playbook hello_world.yml -vv 
```

```bash
[root@ansibleserver playbooks]# ansible-playbook hello_world.yml -vvv
```

```bash
[root@ansibleserver playbooks]# ansible-playbook hello_world.yml -vvvv
```

```bash
[root@ansibleserver playbooks]# ansible-playbook hello_world.yml -vvvvv
```

You just learn about the five debug levels but lets not get side tracked.

## Lets Start Learning about Playbooks

Ansible uses YAML file format configuration files to create playbooks.

VI cheatsheet of commands [help/vi_cheatsheet](help/vi_cheatsheet.md)) 

You will be creating a new file just 

```bash
[root@ansibleserver playbooks]# vi _lab_hello_world_file.yml
or 
[root@ansibleserver playbooks]# nano _lab_hello_world_file.yml
```

```yaml
---
   - hosts: localhost
     gather_facts: no

     tasks:
       - name: Echo Hello World
         copy: 
           dest: /tmp/hello_world_test.txt
           content: "hello world\n" 

```

Save File for vi :wq for nano see help

What did I type?

* Line1 --- (in the file is a YML header)
* Line2 - hosts: localhost (which hosts will can run the playbook)
* Line3 gather_facts: no (ansible can discover info "facts" normally true)
* Line4 tasks: (tells ansible which commands to run)
* Line5 -name: (gives the tasks a name)
* Line6 copy: the module
* Line7 dest: /tmp/hello_world_test.txt (copy hello world to a /tmp file)
* Line8 content: "hello world\n" What is in the file

Run the ansible playbook that was created

```bash
[root@ansibleserver playbooks]# ansible-playbook _lab_hello_world_file.yml
```

This _lab_hello_world_file.yml playbook will create a file in /tmp/hello_world_test.txt

```bash
[root@ansibleserver playbooks]# cat /tmp/hello_world_test.txt
```

The content should match what is in Line 7 in the _lab_hello_world_file.yml

```bash
Hello world
```

### Making Magic

Lets make a change to the file /tmp/hello_world_test.txt then run the ansible-playbook again see what happens

```bash
[root@ansibleserver playbooks]# echo “hello world NOT” >  /tmp/hello_world_test.txt
```

```bash
[root@ansibleserver playbooks]# cat /tmp/hello_world_test.txt
```

```bash
hello world NOT
```

```bash
[root@ansibleserver playbooks]# ansible-playbook _lab_hello_world_file.yml
```

You will notice that there was a change but what changed and why?

```bash
localhost                  : ok=1    changed=1    unreachable=0    failed=0
```

```bash
[root@ansibleserver playbooks]# cat /tmp/hello_world_test.txt
```

```bash
hello world
```

> The file (/tmp/hello_world_test.txt) was changed when we added the NOT to the end of hello world line and ansible changes it back because the copy module on line 7 ensure that the contents match and when they do not it will update the file.

### Extra Credit

Change the file again then run with the --check options.

```bash
[root@ansibleserver playbooks]# echo “hello world NOT” >  /tmp/hello_world_test.txt
```

```bash
[root@ansibleserver playbooks]# cat /tmp/hello_world_test.txt
```

```bash
[root@ansibleserver playbooks]# ansible-playbook _lab_hello_world_file.yml --check
```

What did or did not happen?????

## Lab Cleanup

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

## Wait there is More

Let began with hello_ansible to understand the ansible command and then after hello_client.  Because loading ansible on every server and logging in them locally is not what we signed up for right.  :)

* [Lab0_hello_ansible](labs/0.hello_ansible/README.md)
* [Lab1_hello_client](labs/1.hello_client/README.md)
* [Lab2_hello_inventory](labs/2.hello_inventory/README.md)
* [Lab3_hello_yum](labs/3.hello_yum/README.md)
* [Lab4_hello_yum_vars](labs/4.hello_yum_vars/README.md)
* [Lab5_hello_yum_vars_list](labs/5.hello_yum_vars_list/README.md)
* [Lab6_hello_host_vars](labs/5.hello_host_vars/README.md)
* [Lab7_hello_group_vars](labs/7.hello_group_vars/README.md)
* [Lab8_hello_user](labs/8.hello_user/README.md)
