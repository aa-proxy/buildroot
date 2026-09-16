#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPGRADE_TOOL="$SCRIPT_DIR/upgrade_tool"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    echo "Usage: $(basename "$0") <machine> <image>"
    echo
    echo "Machines:"
    echo "    aaw1-cs317   eMMC, takes the sdcard.img file"
    echo "    aaw2b        SPI NAND, takes the images directory"
    echo "    aaw3         SPI NAND, takes the images directory"
    echo
    echo "Examples:"
    echo "    $(basename "$0") aaw1-cs317 buildroot/output/aaw1-cs317/images/sdcard.img"
    echo "    $(basename "$0") aaw2b buildroot/output/aaw2b/images"
}

wait_for_device() {
  while ! lsusb 2>/dev/null | grep "2207:$USB_PID" -q; do
    sleep 1
  done
}

# eMMC/SD boards: the whole GPT image goes to LBA 0 with upgrade_tool.
flash_upgrade_tool() {
  local loader_bin="$SCRIPT_DIR/${LOADER}_loader.bin"

  if [ ! -f "$loader_bin" ]; then
    echo "Error: loader not found: $loader_bin"
    exit 1
  fi

  # The loader is only accepted while the BootROM sits in Maskrom mode. In
  # Loader mode one is already running and upgrade_tool rejects the command.
  if "$UPGRADE_TOOL" ld | grep -q "Mode=Maskrom"; then
    echo "Device is in Maskrom mode, uploading loader."
    "$UPGRADE_TOOL" db "$loader_bin"
    echo "Waiting for device to re-enumerate."
    wait_for_device
  fi

  "$UPGRADE_TOOL" wl 0 "$IMAGE"
  "$UPGRADE_TOOL" rd
}

# SPI NAND boards: rkdownload.sh reads the partition table out of env.img and
# writes each matching <partition>.img from the image directory.
flash_rkdownload() {
  # Check if 'bc' is installed (rkdownload.sh needs it for partition maths)
  if ! command_exists "bc"; then
    echo "Error: 'bc' is not installed. Please install it and try again."
    exit 1
  fi

  "$SCRIPT_DIR/rkdownload.sh" -d "$IMAGE"
}

case $1 in
aaw1-cs317*)
  USB_PID="110b"  # RV1109
  LOADER=cs317
  NAND=false
  ;;
aaw2*)
  USB_PID="110c"  # RV1103/RV1106
  NAND=true
  ;;
aaw3*)
  USB_PID="110e"  # RV1103B
  NAND=true
  ;;
*)
  echo "Invalid machine $1"
  echo
  usage
  exit 1
  ;;
esac

IMAGE=$2
if [ -z "$IMAGE" ]; then
  echo "Error: no image given."
  echo
  usage
  exit 1
fi
if [ ! -e "$IMAGE" ]; then
  echo "Error: no such file or directory: $IMAGE"
  exit 1
fi

echo "Waiting for device..."
wait_for_device
echo "Device found."
sleep 1

if [ "$NAND" = true ]
then
  flash_rkdownload
else
  flash_upgrade_tool
fi

echo "Device flashed successfully."
