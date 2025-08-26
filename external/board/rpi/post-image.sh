#!/bin/bash

set -e

# workaround for:
# https://gitlab.com/buildroot.org/buildroot/-/issues/131
if grep -q 'rpi0w' "${BR2_CONFIG}"; then
    cp ${BUILD_DIR}/linux-custom/arch/arm/boot/zImage ${BUILD_DIR}/../images/Image
fi

# Adjust Bluetooth coexistence settings for all Raspberry Pi boards
# by modifying matching brcmfmac434*-sdio.txt firmware files.
# These changes reduce Wi-Fi aggressiveness to improve Bluetooth performance.
if grep -q 'rpi' "${BR2_CONFIG}"; then
    # Path to the firmware directory in the target filesystem
    FIRMWARE_DIR="${TARGET_DIR}/lib/firmware/brcm"

    # Loop over all matching firmware files
    for FIRMWARE_FILE in "${FIRMWARE_DIR}"/brcmfmac434*-sdio.txt; do
        # Skip if no files matched
        [ -f "$FIRMWARE_FILE" ] || continue

        echo "Patching $FIRMWARE_FILE"

        # Change btc_mode to 4 (for better Bluetooth coexistence)
        sed -i 's/^btc_mode=1/btc_mode=4/' "$FIRMWARE_FILE"

        # Optionally comment out btc_params if present
        sed -i 's/^btc_params/#btc_params/' "$FIRMWARE_FILE"
    done
fi

source board/raspberrypi/post-image.sh
