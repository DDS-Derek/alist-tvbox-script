#!/bin/bash
# shellcheck shell=bash

Green="\033[32m"
Font="\033[0m"
INFO="[${Green}INFO${Font}]"

function INFO() {
    echo -e "${INFO} ${1}"
}

while true; do
    INFO "开始更新..."
    /usr/bin/pg_auto_updater
    INFO "更新完成！"
    INFO "等待 $((24 * 60 * 60)) 秒后下次运行！"
    sleep "$((24 * 60 * 60))"
done
