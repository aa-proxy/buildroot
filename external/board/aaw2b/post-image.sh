#!/bin/bash

set -e

support/scripts/genimage.sh -c "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/aaw2b/genimage.cfg"

swugenerator -o "${BINARIES_DIR}/update_image.swu" -a "${BINARIES_DIR}" -s "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/aaw2b/sw-description" -e create
