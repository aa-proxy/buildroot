#!/bin/sh

set -u
set -e
set -x

# Some initial variables
MEM_DEFS="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/memmap.py"
SCRIPTS_DIR="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/scripts"
OUT_MEMMAP_DIR="${BINARIES_DIR}/memmap"
PARTITION_XML="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/partition/partition_sd.xml"
BUILDROOT_DIR="$(realpath "$BR2_EXTERNAL_AA_PROXY_OS_PATH/..")"
FSBL_BUILD_DIR="${BUILD_DIR}/fsbl"
RTOS_BUILD_DIR="${BUILD_DIR}/freertos*"

# final steps to create a proper bootable SD card image
cd ${BINARIES_DIR}
lzma -c -9 -f -k Image > Image.lzma
# Copy definitions first, since the build expects paths relative to this file
cp ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/u-boot/multi.its .
${BUILD_DIR}/uboot*/tools/mkimage -f multi.its -r boot.itb
mkdir -p rawimages
cp boot.itb rawimages/boot.sd
