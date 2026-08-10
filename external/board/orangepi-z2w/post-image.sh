#!/bin/bash
set -u
set -e

echo ">>> Post-image script arguments <$*>"

echo ">>> Generating sdcard image"
support/scripts/genimage.sh -c "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/orangepi-z2w/genimage.cfg"

echo ">>> Generating swu image"
swugenerator -o "${BINARIES_DIR}/update_image.swu" \
             -a "${BINARIES_DIR}" \
             -s "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/orangepi-z2w/swupdate/sw-description" \
             -e create
