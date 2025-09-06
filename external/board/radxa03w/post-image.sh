#!/bin/bash

set -u
set -e
set -x

# DTBs
mkdir -p $BINARIES_DIR/rockchip
cp -a $BINARIES_DIR/*.dtb $BINARIES_DIR/rockchip
support/scripts/genimage.sh -c $BR2_EXTERNAL_AA_PROXY_OS_PATH/board/radxa03w/genimage.cfg

