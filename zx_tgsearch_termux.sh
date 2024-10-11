#!/bin/bash
# shellcheck shell=bash

echo "下载运行文件中..."

case $(uname -m) in
armv7* | armv8l)
	FILE_NAME="tgsou-armV7"
	;;
aarch64 | armv8* | arm64)
	FILE_NAME="tgsou-arm64"
	;;
x86_64 | amd64)
	FILE_NAME="tgsou-linux"
	;;
*)
	echo "未知的架构 $(uname -m) unknown architecture"
	exit 1
	;;
esac

if ! curl --insecure -fSL "https://gitlab.com/tvbox2/telegram-channel-video-downloader/-/raw/main/${FILE_NAME}?ref_type=heads&inline=false" -o ./tgsou; then
	echo "下载失败，请确保您可以访问 github.com"
	exit 1
fi

chmod 755 ./tgsou

unset LD_PRELOAD; ./tgsou
