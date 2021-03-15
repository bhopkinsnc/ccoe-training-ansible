# Lab Number 9

## Lab Setup

*_Prerequisite_*

1. Use Guide to Build Container (centos_ansible) [/setup/cntr_centos_ansible/README.md](/setup/cntr_centos_ansible/README.md)
1. Use Guide to Build Container (centos_keys) [/setup/cntr_centos_keys/README.md](/setup/cntr_centos_keys/README.md)
1. Create Docker Network (ansible-network) [/setup/docker_network/README.md](/setup/docker_network/README.md)

## Start Hosts

Change directory back so that your current working directory is inside of ccoe-training-ansible repo.

```bash
docker run --rm -dP --network=ansible-training -h lab9-cent01 --name lab9-cent01 centos_key
```

```bash
docker run --rm -it --network=ansible-training -h ansibleserver --name ansibleserver -v $"{PWD}:/ansible/playbooks" -v $"{PWD}/infra_files/ssh:/root/.ssh" centos_ansible:latest bash
```

## Verify Access with SUDO

```bash
[root@ansibleserver playbooks]# ansible -i lab9-cent01, all -m ping
```

```json
    "ping": "pong"
}
```

Test sudo access

```bash
[root@ansibleserver playbooks]# ansible -i lab-cent01, all --become -m shell -a 'sudo -l'
```

Notice the rights listed for this user.  

```bash
User root may run the following commands on cent01:
    (ALL) ALL
```

## The Lab


Review

List

Inside of groups vars for lab 9 is a file named user_groups.yml.  This file contains a list of groups that need to be added. 

```yaml
addgroups:
  groot:
    gid: 1234
    state: present
  gunix:
    gid: 5678
    state: present
```

```bash
[root@ansibleserver playbooks]# vi _lab_hello_dict.yml
```

```yaml
---
   - hosts: all  
     gather_facts: no

     tasks:

     - name: get group values
       debug:
         msg: "{{ item.key }}"
       with_dict: "{{ addgroups }}"
```

```bash
[root@ansibleserver playbooks]# ansible-playbook -i inventory/lab_9_hosts.ini _lab_hello_dict.yml 
```

```bash
TASK [get group values] **************************************************************************************************************************************
ok: [lab9-cent01] => (item={u'key': u'groot', u'value': {u'state': u'present', u'gid': 1234}}) => {
    "msg": "groot"
}
ok: [lab9-cent01] => (item={u'key': u'gunix', u'value': {u'state': u'present', u'gid': 5678}}) => {
    "msg": "gunix"
}
```

add group

```yaml
- name: add groups
  group:
    name: "{{ item.key }}"
    gid: "{{ item.value.gid }}"
    state: present 
  with_dict: "{{ addgroups }}"
```

```yaml
- name: add users 
  user:
    name: "{{ item.key }}"
    shell: "{{ item.value.shell }}" 
    comment: "{{ item.value.comment }}"
    uid: "{{ item.value.uid }}"
    group: "{{ item.value.group }}"
    groups: "{{ item.value.groups }}"
    state: present 
  with_dict: "{{ addusers }}"
```

```yaml
- name: add sudoers
  copy:
    dest: "/etc/sudoers.d/{{ item.key }}"
    content: "{{ item.value.sudoers_line }}" 
    owner: root
    group: root
    mode: '0440'
    validate: /usr/sbin/visudo -cf %s
  with_dict: "{{ addusers }}"
```

```yaml
addgroups:
  groot:
    gid: 1234
    state: present
  gunix:
    gid: 5678
    state: present
```

```yaml
usersadmins:
  admuser1:
    state: present
    comment: Admin User One
    uid: 1001
    group: 1001
    groups: 'sysadmins'
    serviceacct: yes
    ssh_key: 'ssh-rsa AAAAB3Nz... 
    sudoers_line: |
      admuser1 ALL=(ALL) NOPASSWD: ALL
```