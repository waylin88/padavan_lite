#!/bin/sh
# 下载 hanwckf 的预编译工具链到本目录 (toolchain-3.4.x)
# 工具链来源: https://github.com/hanwckf/padavan-toolchain/releases/tag/v1.1
#   gcc 7.4.0 + uclibc-ng 1.0.32 (crosstool-ng 1.24.0 构建, 静态链接, 带 SO_REUSEPORT 补丁)
# 若 toolchain-3.4.x 已存在则直接跳过。
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLCHAIN_DIR="$DIR/toolchain-3.4.x"
DL_NAME="mipsel-linux-uclibc.tar.xz"
DL_URL="https://github.com/hanwckf/padavan-toolchain/releases/download/v1.1/${DL_NAME}"

if [ -d "$TOOLCHAIN_DIR" ]; then
	echo "$TOOLCHAIN_DIR 已存在，跳过下载。"
	exit 0
fi

cd "$DIR"
echo "正在下载工具链: $DL_URL"
curl -fL --retry 3 -o "$DL_NAME" "$DL_URL"
mkdir -p "$TOOLCHAIN_DIR"
tar -xf "$DL_NAME" -C "$TOOLCHAIN_DIR"
rm -f "$DL_NAME"
echo "工具链已解压到 $TOOLCHAIN_DIR"