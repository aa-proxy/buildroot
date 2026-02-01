BOOTCOUNT_RESET_VERSION = 1.0.0
BOOTCOUNT_RESET_SITE = $(BR2_EXTERNAL_AA_PROXY_OS_PATH)/package/bootcount-reset
BOOTCOUNT_RESET_SITE_METHOD = local

define BOOTCOUNT_RESET_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/bootcount-reset $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 $(@D)/S99bootcount-reset $(TARGET_DIR)/etc/init.d
endef

$(eval $(generic-package))