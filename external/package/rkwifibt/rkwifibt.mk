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

ifeq ($(BR2_PACKAGE_RKWIFIBT_AWCM256),y)
# bcmdhd ignores the compiled-in CONFIG_BCMDHD_FW_PATH: dhd_conf_set_path_params()
# rewrites it from the DT's wifi_chip_type (ap6255 here), so the files have to be
# named for the chip rather than the generic fw_bcmdhd.bin/nvram.txt:
#   fw_path = /system/etc/firmware/fw_ap6255_ag.bin
#   nv_path = /system/etc/firmware/nvram_ap6255.txt
# The clm_ap6255_ag.blob and config.txt it also looks for are optional; rkwifibt
# ships no CLM blob for BCM43455 and the driver falls back to its built-in one.
RKWIFIBT_AWCM256_DIR = $(@D)/firmware/broadcom/AW-CM256
RKWIFIBT_AWCM256_BT_FIRMWARE = /system/etc/firmware/ap6255.hcd

# brcm_tools ships no Makefile, so build the patchram tool straight from source.
define RKWIFIBT_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(@D)/brcm_tools/brcm_patchram_plus1.c -o $(@D)/brcm_patchram_plus
endef

define RKWIFIBT_INSTALL_TARGET_CMDS
    $(INSTALL) -d $(TARGET_DIR)/system/etc/firmware/

    $(INSTALL) -D -m 0644 $(RKWIFIBT_AWCM256_DIR)/wifi/cyfmac43455-sdio-release-7.45.100.18.bin \
        $(TARGET_DIR)/system/etc/firmware/fw_ap6255_ag.bin
    $(INSTALL) -D -m 0644 $(RKWIFIBT_AWCM256_DIR)/wifi/cyfmac43455-sdio.txt \
        $(TARGET_DIR)/system/etc/firmware/nvram_ap6255.txt

    $(INSTALL) -D -m 0644 $(RKWIFIBT_AWCM256_DIR)/bt/BCM4345C0.hcd \
        $(TARGET_DIR)$(RKWIFIBT_AWCM256_BT_FIRMWARE)

    $(INSTALL) -D -m 0755 $(@D)/brcm_patchram_plus $(TARGET_DIR)/usr/bin/brcm_patchram_plus
    $(INSTALL) -D -m 0755 $(RKWIFIBT_PACKAGE_DIR)/S10brcm_patchram $(TARGET_DIR)/etc/init.d/
    $(SED) 's|@BT_FIRMWARE_PATH@|$(RKWIFIBT_AWCM256_BT_FIRMWARE)|g' $(TARGET_DIR)/etc/init.d/S10brcm_patchram
    $(SED) 's|@BT_UART_DEV@|$(call qstrip,$(BR2_PACKAGE_RKWIFIBT_BT_UART_DEV))|g' $(TARGET_DIR)/etc/init.d/S10brcm_patchram
    $(SED) 's|@BT_UART_BAUDRATE@|$(call qstrip,$(BR2_PACKAGE_RKWIFIBT_BT_UART_BAUDRATE))|g' $(TARGET_DIR)/etc/init.d/S10brcm_patchram
endef
endif

$(eval $(generic-package))