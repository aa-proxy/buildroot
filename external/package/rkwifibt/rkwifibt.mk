RKWIFIBT_VERSION = 013367e241ca97399687dc138fe543c1e592fae7
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

$(eval $(generic-package))