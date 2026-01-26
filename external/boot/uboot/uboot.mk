ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP),y)
RKBIN_VERSION = 2c1be1054e86338285309ecc20fa61fc15fd5437
RKBIN_ARCHIVE = rkbin-$(RKBIN_VERSION).tar.gz

define UBOOT_POST_EXTRACT_HOOKS_ROCKCHIP
	mkdir $(@D)/rkbin
	$(call suitable-extractor,$(UBOOT_DL_DIR)/$(RKBIN_ARCHIVE)) $(UBOOT_DL_DIR)/$(RKBIN_ARCHIVE) | \
				$(TAR) --strip-components=1 -C $(@D)/rkbin $(TAR_OPTIONS) -
	sed -i -e '/^select_tool/d' -e '/^clean/d' -e '/^\t*make/d' $(@D)/make.sh
	sed -i 's|RKBIN_TOOLS=\.\./rkbin/tools|RKBIN_TOOLS=\./rkbin/tools|' $(@D)/make.sh
endef

define UBOOT_POST_BUILD_HOOKS_ROCKCHIP
	cd $(@D) && ./make.sh && ./make.sh --spl
	$(@D)/tools/mkenvimage -s 0x20000 -p 0x0 -o $(@D)/env.img $(BR2_TARGET_UBOOT_ROCKCHIP_ENV_FILE)
endef

define UBOOT_POST_INSTALL_IMAGES_HOOKS_ROCKCHIP
	cp -dpf $(@D)/*_download_*.bin $(BINARIES_DIR)/download.bin
	cp -dpf $(@D)/*_idblock_*.img $(BINARIES_DIR)/idblock.img
	cp -dpf $(@D)/uboot.img $(BINARIES_DIR)/
	cp -dpf $(@D)/env.img $(BINARIES_DIR)/env.img
	cp -dpf $(@D)/env.img $(BINARIES_DIR)/env_r.img
endef

UBOOT_EXTRA_DOWNLOADS += https://github.com/cpebit/rkbin/archive/$(RKBIN_VERSION)/$(RKBIN_ARCHIVE)
BR_NO_CHECK_HASH_FOR += $(RKBIN_ARCHIVE)
UBOOT_POST_EXTRACT_HOOKS += UBOOT_POST_EXTRACT_HOOKS_ROCKCHIP
UBOOT_POST_BUILD_HOOKS += UBOOT_POST_BUILD_HOOKS_ROCKCHIP
UBOOT_POST_INSTALL_IMAGES_HOOKS += UBOOT_POST_INSTALL_IMAGES_HOOKS_ROCKCHIP
endif