FROM golang:1.21 as builder
WORKDIR /app/
RUN git clone https://github.com/power721/alist.git /app
ENV CGO_CFLAGS="-D_LARGEFILE64_SOURCE"
RUN bash build.sh release docker

ARG TAG

FROM ubuntu:latest

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
COPY --from=xiaoyaliu/alist:${TAG} /var/lib/data.zip /var/lib/data.zip
COPY --from=xiaoyaliu/alist:${TAG} /entrypoint.sh /entrypoint.sh
COPY --from=xiaoyaliu/alist:${TAG} /updateall /updateall
COPY --from=xiaoyaliu/alist:${TAG} /docker.version /docker.version

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/opt/alist/alist" "server" "--no-prefix"]
