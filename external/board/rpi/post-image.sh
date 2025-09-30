#!/bin/bash

set -e

# workaround for:
# https://gitlab.com/buildroot.org/buildroot/-/issues/131
if grep -q 'rpi0w' "${BR2_CONFIG}"; then
    cp ${BUILD_DIR}/linux-custom/arch/arm/boot/zImage ${BUILD_DIR}/../images/Image
fi

source board/raspberrypi/post-image.sh
