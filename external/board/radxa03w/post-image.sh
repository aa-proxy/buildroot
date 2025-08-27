#!/bin/bash

set -u
set -e
set -x

# DTBOs, although we dont use any
LINUX_DIR=`find $BASE_DIR/build -name 'vmlinux' -type f | xargs dirname`
mkdir -p $BINARIES_DIR/rockchip/overlays
if [ -d ${LINUX_DIR}/arch/arm64/boot/dts/rockchip/overlay ]; then
  cp -a ${LINUX_DIR}/arch/arm64/boot/dts/rockchip/overlay/*.dtbo $BINARIES_DIR/rockchip/overlays
fi

UBOOT_DIR=`find $BASE_DIR/build -name 'uboot-*' -type d | head -1`

# UBoot Script
$UBOOT_DIR/tools/mkimage -C none -A arm -T script -d $BR2_EXTERNAL_AA_PROXY_OS_PATH/board/radxa03w/boot.cmd $BINARIES_DIR/boot.scr

# DTBs
mkdir -p $BINARIES_DIR/rockchip
cp -a $BINARIES_DIR/*.dtb $BINARIES_DIR/rockchip
support/scripts/genimage.sh -c $BR2_EXTERNAL_AA_PROXY_OS_PATH/board/radxa03w/genimage.cfg

