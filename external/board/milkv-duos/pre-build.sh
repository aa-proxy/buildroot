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

# Generate memory maps in different formats for future use
mkdir -p "${OUT_MEMMAP_DIR}"
python3 ${SCRIPTS_DIR}/mmap_conv.py --type h    ${MEM_DEFS} ${OUT_MEMMAP_DIR}/cvi_board_memmap.h
python3 ${SCRIPTS_DIR}/mmap_conv.py --type conf ${MEM_DEFS} ${OUT_MEMMAP_DIR}/cvi_board_memmap.conf
python3 ${SCRIPTS_DIR}/mmap_conv.py --type ld   ${MEM_DEFS} ${OUT_MEMMAP_DIR}/cvi_board_memmap.ld
python3 ${SCRIPTS_DIR}/memory_display.py        ${MEM_DEFS} ${OUT_MEMMAP_DIR}/cvi_board_memmap.txt

# Generate some magic U-Boot stuff
python3 ${BUILDROOT_DIR}/tools/image_tool/mkcvipart.py $PARTITION_XML ${OUT_MEMMAP_DIR}
python3 ${BUILDROOT_DIR}/tools/image_tool/mk_imgHeader.py $PARTITION_XML ${OUT_MEMMAP_DIR}
