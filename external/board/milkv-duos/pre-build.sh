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

# We need to use this specific toolchain for building Rust binaries.
# The reason is that we cannot rely on the system toolchain from Sophgo,
# because compiling OpenSSL fails with errors like:
#     crypto/riscv64cpuid.s:67: Error: unknown CSR `vlenb`
# This toolchain is compatible both with our Buildroot host
# and with the Rust-supported riscv64-musl target.
if [ ! -d ${BUILD_DIR}/riscv ]; then
    wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2023.09.27/riscv64-musl-ubuntu-20.04-gcc-nightly-2023.09.27-nightly.tar.gz -P /tmp
    tar -xzf /tmp/riscv64-musl-ubuntu-20.04-gcc-nightly-2023.09.27-nightly.tar.gz -C "${BUILD_DIR}"
    rm /tmp/riscv64-musl-ubuntu-20.04-gcc-nightly-2023.09.27-nightly.tar.gz
else
    echo "Rust toolchain already downloaded, skipping."
fi
