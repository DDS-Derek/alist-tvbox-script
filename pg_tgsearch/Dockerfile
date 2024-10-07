FROM alpine:3.20

ARG TARGETPLATFORM

ENV TZ=Asia/Shanghai \
    PUID=9001 \
    PGID=9001

WORKDIR /app

COPY --chmod=755 $TARGETPLATFORM/tgsearch /app/tgsearch
COPY --chmod=755 entrypoint.sh /entrypoint.sh

RUN apk --no-cache add \
        tzdata \
        su-exec \
        bash \
        shadow \
    && mkdir -p /home/tgsearch \
    && addgroup -S tgsearch -g 9001 \
    && adduser -S tgsearch -G tgsearch -h /home/tgsearch -u 9001 -s /bin/bash

ENTRYPOINT [ "/entrypoint.sh" ]

CMD /app/tgsearch -p 10199
	
EXPOSE 10199
