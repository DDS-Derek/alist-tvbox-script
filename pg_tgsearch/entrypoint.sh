#!/bin/bash

groupmod -o -g "${PGID}" tgsearch
usermod -o -u "${PUID}" tgsearch

chown tgsearch:tgsearch -R /app /home/tgsearch /tmp

if [ -n "${CACHE_DIR}" ]; then
    chown tgsearch:tgsearch -R "${CACHE_DIR}"
fi

echo "当前 tgsearch 版本：$(cat /version)"

exec su-exec tgsearch:tgsearch "$@"
