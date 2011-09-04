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

    _TARGET_FILE="$ROOTDIR"/"${_FILE}"

    if [[ ! -f "${_TARGET_FILE}" ]]; then
        # ディレクトリがない場合は作成する
        _PARENT_DIR=`echo ${_TARGET_FILE} | sed -e 's/^\(.*\/\).*$/\1/'`
        if [[ ! -d "${_PARENT_DIR}" ]]; then
            mkdir -p "${_PARENT_DIR}"
        fi

        cp "${_FILE}" "${_TARGET_FILE}"

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
        ROOTDIR="$2"
        FILE="$3"

        if [[ -z "$ROOTDIR" || -z "$FILE" ]]; then
            echo 'Usage: mkchroot.sh copy ROOT FILE' > /dev/stderr
            echo '' > /dev/stderr
            echo 'mkchroot: No root directory or file specified' > /dev/stderr
            exit -1
        fi

        if [[ ! -d "$ROOTDIR" ]]; then
            echo "mkchroot: $ROOTDIR: No such directory" > /dev/stderr
            exit -1
        fi

        if [[ ! -f "$FILE" ]]; then
            echo "mkchroot: $FILE: No such file" > /dev/stderr
            exit -1
        fi

        copy "$FILE" "$ROOTDIR"
        ;;
    *) # それ以外のコマンド
        echo "mkchroot: $COMMAND: Unknown command" > /dev/stderr
        exit -1
        ;;
esac
