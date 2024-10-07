#!/bin/bash

groupmod -o -g "${PGID}" tgsearch
usermod -o -u "${PUID}" tgsearch

chown tgsearch:tgsearch -R /app /home/tgsearch

exec su-exec tgsearch:tgsearch "$@"
