#!/bin/sh

set -u
set -e
set -x

# Some initial variables
MEM_DEFS="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/memmap.py"
SCRIPTS_DIR="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/scripts"
OUT_MEMMAP_DIR="${BINARIES_DIR}/memmap"
BUILDROOT_DIR="$(realpath "$BR2_EXTERNAL_AA_PROXY_OS_PATH/..")"

BOARD="$(realpath "$BUILD_DIR/..")"
case "${BOARD}" in
    *-emmc)
        PARTITION_XML="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/partition/partition_emmc.xml"
        ;;
    *)
        PARTITION_XML="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/partition/partition_sd.xml"
        ;;
esac

# final steps to create a proper bootable SD card image / eMMC
cd ${BINARIES_DIR}
lzma -c -9 -f -k Image > Image.lzma
# Copy definitions first, since the build expects paths relative to this file
cp ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/u-boot/multi.its .
${BUILD_DIR}/uboot*/tools/mkimage -f multi.its -r boot.itb
mkdir -p rawimages output

case "${BOARD}" in
    *-emmc)
        # Do not create upgrade.zip here. Produce the individual CIMG images
        # required by Milk-V's eMMC flashing tools instead.

        cp boot.itb rawimages/boot.emmc
        cp rootfs.ext4 rawimages/rootfs_ext4.emmc

        # Create CIMG images and collect all files needed by the `usb_dl` flashing tool.
        python3 /app/tools/image_tool/raw2cimg.py rawimages/boot.emmc ./output $PARTITION_XML
        python3 /app/tools/image_tool/raw2cimg.py rawimages/rootfs_ext4.emmc ./output $PARTITION_XML
        python3 /app/tools/image_tool/raw2cimg.py ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/bootlogo/logo.jpg ./output $PARTITION_XML

        # FIP image
        cp fip.bin ./output

        # Partition definition
        cp ${PARTITION_XML} ./output
        ;;
    *)
        cp boot.itb rawimages/boot.sd

        # create a logo partition
        python3 /app/tools/image_tool/raw2cimg.py ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/milkv-duos/bootlogo/logo.jpg ./output $PARTITION_XML

        # make a final SD card image
        ${BASE_DIR}/../../support/scripts/genimage.sh -c $BR2_EXTERNAL_AA_PROXY_OS_PATH/board/milkv-duos/genimage.cfg
        ;;
esac
