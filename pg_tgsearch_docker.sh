#!/bin/bash
# shellcheck shell=bash

PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/opt/homebrew/bin
export PATH

Blue="\033[34m"
Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
function INFO() {
    echo -e "${INFO} ${1}"
}
function ERROR() {
    echo -e "${ERROR} ${1}"
}
function WARN() {
    echo -e "${WARN} ${1}"
}

function install_pg_tgsearch_docker() {

    while true; do
        INFO "请输入您的 session（必填）"
        read -erp "API_SESSION:" API_SESSION
        if [ -n "${API_SESSION}" ]; then
            break
        else
            INFO "此选项为必填项！"
        fi
    done

    INFO "请输入您的 api_session_v1（选填，回车默认为空）"
    read -erp "API_SESSION_V1:" API_SESSION_V1

    INFO "请输入您的 api_id（选填，回车默认为空）"
    read -erp "API_ID:" API_ID

    INFO "请输入您的 api_hash（选填，回车默认为空）"
    read -erp "API_HASH:" API_HASH

    INFO "请输入您的 api_proxy（选填，回车默认为空）"
    read -erp "API_PROXY:" API_PROXY

    INFO "请输入您的 api_download_image（选填，回车默认为空）"
    read -erp "API_DOWNLOAD_IMAGE:" API_DOWNLOAD_IMAGE

    INFO "请输入您的 cache_dir（选填，回车默认为空）"
    read -erp "CACHE_DIR:" CACHE_DIR

    if ! docker pull ddstomo/pg_tgsearch:latest; then
        ERROR "ddstomo/pg_tgsearch:latest 镜像拉取失败！"
        exit 1
    fi

    docker run -d \
        --name=pg_tgsearch \
        -p 10199:10199 \
        -e API_ID="${API_ID}" \
        -e API_HASH="${API_HASH}" \
        -e API_SESSION="${API_SESSION}" \
        -e API_SESSION_V1="${API_SESSION_V1}" \
        -e API_PROXY="${API_PROXY}" \
        -e API_DOWNLOAD_IMAGE="${API_DOWNLOAD_IMAGE}" \
        -e CACHE_DIR="${CACHE_DIR}" \
        --restart=always \
        ddstomo/pg_tgsearch:latest

    INFO "安装完成！"

}

function uninstall_pg_tgsearch_docker() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始卸载 PG tgsearch${Blue} $i ${Font}\r"
        sleep 1
    done
    docker stop pg_tgsearch
    docker rm pg_tgsearch
    docker rmi ddstomo/pg_tgsearch:latest
    INFO "PG tgsearch 卸载成功！"

}

function main_pg_tgsearch_docker() {

    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    echo -e "${Blue}PG tgsearch${Font}\n"
    echo -e "1、安装"
    echo -e "2、卸载"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-2]:" num
    case "$num" in
    1)
        clear
        install_pg_tgsearch_docker
        ;;
    2)
        clear
        uninstall_pg_tgsearch_docker
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-2]'
        main_pg_tgsearch_docker
        ;;
    esac

}

clear
if [[ $EUID -ne 0 ]]; then
    ERROR '此脚本必须以 root 身份运行！'
    exit 1
fi
if ! command -v docker; then
    ERROR "docker 未安装！"
    exit 1
fi
clear
main_pg_tgsearch_docker
