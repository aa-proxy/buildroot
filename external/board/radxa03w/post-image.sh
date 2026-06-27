#!/bin/bash

set -u
set -e
set -x

cat << EOF > "${BINARIES_DIR}/uboot_vars.txt"
bootpart=2
ustate=0
bootlimit=3
EOF

${HOST_DIR}/bin/mkenvimage -s 16384 -o "${BINARIES_DIR}/uboot.env" "${BINARIES_DIR}/uboot_vars.txt"

support/scripts/genimage.sh -c $BR2_EXTERNAL_AA_PROXY_OS_PATH/board/radxa03w/genimage.cfg

cp "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/radxa03w/swupdate/update.sh" "${BINARIES_DIR}/"

swugenerator -o "${BINARIES_DIR}/update_image.swu" \
             -a "${BINARIES_DIR}" \
             -s "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/radxa03w/swupdate/sw-description" \
             -e create