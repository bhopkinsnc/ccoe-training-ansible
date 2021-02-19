# Introduction

The following is a training guide for ansible.  The guide requires some knowledge of GIT repository and Docker containers. Before begining please ensure you have your local enviorment setup to support this training course.

## List of Prerequisite

1. GIT Client and Rights to Pull From Repo
1. Docker Install and working
1. Access to Internet

## Git Clone Repo

If you need help with git commands [help/git_commands.md](help/git_commands.md)

Clone THIS Repo on the Workstation that you will be using that has docker installed and configured.

https://VF-Cloud@dev.azure.com/VF-Cloud/vf_cloud_core/_git/ccoe-training-ansible


## Build Docker Container 

Use Guide to Build Container [setup/cntr_centos_ansible/README.md](setup/cntr_centos_ansible/README.md) 

## Run Docker Container

Change repo root directory

```bash
docker run --rm -it -h ansibleserver -v $(pwd):/ansible/playbooks cent_ansible bash
```

The continer should start in the /ansible/playbooks working directory and files in the repo

```bash
[root@ansibleserver playbooks]# ls
```

```bash
README.md  hello_world.yml  infra_files  inventory  setup 
```

## Test Ansible

Run the ansible help command verify if install on your local workstation.  If not install.

```bash
ansible --help
```

## Run First Ansible Command

```bash
ansible-playbook hello_world.yml -v
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

## It worked SO Lets Start Learning

Ansible uses YML file format configuration files to create playbooks.

VI cheatsheet of commands [help/vi_cheatsheet](help/vi_cheatsheet.md)) 

You will be creating a new file just 

```bash
vi -lab_hello_world_file.yml
or 
nano -lab_hello_world_file.yml
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

Save File 

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
ansible-playbook -lab_hello_world_file.yml
```

This -lab_hello_world_file.yml playbook will create a file in /tmp/hello_world_test.txt

```bash
cat /tmp/hello_world_test.txt
```

The content should match what is in Line 7

```bash
Hello world
```

### Making Magic

Lets make a change to the file /tmp/hello_world_test.txt then run the ansible-playbook again see what happens

```bash
echo “hello world NOT” >  /tmp/hello_world_test.txt
```

```bash
cat /tmp/hello_world_test.txt
```

```bash
hello world NOT
```

```bash
ansible-playbook -lab_hello_world_file.yml
```

You will notice that there was a change but what changed and why?

```bash
localhost                  : ok=1    changed=1    unreachable=0    failed=0
```

```bash
cat /tmp/hello_world_test.txt
```

```bash
hello world
```

> The file was changed when we add the NOT to the end of hello world and ansible changes it back because the copy module on line 7 ensure that the contents match and when they do not it will update the file.

### Extra Credit

Change the file again then run with the --check options.

```bash
echo “hello world NOT” >  /tmp/hello_world_test.txt
```

```bash
cat /tmp/hello_world_test.txt
```

```bash
ansible-playbook -lab_hello_world_file.yml --check
```

What did or did not happen?????

## Wait there is More

Let bring hello_ansible then next hello_client. Because loading ansible on every server and logging in them locally is not what we signed up for right.  :)

* [hello_ansible](labs/0.hello_ansible/README.md)
* [hello_client](labs/1.hello_client/README.md)
* [hello_yum](labs/2.hello_yum/README.md)
* [hello_yum_vars](labs/3.hello_yum_vars/README.md)
* [hello_yum_vars_list](labs/4.hello_yum_vars_list/README.md)
* [hello_user](labs/5.hello_user/README.md)
* [hello_user_key](labs/6.hello_user_key/README.md)
