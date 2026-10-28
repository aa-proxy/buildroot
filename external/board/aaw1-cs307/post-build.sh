#!/bin/bash

set -u
set -e

source ${BR2_EXTERNAL_AA_PROXY_OS_PATH}/board/common/post-build.sh

# The AP6254 (BCM43454) wants a CLM blob for the regional channel/power limits.
# Fetch it at build time instead of keeping a binary in the repo. The Broadcom
# 43455 blob from armbian/firmware is the one that works for this chip, it only
# has to be installed under the 43454 name the driver asks for.
# Pinned to a commit and checked against a hash, so the build stays reproducible.
CLM_COMMIT="9934dbd5541bb49e2063089437a981f752c87b7f"
CLM_URL="https://raw.githubusercontent.com/armbian/firmware/${CLM_COMMIT}/brcm/brcmfmac43455-sdio.clm_blob"
CLM_SHA256="8e2250518bc789e53109728c3c0a6124bc3801a75a1cb4966125753cf1f0252e"
CLM_DST="${TARGET_DIR}/lib/firmware/brcm/brcmfmac43454-sdio.clm_blob"

mkdir -p "$(dirname "${CLM_DST}")"
echo "Downloading brcmfmac43454-sdio.clm_blob..."
wget -q -O "${CLM_DST}" "${CLM_URL}"
echo "${CLM_SHA256}  ${CLM_DST}" | sha256sum -c -

# Fix permissions on target
chmod 644 ${TARGET_DIR}/lib/firmware/regulatory.db*
chmod 644 ${TARGET_DIR}/lib/firmware/brcm/brcmfmac4345*-sdio.clm_blob
