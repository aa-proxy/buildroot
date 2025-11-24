#!/bin/bash

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

${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/common/generate-issue.sh

# copy FreeRTOS output binary to images
cp ${RTOS_BUILD_DIR}/cvitek/install/bin/cvirtos.bin ${BINARIES_DIR}

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

# fetching AIC firmware (until we use an AIC package)
OUTDIR="$TARGET_DIR/lib/firmware/aic8800_sdio"
BASE_URL="https://github.com/radxa-pkg/aic8800/raw/451a1c8f14dad821034017ccb902eaf0a2b8c2ee/src/SDIO/driver_fw/fw/aic8800D80"
FILES=(
    "aic_powerlimit_8800d80.txt"
    "aic_userconfig_8800d80.txt"
    "fmacfw_8800d80_h_u02.bin"
    "fmacfw_8800d80_h_u02_ipc.bin"
    "fmacfw_8800d80_u02.bin"
    "fmacfw_8800d80_u02_ipc.bin"
    "fmacfwbt_8800d80_h_u02.bin"
    "fmacfwbt_8800d80_u02.bin"
    "fw_adid_8800d80_u02.bin"
    "fw_patch_8800d80_u02.bin"
    "fw_patch_8800d80_u02_ext0.bin"
    "fw_patch_8800d80_u04.bin"
    "fw_patch_table_8800d80_u02.bin"
    "fw_patch_table_8800d80_u04.bin"
    "lmacfw_rf_8800d80_u02.bin"
)
mkdir -p "$OUTDIR"
for f in "${FILES[@]}"; do
    echo "Downloading $f..."
    wget -O "$OUTDIR/$f" "$BASE_URL/$f"
done
