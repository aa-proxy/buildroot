#!/bin/bash

#Generate sdcard.img
support/scripts/genimage.sh -c "${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/qemu/genimage.cfg"

#Generate start-qemu.sh
START_QEMU_SCRIPT="${BINARIES_DIR}/start-qemu.sh"
cat <<-_EOF_ > "${START_QEMU_SCRIPT}"
	#!/bin/sh
	(
	BINARIES_DIR="\${0%/*}/"
	cd \${BINARIES_DIR}

	export PATH="${HOST_DIR}/bin:\${PATH}"
	exec qemu-system-x86_64 \
          -M pc \
          -kernel bzImage \
          -drive file=sdcard.img,if=virtio,format=raw \
          -append "rootwait root=/dev/vda1 init=/etc/overlay_init rootrw=/dev/vda2 rootrwoptions=rw,noatime nomodeset console=tty1 console=ttyS0" \
          -net nic,model=virtio \
          -net user,hostfwd=tcp::2022-:22,hostfwd=tcp::8080-:80 \
          -serial stdio
	)
_EOF_

chmod +x "${START_QEMU_SCRIPT}"
