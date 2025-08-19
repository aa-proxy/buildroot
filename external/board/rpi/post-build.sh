#!/bin/bash

set -u
set -e

${BR2_EXTERNAL_AA_PROXY_OS_PATH}/scripts/generate-issue.sh

# Read BR2_DEFCONFIG value from the .config file
DEFCONFIG_PATH=$(grep '^BR2_DEFCONFIG=' "$BR2_CONFIG" | cut -d= -f2 | tr -d '"')

# Extract just the filename (e.g. "rpi4_defconfig")
DEFCONFIG_NAME=$(basename "$DEFCONFIG_PATH")

# Check if the filename contains "rpi4" or "rpi5"
if echo "$DEFCONFIG_NAME" | grep -qE 'rpi4|rpi5'; then
    echo "Defconfig matches rpi4 or rpi5: $DEFCONFIG_NAME"

    # Enable DHCP support for eth0 interface
    cat << EOF >> "${TARGET_DIR}/etc/network/interfaces"
auto eth0
iface eth0 inet dhcp
EOF
fi

source board/raspberrypi/post-build.sh
