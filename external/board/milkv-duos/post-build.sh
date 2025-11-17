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

# Sophgo FSBL (First Stage Boot Loader)
# We cannot add this as a package because it is a bootloader/BR2_TARGET_ package
rm -rf ${FSBL_BUILD_DIR}
git clone https://github.com/sophgo/fsbl.git ${FSBL_BUILD_DIR}
cd ${FSBL_BUILD_DIR}
patch -p1 < ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/patches/fsbl/0001-fiptool.py-use-a-host-python3.patch
patch -p1 < ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/patches/fsbl/0002-make_helpers-fip.mk-adjust-OpenSBI-monitor-path.patch
mkdir build
cp ${OUT_MEMMAP_DIR}/cvi_board_memmap.h ${FSBL_BUILD_DIR}/build

export PATH=/app/host-tools/gcc/riscv64-linux-musl-x86_64/bin:$PATH

ARCH=riscv \
CHIP_ARCH=CV181X \
CROSS_COMPILE_GLIBC_RISCV64=riscv64-unknown-linux-musl- \
DDR_CFG=ddr3_1866_x16 \
LOG_LEVEL=2 \
BLCP_2ND_PATH=../../images/cvirtos.bin \
LOADER_2ND_PATH=../../images/u-boot.bin \
make -j$(nproc --all) \
-C ${FSBL_BUILD_DIR} \
O=${FSBL_BUILD_DIR}/build

cp ${FSBL_BUILD_DIR}/build/fip.bin ${BINARIES_DIR}
