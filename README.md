# Introduction

The following is a training guide for ansible.  The guide requires some knowledge of GIT repository and Docker containers. Before begining please ensure you have your local enviorment setup to support this training course.

## List of Prerequisite

1. GIT Client Access Pull From Repo
1. Docker Install
1. Access to Internet 

## Git Clone Repo

## Build Docker Container 

## Run Docker Container

## Test Ansible

Run the ansible help command verify if install on your local workstation.  If not install.

```bash
   ansible --help
```

## Run First Ansible Command

```bash
   cd ~/projects/GBT-ANSIBLE-TRANING/ansibleTraining

   ansible-playbook hello_world.yml -v
```

Look for the stdout

```bash
changed: [localhost] => {"changed": true, "cmd": "echo \"hello world\"", "delta": "0:00:00.010227", "end": "2020-03-05 17:43:57.942590", "rc": 0, "start": "2020-03-05 17:43:57.932363", "stderr": "", "stderr_lines": [], "stdout": "hello world", "stdout_lines": ["hello world"]}
```

If you get output like below then your ansible-playbook command worked?

Ansible uses YML file format configuration files to create playbooks.

VI cheatsheet of commands [here](../azAdminTraining/vi_cheatsheet.md)) 

```bash
  cd ~/projects
  vi hello_world_file.yml
```

```yaml
---
   - hosts: localhost
     gather_facts: no

     tasks:
       - name: Echo Hello World
         copy: content="hello world\n" dest=/tmp/hello_world_test.txt

```

* Line1 --- (in the file is a YML header)
* Line2 - hosts: localhost (which hosts will can run the playbook)
* Line3 gather_facts: no (ansible can discover info "facts" normally true)
* Line4 tasks: (tells ansible which commands to run)
* Line5 -name: (gives the tasks a name)
* Line6 copy: content="hello world\n" dest=/tmp/hello_world_test.txt (copy hello world to a /tmp file)

Run the ansible playbook that was created

```bash
  ansible-playbook hello_world_file.yml
```

This hello_world_file playbook will create a file in /tmp/hello_world_test.txt

```bash
   cat /tmp/hello_world_test.txt
```

```bash
   Hello world
```

### Making Magic

Lets change the file /tmp/hello_world_test.txt then run the ansible-playbook again

```bash
   echo “hello world NOT” >  /tmp/hello_world_test.txt
```

```bash
   cat /tmp/hello_world_test.txt
```

```bash
   ansible-playbook hello_world_file.yml
```

```bash
   localhost                  : ok=1    changed=1    unreachable=0    failed=0
```

### Extra Credit

Change the file again then run with the --check options.

```bash
   echo “hello world NOT” >  /tmp/hello_world_test.txt
```

```bash
    cat /tmp/hello_world_test.txt
```

```bash
   ansible-playbook hello_world_file.yml --check
```

What did or did not happen?????

## Wait there is More

Let bring hello_world to a client

* [hello_client](hello_client.md)
* [hello_yum](hello_yum.md)
* [hello_yum_vars](hello_yum_vars.md)
* [hello_yum_vars_list](hello_yum_vars_list.md)
* [hello_user](hello_user.md)
* [hello_user_key](hello_user_key.md)
