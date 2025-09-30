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
    cd ${BUILDROOT_DIR}
    make BR2_EXTERNAL=../external/ O=${OUTPUT} gen_${ARG}_defconfig
    cd ${OUTPUT}
    make -j$(nproc --all)
fi
