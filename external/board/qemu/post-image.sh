#!/bin/bash

#Generate sdcard.img
BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/qemu/genimage.cfg.in"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

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
          -append "rootwait root=/dev/vda1 rootrw=/dev/vda2 rootrwoptions=rw,noatime nomodeset console=tty1 console=ttyS0" \
          -net nic,model=virtio \
          -net user,hostfwd=tcp::2022-:22,hostfwd=tcp::8080-:80 \
          -serial stdio
	)
_EOF_

chmod +x "${START_QEMU_SCRIPT}"
