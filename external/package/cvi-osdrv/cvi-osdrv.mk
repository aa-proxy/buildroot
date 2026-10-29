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
endef

$(eval $(generic-package))
