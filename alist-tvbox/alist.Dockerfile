ARG TAG

FROM golang:1.21 AS builder
WORKDIR /app/
RUN git clone https://github.com/power721/alist.git /app
ENV CGO_CFLAGS="-D_LARGEFILE64_SOURCE"
RUN bash build.sh release docker

FROM xiaoyaliu/alist:${TAG} AS base

FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        sqlite3 \
        unzip \
        bash \
        curl \
        gzip \
        wget \
        busybox \
        ripgrep \
        nginx \
        libnginx-mod-http-js \
        apache2-utils \
        jq \
        tzdata && \
   mv /usr/bin/rg /bin/grep && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*

WORKDIR /opt/alist/

VOLUME [ "/opt/alist/data/" ]

COPY --from=builder /app/bin/alist ./
COPY --from=base /var/lib/data.zip /var/lib/data.zip
COPY --from=base /entrypoint.sh /entrypoint.sh
COPY --from=base /updateall /updateall
COPY --from=base /docker.version /docker.version

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/opt/alist/alist" "server" "--no-prefix"]
