FROM python:3.12-alpine3.20 AS build

RUN apk add --no-cache \
        binutils \
        clang \
        gcc \
        build-base \
        g++ \
        cargo \
        rust \
        libffi-dev \
        zlib-dev && \
    pip install --upgrade pip && \
    pip install pyinstaller
WORKDIR /build
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .
RUN pyinstaller pg_auto_updater.spec

FROM alpine:3.20

ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]"

RUN apk add --no-cache \
        bash \
        tzdata && \
    rm -rf /tmp/* /root/.cache /var/cache/apk/*

COPY --from=build --chmod=+x /build/dist/pg_auto_updater /usr/bin/pg_auto_updater
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]