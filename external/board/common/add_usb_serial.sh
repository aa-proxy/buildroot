#!/bin/sh

set -u
set -e

# Add a console on ttyGS0
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^ttyGS0::' ${TARGET_DIR}/etc/inittab || \
        sed -i '/GENERIC_SERIAL/a\
ttyGS0::respawn:/sbin/getty -L ttyGS0 115200 vt100 # usb serial' ${TARGET_DIR}/etc/inittab
fi
