# pg tgsearch

## Run

**docker-cli**

```shell
docker run -d \
    --name=pg_tgsearch \
    -p 10199:10199 \
    -e API_ID= \
    -e API_HASH= \
    -e STRINGSESSION= \
    -e API_PROXY= \
    --restart=always \
    ddstomo/pg_tgsearch:latest
```

**docker-compose**

```yaml
services:
    tgsearch:
        container_name: pg_tgsearch
        image: ddstomo/pg_tgsearch:latest
        environment:
            - API_ID=
            - API_HASH=
            - STRINGSESSION=
            - API_PROXY=
        ports:
            - 10199:10199
        restart: always
```
