#!/bin/bash

set -u
set -e

${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/common/generate-issue.sh

source ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/common/add_usb_serial.sh


