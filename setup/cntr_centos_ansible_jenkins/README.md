## Build Docker Container

Check if images is already created

```bash
docker images centos_ansible
```

```bash
REPOSITORY     TAG       IMAGE ID       CREATED        SIZE
centos_ansible   latest    XXXXXXXXXXXX   1 hours ago   363MB
```

If not listed create

Change directory into training repo

```bash
cd setup/cntr_centos_ansible
docker build -t centos_ansible .
cd ../..
```

## Verify Container 

```bash
docker run --rm -it centos_ansible 
```

```bash
ansible-playbook 2.9.17
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.5 (default, Oct 14 2020, 14:45:30) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
```