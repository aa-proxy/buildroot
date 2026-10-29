#!/bin/bash

set -u
set -e

source ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/common/post-build.sh

# No brcmfmac CLM blob is installed: the AP625x firmwares all carry a full
# CLM (every country) built in, so brcmfmac's "no clm_blob available" warning
# is harmless.

# Fix permissions on target
chmod 644 ${TARGET_DIR}/lib/firmware/regulatory.db*
