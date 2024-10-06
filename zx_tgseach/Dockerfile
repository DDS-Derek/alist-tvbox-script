FROM alpine:3.20

ARG TARGETPLATFORM

COPY --chmod=755 $TARGETPLATFORM/tgsearch /app/tgsearch

ENTRYPOINT [ "/app/tgsearch" ]
