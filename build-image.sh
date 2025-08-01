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
    BUILDROOT_DIR=/app/buildroot
    OUTPUT=${BUILDROOT_DIR}/output/${ARG}

    mkdir -p ${OUTPUT}
    cd ${BUILDROOT_DIR}
    make BR2_EXTERNAL=../external/ O=${OUTPUT} ${ARG}_defconfig
    cd ${OUTPUT}
    make
fi
