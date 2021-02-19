# Labs Number 0 

## Lab Setup

Start ansible server

```bash
docker run --rm -it -h ansibleserver -v $(pwd):/ansible/playbooks cent_ansible bash
```

## Hello Ansible

In the introduction to Ansible a playbook was run.  Put what is the differance between ansible-playbook command and ansible.

## Command ansible-playbook

The first playbook 

```yaml
1. ---
2.    - hosts: localhost
3.      gather_facts: no

4.      tasks:
5.        - name: Echo Hello World
6.          copy: 
7.            dest: /tmp/hello_world_test.txt
8.            content: "hello world\n" 

```

* Line1 --- (in the file is a YML header)
* Line2 - hosts: localhost (which hosts will can run the playbook)
* Line3 gather_facts: no (ansible can discover info "facts" normally true)
* Line4 tasks: (tells ansible which commands to run)
* Line5 -name: (gives the tasks a name)
* Line6 copy: the module
* Line7 dest: /tmp/hello_world_test.txt (copy hello world to a /tmp file)
* Line8 content: "hello world\n" What is in the file

This same playbook can be run using the command line

## Command ansible

Ansible command line interface to be able to run ansible modules with having to create a playbook.


```bash
ansible -c local -i localhost, all -m copy -a 'dest="/tmp/hello_world_test.txt" content="hello world\n"'
```

```bash
1. ansible  # The command
2. -c local # The connection type local vs ssh
3. -i localhost, # The host NOTE; the "," for a single host = Line 2
4. all # All Groups
5. -m copy # The ansible module == Line 6
6. -a # module arguments 
7. 'dest="/tmp/hello_world_test.txt" content="hello world\n"' # the arguments = line 7 and 8 combined

```

There are a lot of other options and the ansible command is very powerfull and you will see it used throught this training.

```bash
ansible -h
usage: ansible [-h] [--version] [-v] [-b] [--become-method BECOME_METHOD]
               [--become-user BECOME_USER] [-K] [-i INVENTORY] [--list-hosts]
               [-l SUBSET] [-P POLL_INTERVAL] [-B SECONDS] [-o] [-t TREE] [-k]
               [--private-key PRIVATE_KEY_FILE] [-u REMOTE_USER]
               [-c CONNECTION] [-T TIMEOUT]
               [--ssh-common-args SSH_COMMON_ARGS]
               [--sftp-extra-args SFTP_EXTRA_ARGS]
               [--scp-extra-args SCP_EXTRA_ARGS]
               [--ssh-extra-args SSH_EXTRA_ARGS] [-C] [--syntax-check] [-D]
               [-e EXTRA_VARS] [--vault-id VAULT_IDS]
               [--ask-vault-pass | --vault-password-file VAULT_PASSWORD_FILES]
               [-f FORKS] [-M MODULE_PATH] [--playbook-dir BASEDIR]
               [-a MODULE_ARGS] [-m MODULE_NAME]
               pattern

Define and run a single task 'playbook' against a set of hosts

positional arguments:
  pattern               host pattern

optional arguments:
  --ask-vault-pass      ask for vault password
  --list-hosts          outputs a list of matching hosts; does not execute
                        anything else
  --playbook-dir BASEDIR
                        Since this tool does not use playbooks, use this as a
                        substitute playbook directory.This sets the relative
                        path for many features including roles/ group_vars/
                        etc.
  --syntax-check        perform a syntax check on the playbook, but do not
                        execute it
  --vault-id VAULT_IDS  the vault identity to use
  --vault-password-file VAULT_PASSWORD_FILES
                        vault password file
  --version             show program's version number, config file location,
                        configured module search path, module location,
                        executable location and exit
  -B SECONDS, --background SECONDS
                        run asynchronously, failing after X seconds
                        (default=N/A)
  -C, --check           don't make any changes; instead, try to predict some
                        of the changes that may occur
  -D, --diff            when changing (small) files and templates, show the
                        differences in those files; works great with --check
  -M MODULE_PATH, --module-path MODULE_PATH
                        prepend colon-separated path(s) to module library (def
                        ault=~/.ansible/plugins/modules:/usr/share/ansible/plu
                        gins/modules)
  -P POLL_INTERVAL, --poll POLL_INTERVAL
                        set the poll interval if using -B (default=15)
  -a MODULE_ARGS, --args MODULE_ARGS
                        module arguments
  -e EXTRA_VARS, --extra-vars EXTRA_VARS
                        set additional variables as key=value or YAML/JSON, if
                        filename prepend with @
  -f FORKS, --forks FORKS
                        specify number of parallel processes to use
                        (default=5)
  -h, --help            show this help message and exit
  -i INVENTORY, --inventory INVENTORY, --inventory-file INVENTORY
                        specify inventory host path or comma separated host
                        list. --inventory-file is deprecated
  -l SUBSET, --limit SUBSET
                        further limit selected hosts to an additional pattern
  -m MODULE_NAME, --module-name MODULE_NAME
                        module name to execute (default=command)
  -o, --one-line        condense output
  -t TREE, --tree TREE  log output to this directory
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)

Privilege Escalation Options:
  control how and which user you become as on target hosts

  --become-method BECOME_METHOD
                        privilege escalation method to use (default=sudo), use
                        `ansible-doc -t become -l` to list valid choices.
  --become-user BECOME_USER
                        run operations as this user (default=root)
  -K, --ask-become-pass
                        ask for privilege escalation password
  -b, --become          run operations with become (does not imply password
                        prompting)

Connection Options:
  control as whom and how to connect to hosts

  --private-key PRIVATE_KEY_FILE, --key-file PRIVATE_KEY_FILE
                        use this file to authenticate the connection
  --scp-extra-args SCP_EXTRA_ARGS
                        specify extra arguments to pass to scp only (e.g. -l)
  --sftp-extra-args SFTP_EXTRA_ARGS
                        specify extra arguments to pass to sftp only (e.g. -f,
                        -l)
  --ssh-common-args SSH_COMMON_ARGS
                        specify common arguments to pass to sftp/scp/ssh (e.g.
                        ProxyCommand)
  --ssh-extra-args SSH_EXTRA_ARGS
                        specify extra arguments to pass to ssh only (e.g. -R)
  -T TIMEOUT, --timeout TIMEOUT
                        override the connection timeout in seconds
                        (default=10)
  -c CONNECTION, --connection CONNECTION
                        connection type to use (default=smart)
  -k, --ask-pass        ask for connection password
  -u REMOTE_USER, --user REMOTE_USER
                        connect as this user (default=None)

Some modules do not make sense in Ad-Hoc (include, meta, etc)
```

## Summary

> A playbook is not required to run ansible modules.  The ansible command can be used call modules and pass the same arguments. The main difference is instead of the yaml format ":" separator a "=" sign is used.

## Lab Cleanup 

Exit ansible Server

```bash
[root@ansibleserver playbooks]# exit 
```

What next learn about connecting to an external client

* [hello_client](../1.hello_client/README.md)

or  back to hello world

* [hello_worldclient](../README.md)