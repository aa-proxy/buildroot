RKWIFIBT_VERSION = 3e96cdc4ec762ba8aa3dda6b9c77cea16865a5b9
RKWIFIBT_SITE = $(call github,cpebit,rkwifibt,$(RKWIFIBT_VERSION))

ifeq ($(BR2_PACKAGE_RKWIFIBT_RTL8733BS),y)
define RKWIFIBT_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/realtek/rtk_hciattach
endef

define RKWIFIBT_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/realtek/rtk_hciattach/rtk_hciattach $(TARGET_DIR)/usr/bin

    $(INSTALL) -d $(TARGET_DIR)/lib/firmware/rtlbt/
    $(INSTALL) -D -m 0644 $(@D)/realtek/RTL8733BS/rtl8733bs_config $(TARGET_DIR)/lib/firmware/rtlbt/
    $(INSTALL) -D -m 0644 $(@D)/realtek/RTL8733BS/rtl8733bs_fw $(TARGET_DIR)/lib/firmware/rtlbt/
endef
endif

$(eval $(generic-package))