#!/bin/bash

FILE="<pypy.tar.gz>" #这里需要修改成 pypy 的压缩包的名字
TARGET_DIR="/chroot/domjudge/usr/local/lib"
PYPY_DIR="<pypy>" #这里也是需要修改成 pypy 的压缩包的名字
PYPY_PATH="$TARGET_DIR/$PYPY_DIR"
LINK_FROM="/usr/local/lib/$PYPY_DIR/bin/pypy3"
LINK_TO="/usr/local/bin/pypy3"

CONTAINER_NAME="$1"   # 容器名前缀
SCOPE="$2"            # 最大编号

# 检查参数
if [[ -z "$CONTAINER_NAME" || -z "$SCOPE" ]]; then
    echo "Usage: $0 <container-prefix> <max-index>"
    exit 1
fi

# 检查压缩包是否存在
if [[ ! -f "$FILE" ]]; then
    echo "Error: $FILE not found in current directory!"
    exit 1
fi

for i in $(seq 0 "$SCOPE"); do
    CONTAINER="${CONTAINER_NAME}-${i}"

    # 检查容器是否存在
    if ! docker ps -a --format "{{.Names}}" | grep -wq "$CONTAINER"; then
        echo "!!! Container $CONTAINER not found, skipping"
        continue
    fi

    # 检测 pypy 是否存在
    EXISTS=$(docker exec "$CONTAINER" sh -c "[ -d \"$PYPY_PATH\" ] && echo yes || echo no")

    if [[ "$EXISTS" == "yes" ]]; then
        echo ">>> Pypy already exists — skipping extract."
    else
        docker cp "$FILE" "$CONTAINER":/tmp/ || { echo "Copy failed"; continue; }

        docker exec "$CONTAINER" sh -c "
            mkdir -p $TARGET_DIR &&
            tar -xzf /tmp/$FILE -C $TARGET_DIR
        "
    fi

    #创建软链接
    docker exec "$CONTAINER" sh -c "
        chroot /chroot/domjudge /bin/bash -c '
            mkdir -p /usr/local/bin &&
            ln -sf \"$LINK_FROM\" \"$LINK_TO\"
        '
    "

    #重启
    docker stop "$CONTAINER" >/dev/null 2>&1
    docker start "$CONTAINER" >/dev/null 2>&1

    echo ">>> $CONTAINER done."
done
