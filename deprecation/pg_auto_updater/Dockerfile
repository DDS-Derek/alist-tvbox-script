FROM python:3.13-slim-bookworm AS build

RUN apt-get update -y && \
    apt-get install -y build-essential binutils && \
    pip install --upgrade pip && \
    pip install pyinstaller
WORKDIR /build
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .
RUN pyinstaller pg_auto_updater.spec

FROM debian:bookworm-slim

ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]"

RUN apt-get update -y && \
    apt-get install -y tzdata && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

COPY --from=build --chmod=+x /build/dist/pg_auto_updater /usr/bin/pg_auto_updater

ENTRYPOINT [ "/usr/bin/pg_auto_updater" ]