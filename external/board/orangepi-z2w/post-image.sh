#!/bin/bash
set -u
set -e

echo ">>> Post-image script arguments <$*>"

echo ">>> Generating sdcard image"
support/scripts/genimage.sh -c "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/orangepi-z2w/genimage.cfg"
