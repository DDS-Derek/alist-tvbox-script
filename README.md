# alist-tvbox-script

alist-tvbox 自用脚本

## 安装脚本

### Alist-Tvbox 安装脚本（支持armv7）

```shell
bash -c "$(curl --insecure -fsSL https://ddsrem.com/script/alist_tvbox_update_xiaoya.sh)"
```

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/DDS-Derek/alist-tvbox-script/master/update_xiaoya.sh)"
```

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

## pg_tgsearch_docker

```shell
bash -c "$(curl --insecure -fsSL https://ddsrem.com/script/pg_tgsearch_docker.sh)"
```

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/DDS-Derek/alist-tvbox-script/master/pg_tgsearch_docker.sh)"
```

## Repository address

- https://github.com/fish2018/ZX
- https://github.com/fish2018/PG
- https://github.com/alantang1977/pg
- https://github.com/alantang1977/X
- https://github.com/qist/tvbox
