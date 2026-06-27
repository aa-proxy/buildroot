#!/bin/sh

case "$1" in
postinst)
	ROOTFS="$(swupdate -g)"
	if [ "$ROOTFS" = "/dev/mmcblk0p2" ]; then
		fw_setenv bootpart 3
	else
		fw_setenv bootpart 2
	fi
	fw_setenv ustate 1
	;;
esac

exit 0
