#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # QEMU graphical window' ${TARGET_DIR}/etc/inittab
fi

# Ensure proper /etc/network/interfaces for qemu network access
    cat << EOF > ${TARGET_DIR}/etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF

# Modify /etc/fstab entries
if [ -e ${TARGET_DIR}/etc/fstab ]; then
    # Remove the /dev/mmcblk0p1 line
    sed -i '/^[[:space:]]*\/dev\/mmcblk0p1[[:space:]]/d' ${TARGET_DIR}/etc/fstab

    # Replace /dev/mmcblk0p3 with /dev/vda2
    sed -i 's|^/dev/mmcblk0p3|/dev/vda2|' ${TARGET_DIR}/etc/fstab
fi
