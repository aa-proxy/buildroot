#!/bin/bash

set -e

support/scripts/genimage.sh -c "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/aaw1-cs307/genimage.cfg"

swugenerator -o "${BINARIES_DIR}/update_image.swu" -a "${BINARIES_DIR}" -s "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/aaw1-cs307/sw-description" -e create
