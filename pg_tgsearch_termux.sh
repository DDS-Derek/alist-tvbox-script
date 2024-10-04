#!/bin/bash
# shellcheck shell=bash

echo "感谢：TG佬@nobody,PG作者大佬"

echo "下载运行文件中..."
if ! curl --insecure -fSL https://github.com/fish2018/PG/archive/refs/heads/main.zip -o main.zip; then
	echo "下载失败，请确保您可以访问 github.com"
	exit 1
fi
echo "解压文件中..."
if ! unzip main.zip; then
	echo "解压失败"
	exit 1
fi
if ! unzip PG-main/tgsearch* -d PG-main; then
	echo "解压失败"
	exit 1
fi

case $(uname -m) in
armv7* | armv8l)
	mv PG-main/tgsearch.arm32v7 ./tgsearch
	;;
aarch64 | armv8* | arm64)
	mv PG-main/tgsearch.arm64v8 ./tgsearch
	;;
x86_64 | amd64)
	mv PG-main/tgsearch.x86_64 ./tgsearch
	;;
*)
	echo "未知的架构 $(uname -m) unknown architecture"
	exit 1
	;;
esac

rm -rf PG-main
rm -f main.zip

chmod 755 ./tgsearch

unset LD_PRELOAD; ./tgsearch
