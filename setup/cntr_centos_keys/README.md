## Build Docker Container

Check if images is already created

```bash
docker images centos_keys
```

```bash
REPOSITORY     TAG       IMAGE ID       CREATED        SIZE
centos_keys   latest   XXXXXXXXXX     25 hours ago   363MB
```

If not listed create

Change directory into training repo

```bash
cd setup/cntr_centos_keys
docker build -t centos_keys .
cd ../..
```