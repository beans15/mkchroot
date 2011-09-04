#!/bin/sh

COMMAND="$1"

if [[ -z "$COMMAND" ]]; then
    echo 'Usage: mkchroot.sh COMMAND ...' > /dev/stderr
    exit -1
fi

copy()
{
    _FILE="$1"
    ROOTDIR="$2"

    if [[ ! -f "$ROOTDIR"/"${_FILE}" ]]; then
        cp "${_FILE}" "$ROOTDIR"/"${_FILE}"

        # 依存関係を調べる
        for f in `otool -L "${_FILE}" | grep -v '^.*:' | awk '{print $1}'`; do
            copy "$f" "$ROOTDIR"
        done
    fi
}

case "$COMMAND" in
    "init") # 初期化を行う
        ROOTDIR="$2"

        if [[ -z "$ROOTDIR" ]]; then
            echo 'Usage: mkchroot.sh init ROOT' > /dev/stderr
            echo '' > /dev/stderr
            echo 'mkchroot: No root directory specified' > /dev/stderr
            exit -1
        fi

        if [[ ! -d "$ROOTDIR" ]]; then
            # 基本的なディレクトリを作成、ライブラリをコピー
            mkdir -p "$ROOTDIR"/{bin,etc,home,lib,usr/bin,usr/lib,usr/local/bin,usr/local/lib,var,tmp}
            cp -r /usr/lib/system "$ROOTDIR"/usr/lib/
            cp /usr/lib/{dyld,libSystem.B.dylib,libgcc_s.1.dylib} "$ROOTDIR"/usr/lib/
        fi
        ;;
    "copy") # ファイルをコピーする
        FILE="$2"
        ROOTDIR="$3"

        if [[ -z "$ROOTDIR" || -z "$FILE" ]]; then
            echo 'Usage: mkchroot.sh copy FILE ROOT' > /dev/stderr
            echo '' > /dev/stderr
            echo 'mkchroot: No root directory or file specified' > /dev/stderr
            exit -1
        fi

        if [[ ! -d "$ROOTDIR" ]]; then
            echo "mkchroot: $ROOTDIR: No such directory" > /dev/stderr
            exit -1
        fi

        copy "$FILE" "$ROOTDIR"
        ;;
    *) # それ以外のコマンド
        echo "mkchroot: $COMMAND: Unknown command" > /dev/stderr
        exit -1
        ;;
esac
