#!/bin/bash

# Exit if no argument is provided
if [ -z "$1" ]; then
    echo "Error: No argument provided."
    echo "Usage: $0 <board>"
    exit 1
fi

ARG=$1
CONFIG_DIR="external/configs"
GEN_DEFCONFIG="${CONFIG_DIR}/gen_${ARG}_defconfig"

# Copy main board defconfig
cp "${CONFIG_DIR}/${ARG}_defconfig" "${GEN_DEFCONFIG}"

# Append common config for all boards
cat "${CONFIG_DIR}/common.part" >> "${GEN_DEFCONFIG}"

# If the board is a Raspberry Pi, append additional RPi config
if [[ "$ARG" == rpi* ]]; then
    cat "${CONFIG_DIR}/common_rpi.part" >> "${GEN_DEFCONFIG}"
fi
