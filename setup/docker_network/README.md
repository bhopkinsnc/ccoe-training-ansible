# Docker Network 

## Create

```bash
docker network list
```

Should see netwrok listed if not will need to be created

```bash
docker network create ansible-training
```

```bash
docker network list
```

```bash
NETWORK ID     NAME               DRIVER    SCOPE
bd499f4d078a   ansible-training   bridge    loca
```

Linux One line to create

```bash
docker network list | grep -q "ansible-training" || docker network create ansible-training
```

NETWORK ID     NAME               DRIVER    SCOPE
bd499f4d078a   ansible-training   bridge    local