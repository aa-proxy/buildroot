################################################################################
#
# uwe5622 - Unisoc/Spreadtrum UWE5622 WiFi driver (packaged as AW859A)
#
################################################################################

UWE5622_VERSION = 9422f6e27168932270db03c3d37743679c710aaa
UWE5622_SITE = $(call github,armbian,uwe5622,$(UWE5622_VERSION))
UWE5622_LICENSE = GPL-2.0

# tty-sdio (Bluetooth over SDIO)'s own Makefile hardcodes an include path
# relative to the kernel source tree (drivers/net/wireless/uwe5622/unisocwcn/
# include), which assumes in-tree placement. It also honors UNISOC_BSP_INCLUDE
# as an extra -I, which we point at our own unisocwcn/include to satisfy it
# out-of-tree instead of patching the hardcoded path.

UWE5622_MODULE_MAKE_OPTS = \
	CONFIG_AW_WIFI_DEVICE_UWE5622=y \
	CONFIG_WLAN_UWE5622=m \
	CONFIG_UNISOC_WIFI_PS=$(BR2_PACKAGE_UWE5622_WIFI_PS) \
	UNISOC_FW_PATH_CONFIG=/lib/firmware/uwe5622/ \
	UNISOC_WIFI_CUS_CONFIG=/lib/firmware/uwe5622 \
	UNISOC_BSP_INCLUDE=$(@D)/unisocwcn/include

ifeq ($(BR2_PACKAGE_UWE5622_BLUETOOTH),y)
UWE5622_MODULE_MAKE_OPTS += CONFIG_TTY_OVERY_SDIO=m
endif

# Firmware isn't bundled in the armbian/uwe5622 driver repo itself;
# it lives in armbian/firmware. Grab just the files needed for this
# chip instead of the whole (large) firmware repo.
UWE5622_EXTRA_DOWNLOADS = \
	https://raw.githubusercontent.com/armbian/firmware/master/uwe5622/wcnmodem.bin \
	https://raw.githubusercontent.com/armbian/firmware/master/uwe5622/wifi_2355b001_1ant.ini

define UWE5622_INSTALL_FIRMWARE
	$(INSTALL) -D -m 0644 $(UWE5622_DL_DIR)/wcnmodem.bin \
		$(TARGET_DIR)/lib/firmware/uwe5622/wcnmodem.bin
	$(INSTALL) -D -m 0644 $(UWE5622_DL_DIR)/wifi_2355b001_1ant.ini \
		$(TARGET_DIR)/lib/firmware/uwe5622/wifi_2355b001_1ant.ini
endef

UWE5622_INSTALL_TARGET_CMDS += $(UWE5622_INSTALL_FIRMWARE)

$(eval $(kernel-module))
$(eval $(generic-package))

# unisocwifi (sprdwl_ng.ko) calls into symbols exported by unisocwcn
# (uwe5622_bsp_sdio.ko, e.g. start_marlin/get_wcn_bus_ops). The generic
# kernel-module infra (driven by MODULE_SUBDIRS) builds each subdir as an
# independent `M=` invocation with no cross-linking, so unisocwifi's modpost
# fails to resolve them. Override the build/install hooks set up above to
# build unisocwcn first and feed its Module.symvers to unisocwifi via
# KBUILD_EXTRA_SYMBOLS.

define UWE5622_KERNEL_MODULES_BUILD
	@$(call MESSAGE,"Building kernel module(s)")
	$(LINUX_MAKE_ENV) $(UWE5622_MAKE) \
		-C $(LINUX_DIR) \
		$(LINUX_MAKE_FLAGS) \
		$(UWE5622_MODULE_MAKE_OPTS) \
		PWD=$(@D)/unisocwcn \
		M=$(@D)/unisocwcn \
		modules
	$(LINUX_MAKE_ENV) $(UWE5622_MAKE) \
		-C $(LINUX_DIR) \
		$(LINUX_MAKE_FLAGS) \
		$(UWE5622_MODULE_MAKE_OPTS) \
		KBUILD_EXTRA_SYMBOLS=$(@D)/unisocwcn/Module.symvers \
		PWD=$(@D)/unisocwifi \
		M=$(@D)/unisocwifi \
		modules
	$(if $(filter y,$(BR2_PACKAGE_UWE5622_BLUETOOTH)),\
		$(LINUX_MAKE_ENV) $(UWE5622_MAKE) \
			-C $(LINUX_DIR) \
			$(LINUX_MAKE_FLAGS) \
			$(UWE5622_MODULE_MAKE_OPTS) \
			KBUILD_EXTRA_SYMBOLS=$(@D)/unisocwcn/Module.symvers \
			PWD=$(@D)/tty-sdio \
			M=$(@D)/tty-sdio \
			modules)
endef

define UWE5622_KERNEL_MODULES_INSTALL
	@$(call MESSAGE,"Installing kernel module(s)")
	$(LINUX_MAKE_ENV) $(UWE5622_MAKE) \
		-C $(LINUX_DIR) \
		$(LINUX_MAKE_FLAGS) \
		$(UWE5622_MODULE_MAKE_OPTS) \
		PWD=$(@D)/unisocwcn \
		M=$(@D)/unisocwcn \
		modules_install
	$(LINUX_MAKE_ENV) $(UWE5622_MAKE) \
		-C $(LINUX_DIR) \
		$(LINUX_MAKE_FLAGS) \
		$(UWE5622_MODULE_MAKE_OPTS) \
		PWD=$(@D)/unisocwifi \
		M=$(@D)/unisocwifi \
		modules_install
	$(if $(filter y,$(BR2_PACKAGE_UWE5622_BLUETOOTH)),\
		$(LINUX_MAKE_ENV) $(UWE5622_MAKE) \
			-C $(LINUX_DIR) \
			$(LINUX_MAKE_FLAGS) \
			$(UWE5622_MODULE_MAKE_OPTS) \
			PWD=$(@D)/tty-sdio \
			M=$(@D)/tty-sdio \
			modules_install)
endef
