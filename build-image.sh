#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No argument provided."
    echo "Usage: $0 <board/shell>"
    exit 1
fi

ARG=$1

if [ "$ARG" = "shell" ]; then
    echo "Entering interactive shell..."
    exec /bin/bash # Replace the current script process with a bash shell
else
    # make the configs dir writable
    sudo chmod a+w external/configs
    # merge defconfig for specified board
    external/scripts/defconfig_merger.sh ${ARG}

    BUILDROOT_DIR=/app/buildroot
    OUTPUT=${BUILDROOT_DIR}/output/${ARG}
    mkdir -p ${OUTPUT}

    # We need to download the host-tools for MilkV.
    # FIXME: consider using the upstream repository (https://github.com/sophgo/host-tools).
    # Downloading them into the target output and setting BR2_TOOLCHAIN_EXTERNAL_PATH
    # doesn't help, because Buildroot still resolves the path as /app/host-tools.
    # So the tools must be placed directly in the root /app directory.
    if [ "$ARG" = "milkv-duos" ]; then
        sudo git clone --depth=1 https://github.com/milkv-duo/host-tools.git /app/host-tools
    fi

    cd ${BUILDROOT_DIR}
    make BR2_EXTERNAL=../external/ O=${OUTPUT} gen_${ARG}_defconfig
    cd ${OUTPUT}
    make -j$(nproc --all)
fi
