## pg_auto_updater

### Run

**docker-cli**

```shell
docker run -d \
	--name=pg_auto_updater \
	--restart=always \
	-v /ssd/data/docker/tvbox/tvbox/config/pg:/data \
	-v /ssd/data/docker/tvbox/pg_auto_updater/config:/config \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--net=host \
	ddsderek/pg_auto_updater:latest
```

**docker-compose**

```yaml
services:
    pg_auto_updater:
        container_name: pg_auto_updater
        restart: always
        volumes:
            - /ssd/data/docker/tvbox/tvbox/config/pg:/data
            - /ssd/data/docker/tvbox/pg_auto_updater/config:/config
            - /var/run/docker.sock:/var/run/docker.sock
        network_mode: host
        image: ddsderek/pg_auto_updater:latest
```
