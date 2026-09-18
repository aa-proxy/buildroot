RKWIFIBT_VERSION = 3bf28ef23d0d185af036a03c67c0bbec280aadcf
RKWIFIBT_SITE = $(call github,cpebit,rkwifibt,$(RKWIFIBT_VERSION))

RKWIFIBT_PACKAGE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifeq ($(BR2_PACKAGE_RKWIFIBT_RTL8733BS),y)
define RKWIFIBT_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/realtek/rtk_hciattach
endef

define RKWIFIBT_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/realtek/rtk_hciattach/rtk_hciattach $(TARGET_DIR)/usr/bin
    $(INSTALL) -D -m 0755 $(RKWIFIBT_PACKAGE_DIR)/S10rtk_hciattach $(TARGET_DIR)/etc/init.d/
    $(SED) 's|@BT_UART_DEV@|$(BR2_PACKAGE_RKWIFIBT_BT_UART_DEV)|g' $(TARGET_DIR)/etc/init.d/S10rtk_hciattach
    $(SED) 's|@BT_UART_BAUDRATE@|$(BR2_PACKAGE_RKWIFIBT_BT_UART_BAUDRATE)|g' $(TARGET_DIR)/etc/init.d/S10rtk_hciattach

    $(INSTALL) -d $(TARGET_DIR)/lib/firmware/rtlbt/
    $(INSTALL) -D -m 0644 $(@D)/realtek/RTL8733BS/rtl8733bs_config $(TARGET_DIR)/lib/firmware/rtlbt/
    $(INSTALL) -D -m 0644 $(@D)/realtek/RTL8733BS/rtl8733bs_fw $(TARGET_DIR)/lib/firmware/rtlbt/
endef
endif

ifeq ($(BR2_PACKAGE_RKWIFIBT_AIC8800),y)
define RKWIFIBT_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(RKWIFIBT_PACKAGE_DIR)/S10btattach $(TARGET_DIR)/etc/init.d/
    $(SED) 's|@BT_UART_DEV@|$(BR2_PACKAGE_RKWIFIBT_BT_UART_DEV)|g' $(TARGET_DIR)/etc/init.d/S10btattach
    $(SED) 's|@BT_UART_BAUDRATE@|$(BR2_PACKAGE_RKWIFIBT_BT_UART_BAUDRATE)|g' $(TARGET_DIR)/etc/init.d/S10btattach

    $(INSTALL) -d $(TARGET_DIR)/lib/firmware/aic8800/
    $(INSTALL) -D -m 0644 $(@D)/firmware/aic/aic8800D80/* $(TARGET_DIR)/lib/firmware/aic8800/
endef
endif

# The Broadcom modules all run bcmdhd, which ignores the compiled-in
# CONFIG_BCMDHD_FW_PATH: dhd_conf_set_fw_name_by_chip() rewrites it from the
# SDIO chip id and revision it probed, via chip_name_map[] in dhd_config.c, so
# the files have to be named for the chip rather than the generic
# fw_bcmdhd.bin/nvram.txt:
#   BCM4345  rev 6 (AP6255) -> fw_ap6255_ag.bin, nvram_ap6255.txt
#   BCM43454 rev 6 (AP6254) -> fw_ap6254_ag.bin, nvram_ap6254.txt
#   BCM4345  rev 9 (AP6256) -> fw_ap6256_ag.bin, nvram_ap6256.txt
# The clm_*.blob and config.txt it also looks for are optional; rkwifibt ships
# no CLM blob for these and the driver falls back to its built-in one.
RKWIFIBT_BROADCOM_DIR = $(@D)/firmware/broadcom
RKWIFIBT_FIRMWARE_DIR = $(TARGET_DIR)/system/etc/firmware

ifeq ($(BR2_PACKAGE_RKWIFIBT_AP625X),y)
# brcm_tools ships no Makefile, so build the patchram tool straight from source.
define RKWIFIBT_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(@D)/brcm_tools/brcm_patchram_plus1.c -o $(@D)/brcm_patchram_plus
endef

define RKWIFIBT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AP6254/wifi/fw_bcm43455c0_ag.bin \
		$(RKWIFIBT_FIRMWARE_DIR)/fw_ap6254_ag.bin
	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AP6254/wifi/nvram_ap6254.txt \
		$(RKWIFIBT_FIRMWARE_DIR)/nvram_ap6254.txt
	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AP6254/bt/BCM4345C0.hcd \
		$(RKWIFIBT_FIRMWARE_DIR)/ap6254.hcd

	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AW-CM256/wifi/cyfmac43455-sdio-release-7.45.100.18.bin \
		$(RKWIFIBT_FIRMWARE_DIR)/fw_ap6255_ag.bin
	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AW-CM256/wifi/cyfmac43455-sdio.txt \
		$(RKWIFIBT_FIRMWARE_DIR)/nvram_ap6255.txt
	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AW-CM256/bt/BCM4345C0.hcd \
		$(RKWIFIBT_FIRMWARE_DIR)/ap6255.hcd

	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AP6256/wifi/fw_bcm43456c5_ag.bin \
		$(RKWIFIBT_FIRMWARE_DIR)/fw_ap6256_ag.bin
	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AP6256/wifi/nvram_ap6256.txt \
		$(RKWIFIBT_FIRMWARE_DIR)/nvram_ap6256.txt
	$(INSTALL) -D -m 0644 $(RKWIFIBT_BROADCOM_DIR)/AP6256/bt/BCM4345C5.hcd \
		$(RKWIFIBT_FIRMWARE_DIR)/ap6256.hcd

	$(INSTALL) -D -m 0755 $(@D)/brcm_patchram_plus $(TARGET_DIR)/usr/bin/brcm_patchram_plus
	$(INSTALL) -D -m 0755 $(RKWIFIBT_PACKAGE_DIR)/S10brcm_patchram $(TARGET_DIR)/etc/init.d/
	$(SED) 's|@BT_FIRMWARE_DIR@|/system/etc/firmware|g' $(TARGET_DIR)/etc/init.d/S10brcm_patchram
	$(SED) 's|@BT_UART_DEV@|$(call qstrip,$(BR2_PACKAGE_RKWIFIBT_BT_UART_DEV))|g' $(TARGET_DIR)/etc/init.d/S10brcm_patchram
	$(SED) 's|@BT_UART_BAUDRATE@|$(call qstrip,$(BR2_PACKAGE_RKWIFIBT_BT_UART_BAUDRATE))|g' $(TARGET_DIR)/etc/init.d/S10brcm_patchram
endef
endif

$(eval $(generic-package))