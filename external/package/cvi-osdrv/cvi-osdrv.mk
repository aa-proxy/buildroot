################################################################################
#
# cvi-osdrv
#
################################################################################

# sophgo/osdrv, branch sg200x-dev (same revision as in Milk-V duo-buildroot-sdk-v2)
CVI_OSDRV_VERSION = c7aeabf7753552f17d45e3deb112db6a38e59445
CVI_OSDRV_SITE = $(call github,sophgo,osdrv,$(CVI_OSDRV_VERSION))
CVI_OSDRV_LICENSE = GPL-2.0
CVI_OSDRV_DEPENDENCIES = linux

# The VPU firmware is loaded by cvi_vc_driver from /usr/share/fw_vcodec at
# channel creation time (CVI_VENC_CreateChn fails with NULL_PTR without it).
# coda980.bin: H.264 core, monet.bin: H.265 core. Taken from the Milk-V SDK
# at a pinned commit.
CVI_OSDRV_FW_URL = https://raw.githubusercontent.com/milkv-duo/duo-buildroot-sdk-v2/6f8962c394dd0a05729abb089f0feb7d5cc4aa5e/device/generic/rootfs_overlay/common/usr/share/fw_vcodec
CVI_OSDRV_EXTRA_DOWNLOADS = \
	$(CVI_OSDRV_FW_URL)/coda980.bin \
	$(CVI_OSDRV_FW_URL)/monet.bin

# Only what is needed for the video codec. Order matters: every module
# picks up the Module.symvers of the previous ones (KBUILD_EXTRA_SYMBOLS).
CVI_OSDRV_MODULES = sys base vcodec jpeg cvi_vc_drv

# Per-module Makefiles rely on $(PWD), so we have to cd into each directory
# (exactly what osdrv/Makefile does) instead of using make -C.
CVI_OSDRV_MAKE_OPTS = \
	$(LINUX_MAKE_FLAGS) \
	KERNEL_DIR=$(LINUX_DIR) \
	CVIARCH=CV181X \
	CVIARCH_L=cv181x \
	CHIP_ARCH=CV181X

define CVI_OSDRV_BUILD_CMDS
	$(foreach m,$(CVI_OSDRV_MODULES), \
		cd $(@D)/interdrv/$(m) && \
		$(TARGET_MAKE_ENV) $(MAKE) $(CVI_OSDRV_MAKE_OPTS) all || exit 1;)
endef

# depmod is run by Buildroot at the end of the build, so modprobe
# resolves the dependencies between these modules on its own.
define CVI_OSDRV_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra
	$(foreach m,$(CVI_OSDRV_MODULES), \
		find $(@D)/interdrv/$(m) -maxdepth 1 -name '*.ko' \
			-exec $(INSTALL) -m 0644 {} \
			$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/ \; ;)
	$(INSTALL) -D -m 0644 $(CVI_OSDRV_DL_DIR)/coda980.bin \
		$(TARGET_DIR)/usr/share/fw_vcodec/coda980.bin
	$(INSTALL) -D -m 0644 $(CVI_OSDRV_DL_DIR)/monet.bin \
		$(TARGET_DIR)/usr/share/fw_vcodec/monet.bin
endef

$(eval $(generic-package))
