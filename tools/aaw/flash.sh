#!/bin/bash
set -e

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if 'bc' is installed
if ! command_exists "bc"; then
    echo "Error: 'bc' is not installed. Please install it and try again."
    exit 1
fi

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
