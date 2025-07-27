#!/bin/bash
set -e

wait_for_device() {
  while ! lsusb 2>/dev/null | grep "2207:110c" -q; do
    sleep 1
  done
}

echo "Waiting for device..."
wait_for_device
echo "Device found."
sleep 1

sudo ./rkdownload.sh -d "$1"

echo "Device flashed successfully."
