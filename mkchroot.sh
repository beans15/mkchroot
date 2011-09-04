#!/bin/sh

COMMAND=$1

if [[ -z $1 ]]; then
    echo 'Usage: mkchroot.sh COMMAND ...' > /dev/stderr
    exit -1
fi

case "$1" in
    "init") # 初期化を行う
        ROOTDIR="$2"

        if [[ -z "$ROOTDIR" ]]; then
            echo 'Usage: mkchroot.sh init DIRECTORY' > /dev/stderr
            echo '' > /dev/stderr
            echo 'mkchroot: No root directory specified' > /dev/stderr
            exit -1
        fi

        if [[ ! -d "$ROOTDIR" ]]; then
            # 基本的なディレクトリを作成、ライブラリをコピー
            mkdir -p "$ROOTDIR"/{bin,etc,home,lib,usr/bin,usr/lib,usr/local/bin,usr/local/lib,var,tmp}
            cp -r /usr/lib/system "$ROOTDIR"/usr/lib/
        fi
        ;;
esac
