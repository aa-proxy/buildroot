ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP),y)
RKBIN_VERSION = 2c1be1054e86338285309ecc20fa61fc15fd5437
RKBIN_ARCHIVE = rkbin-$(RKBIN_VERSION).tar.gz

# A board can take its idbloader blobs from a second rkbin. rk3308 needs this:
# the DDR and miniloader builds it wants were dropped from Rockchip's rkbin
# years ago and only survive in radxa's fork, which in turn ships no
# tools/mkimage -- so the two trees are used side by side, exactly as
# meta-aawireless did (rk_mkimage from rockchip-linux/rkbin, blobs from radxa).
IDBLOADER_RKBIN_REPO = $(call qstrip,$(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOADER_RKBIN_REPO))
IDBLOADER_RKBIN_VERSION = $(call qstrip,$(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOADER_RKBIN_VERSION))

ifneq ($(IDBLOADER_RKBIN_VERSION),)
IDBLOADER_RKBIN_ARCHIVE = rkbin-$(IDBLOADER_RKBIN_VERSION).tar.gz
UBOOT_EXTRA_DOWNLOADS += https://github.com/$(IDBLOADER_RKBIN_REPO)/archive/$(IDBLOADER_RKBIN_VERSION)/$(IDBLOADER_RKBIN_ARCHIVE)
BR_NO_CHECK_HASH_FOR += $(IDBLOADER_RKBIN_ARCHIVE)

define UBOOT_ROCKCHIP_EXTRACT_IDBLOADER_RKBIN
	mkdir $(@D)/rkbin-idbloader
	$(call suitable-extractor,$(UBOOT_DL_DIR)/$(IDBLOADER_RKBIN_ARCHIVE)) $(UBOOT_DL_DIR)/$(IDBLOADER_RKBIN_ARCHIVE) | \
				$(TAR) --strip-components=1 -C $(@D)/rkbin-idbloader $(TAR_OPTIONS) -
endef
UBOOT_ROCKCHIP_IDBLOADER_RKBIN_DIR = $(@D)/rkbin-idbloader
else
define UBOOT_ROCKCHIP_EXTRACT_IDBLOADER_RKBIN
endef
UBOOT_ROCKCHIP_IDBLOADER_RKBIN_DIR = $(@D)/rkbin
endif

define UBOOT_ROCKCHIP_POST_EXTRACT
	mkdir $(@D)/rkbin
	$(call suitable-extractor,$(UBOOT_DL_DIR)/$(RKBIN_ARCHIVE)) $(UBOOT_DL_DIR)/$(RKBIN_ARCHIVE) | \
				$(TAR) --strip-components=1 -C $(@D)/rkbin $(TAR_OPTIONS) -
	$(UBOOT_ROCKCHIP_EXTRACT_IDBLOADER_RKBIN)
	sed -i -e '/^select_toolchain$$/d' -e '/^clean_files$$/d' -e '/^\t*make/d' $(@D)/make.sh
	sed -i 's|RKBIN_TOOLS=\.\./rkbin/tools|RKBIN_TOOLS=\./rkbin/tools|' $(@D)/make.sh
	if [ -e $(@D)/scripts/uboot.sh ]; then \
		sed -i 's|\.\./rkbin/tools|\./rkbin/tools|' $(@D)/scripts/uboot.sh; \
	fi
endef

# --idblock packs idblock.bin for boards whose BootROM reads the ID block
# straight off eMMC/SD; --spl packs the download.bin and idblock.img pair the
# Rockchip flashing tools want for SPI NAND. They are separate sub-commands and
# emit different files, so pick the one the board is actually flashed with.
# Older trees (rk3308) have neither, and get their ID block from
# UBOOT_ROCKCHIP_BUILD_IDBLOADER below instead.
ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOCK),y)
define UBOOT_ROCKCHIP_POST_BUILD
	cd $(@D) && ./make.sh && ./make.sh --idblock
endef
else ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOADER),y)
define UBOOT_ROCKCHIP_POST_BUILD
	cd $(@D) && ./make.sh
endef
else
define UBOOT_ROCKCHIP_POST_BUILD
	cd $(@D) && ./make.sh && ./make.sh --spl
endef
endif

# The BootROM reads the ID block as a DDR init blob in an "rksd" wrapper
# followed by the miniloader, which is what make.sh --idblock packs on the
# newer trees.
#
# This deliberately uses rkbin's own mkimage rather than the one in the U-Boot
# tree. The rksd writer in the 2017.09 Rockchip fork emits the payload but
# leaves header0 zeroed, and the BootROM rejects an ID block whose (RC4
# scrambled) header0 is missing: the board writes fine and then falls straight
# back to MaskROM. rkbin's binary writes it.
UBOOT_ROCKCHIP_IDBLOADER_SOC = $(call qstrip,$(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOADER_SOC))
UBOOT_ROCKCHIP_IDBLOADER_DDR_BIN = $(call qstrip,$(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOADER_DDR_BIN))
UBOOT_ROCKCHIP_IDBLOADER_MINILOADER_BIN = $(call qstrip,$(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOADER_MINILOADER_BIN))

# An absolute path is used as given; anything else is relative to whichever
# rkbin the idbloader blobs come from.
uboot-rockchip-blob = $(if $(filter /%,$(1)),$(1),$(UBOOT_ROCKCHIP_IDBLOADER_RKBIN_DIR)/$(1))

define UBOOT_ROCKCHIP_BUILD_IDBLOADER
	$(@D)/rkbin/tools/mkimage -n $(UBOOT_ROCKCHIP_IDBLOADER_SOC) -T rksd \
		-d $(call uboot-rockchip-blob,$(UBOOT_ROCKCHIP_IDBLOADER_DDR_BIN)) \
		$(@D)/idbloader.img
	cat $(call uboot-rockchip-blob,$(UBOOT_ROCKCHIP_IDBLOADER_MINILOADER_BIN)) >> $(@D)/idbloader.img
endef

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

	if [ -e $(@D)/idbloader.img ]; then \
		cp -dpf $(@D)/idbloader.img $(BINARIES_DIR)/idbloader.img; \
	fi

	if [ -e $(@D)/trust.img ]; then \
		cp -dpf $(@D)/trust.img $(BINARIES_DIR)/trust.img; \
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
ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_IDBLOADER),y)
UBOOT_POST_BUILD_HOOKS += UBOOT_ROCKCHIP_BUILD_IDBLOADER
endif
ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_ENV),y)
UBOOT_POST_BUILD_HOOKS += UBOOT_ROCKCHIP_BUILD_ENV_IMAGE
endif
ifeq ($(BR2_TARGET_UBOOT_ROCKCHIP_BOOT_SCRIPT),y)
UBOOT_POST_BUILD_HOOKS += UBOOT_ROCKCHIP_BUILD_BOOT_SCRIPT
UBOOT_POST_INSTALL_TARGET_HOOKS += UBOOT_ROCKCHIP_INSTALL_BOOT_SCRIPT
endif
UBOOT_POST_INSTALL_IMAGES_HOOKS += UBOOT_ROCKCHIP_INSTALL_IMAGES
endif