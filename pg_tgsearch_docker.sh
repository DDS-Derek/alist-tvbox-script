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

function container_update() {

    local run_image remove_image pull_image
    if docker inspect ddsderek/runlike:latest > /dev/null 2>&1; then
        local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' ddsderek/runlike:latest 2> /dev/null | cut -f2 -d:)
        remote_sha=$(curl -s -m 10 "https://hub.docker.com/v2/repositories/ddsderek/runlike/tags/latest" | grep -o '"digest":"[^"]*' | grep -o '[^"]*$' | tail -n1 | cut -f2 -d:)
        if [ "$local_sha" != "$remote_sha" ]; then
            docker rmi ddsderek/runlike:latest
            docker pull "ddsderek/runlike:latest"
        fi
    else
        docker pull "ddsderek/runlike:latest"
    fi
    INFO "获取 ${1} 容器信息中..."
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /tmp:/tmp ddsderek/runlike -p "${@}" > "/tmp/container_update_${*}"
    if [ -n "${container_update_extra_command}" ]; then
        eval "${container_update_extra_command}"
    fi
    run_image=$(docker container inspect -f '{{.Config.Image}}' "${@}")
    # shellcheck disable=SC2086
    remove_image=$(docker images -q ${run_image})
    local retries=0
    local max_retries=3
    while [ $retries -lt $max_retries ]; do
        if docker pull "${run_image}"; then
            INFO "${1} 镜像拉取成功！"
            break
        else
            WARN "${1} 镜像拉取失败，正在进行第 $((retries + 1)) 次重试..."
            retries=$((retries + 1))
        fi
    done
    if [ $retries -eq $max_retries ]; then
        ERROR "镜像拉取失败，已达到最大重试次数！"
        return 1
    else
        pull_image=$(docker images -q "${run_image}")
        if ! docker stop "${@}" > /dev/null 2>&1; then
            if ! docker kill "${@}" > /dev/null 2>&1; then
                docker rmi "${run_image}"
                ERROR "更新失败，停止 ${*} 容器失败！"
                return 1
            fi
        fi
        INFO "停止 ${*} 容器成功！"
        if ! docker rm --force "${@}" > /dev/null 2>&1; then
            ERROR "更新失败，删除 ${*} 容器失败！"
            return 1
        fi
        INFO "删除 ${*} 容器成功！"
        if [ "${pull_image}" != "${remove_image}" ]; then
            INFO "删除 ${remove_image} 镜像中..."
            docker rmi "${remove_image}" > /dev/null 2>&1
        fi
        if bash "/tmp/container_update_${*}"; then
            rm -f "/tmp/container_update_${*}"
            INFO "${*} 更新成功"
            return 0
        else
            ERROR "更新失败，创建 ${*} 容器失败！"
            return 1
        fi
    fi

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

    INFO "请输入您的 api_download_image（选填，回车默认 1）"
    read -erp "API_DOWNLOAD_IMAGE:" API_DOWNLOAD_IMAGE
    [[ -z "${API_DOWNLOAD_IMAGE}" ]] && API_DOWNLOAD_IMAGE="1"

    INFO "请输入您的 api_download_video（选填，回车默认 1）"
    read -erp "API_DOWNLOAD_VIDEO:" API_DOWNLOAD_VIDEO
    [[ -z "${API_DOWNLOAD_VIDEO}" ]] && API_DOWNLOAD_VIDEO="1"

    INFO "请输入您的 cache_dir（选填，回车默认 /cache）"
    read -erp "CACHE_DIR:" CACHE_DIR
    [[ -z "${CACHE_DIR}" ]] && CACHE_DIR="/cache"

    INFO "请输入您的挂载目录，用于存放缓存文件（选填，回车默认 $(pwd)/pg_tgsearch）"
    read -erp "VOLUME_DIR:" VOLUME_DIR
    [[ -z "${VOLUME_DIR}" ]] && VOLUME_DIR="$(pwd)/pg_tgsearch"

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
        -e API_DOWNLOAD_VIDEO="${API_DOWNLOAD_VIDEO}" \
        -e CACHE_DIR="${CACHE_DIR}" \
        -v "${VOLUME_DIR}/cache:${CACHE_DIR}" \
        -v "${VOLUME_DIR}/tmp:/tmp" \
        --restart=always \
        ddstomo/pg_tgsearch:latest

    INFO "安装完成！"

}

function update_pg_tgsearch_docker() {

    for i in $(seq -w 3 -1 0); do
        echo -en "即将开始更新 PG tgsearch${Blue} $i ${Font}\r"
        sleep 1
    done
    container_update pg_tgsearch

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
    echo -e "2、更新"
    echo -e "3、卸载"
    echo -e "——————————————————————————————————————————————————————————————————————————————————"
    read -erp "请输入数字 [1-3]:" num
    case "$num" in
    1)
        clear
        install_pg_tgsearch_docker
        ;;
    2)
        clear
        update_pg_tgsearch_docker
        ;;
    3)
        clear
        uninstall_pg_tgsearch_docker
        ;;
    *)
        clear
        ERROR '请输入正确数字 [1-3]'
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
