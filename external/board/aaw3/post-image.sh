#!/bin/bash

set -e

support/scripts/genimage.sh -c "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/aaw3/genimage.cfg"

ln -sf boot.img "${BINARIES_DIR}/boot1.img"
ln -sf boot.img "${BINARIES_DIR}/boot2.img"

swugenerator -o "${BINARIES_DIR}/update_image.swu" -a "${BINARIES_DIR}" -s "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/aaw3/sw-description" -e create
