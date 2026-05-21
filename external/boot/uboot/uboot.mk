ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP),y)
RKBIN_VERSION = 2c1be1054e86338285309ecc20fa61fc15fd5437
RKBIN_ARCHIVE = rkbin-$(RKBIN_VERSION).tar.gz

define UBOOT_ROCKCHIP_POST_EXTRACT
	mkdir $(@D)/rkbin
	$(call suitable-extractor,$(UBOOT_DL_DIR)/$(RKBIN_ARCHIVE)) $(UBOOT_DL_DIR)/$(RKBIN_ARCHIVE) | \
				$(TAR) --strip-components=1 -C $(@D)/rkbin $(TAR_OPTIONS) -
	sed -i -e '/^select_tool/d' -e '/^clean/d' -e '/^\t*make/d' $(@D)/make.sh
	sed -i 's|RKBIN_TOOLS=\.\./rkbin/tools|RKBIN_TOOLS=\./rkbin/tools|' $(@D)/make.sh
	sed -i 's|\.\./rkbin/tools|\./rkbin/tools|' $(@D)/scripts/uboot.sh
endef

# --idblock packs idblock.bin for boards whose BootROM reads the ID block
# straight off eMMC/SD; --spl packs the download.bin and idblock.img pair the
# Rockchip flashing tools want for SPI NAND. They are separate sub-commands and
# emit different files, so pick the one the board is actually flashed with.
ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOCK),y)
define UBOOT_ROCKCHIP_POST_BUILD
	cd $(@D) && ./make.sh && ./make.sh --idblock
endef
else
define UBOOT_ROCKCHIP_POST_BUILD
	cd $(@D) && ./make.sh && ./make.sh --spl
endef
endif

define UBOOT_ROCKCHIP_BUILD_ENV_IMAGE
	$(@D)/tools/mkenvimage -s 0x20000 -p 0x0 \
		-o $(@D)/env.img \
		$(BR2_TARGET_UBOOT_ROCKCHIP_ENV_FILE)
endef

define UBOOT_ROCKCHIP_BUILD_BOOT_SCRIPT
	$(@D)/tools/mkimage -A arm -T script -C none \
	  -d $(BR2_TARGET_UBOOT_ROCKCHIP_BOOT_SCRIPT_FILE) \
	  $(@D)/boot.scr
endef

define UBOOT_ROCKCHIP_INSTALL_BOOT_SCRIPT
	$(INSTALL) -D -m 0644 $(@D)/boot.scr \
		$(TARGET_DIR)/boot/boot.scr
endef

define UBOOT_ROCKCHIP_INSTALL_IMAGES
	cp -dpf $(@D)/uboot.img $(BINARIES_DIR)/uboot.img

	if ls $(@D)/*_download_*.bin >/dev/null 2>&1; then \
		cp -dpf $(@D)/*_download_*.bin $(BINARIES_DIR)/download.bin; \
	fi

	if ls $(@D)/*_idblock_*.img >/dev/null 2>&1; then \
		cp -dpf $(@D)/*_idblock_*.img $(BINARIES_DIR)/idblock.img; \
	fi

	if [ -e $(@D)/idblock.bin ]; then \
		cp -dpf $(@D)/idblock.bin $(BINARIES_DIR)/idblock.bin; \
	fi

	if [ -e $(@D)/env.img ]; then \
		cp -dpf $(@D)/env.img $(BINARIES_DIR)/env.img; \
		cp -dpf $(@D)/env.img $(BINARIES_DIR)/env_r.img; \
	fi
endef

UBOOT_EXTRA_DOWNLOADS += https://github.com/cpebit/rkbin/archive/$(RKBIN_VERSION)/$(RKBIN_ARCHIVE)
BR_NO_CHECK_HASH_FOR += $(RKBIN_ARCHIVE)
UBOOT_POST_EXTRACT_HOOKS += UBOOT_ROCKCHIP_POST_EXTRACT
UBOOT_POST_BUILD_HOOKS += UBOOT_ROCKCHIP_POST_BUILD
ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_ENV),y)
UBOOT_POST_BUILD_HOOKS += UBOOT_ROCKCHIP_BUILD_ENV_IMAGE
endif
ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_BOOT_SCRIPT),y)
UBOOT_POST_BUILD_HOOKS += UBOOT_ROCKCHIP_BUILD_BOOT_SCRIPT
UBOOT_POST_INSTALL_TARGET_HOOKS += UBOOT_ROCKCHIP_INSTALL_BOOT_SCRIPT
endif
UBOOT_POST_INSTALL_IMAGES_HOOKS += UBOOT_ROCKCHIP_INSTALL_IMAGES
endif