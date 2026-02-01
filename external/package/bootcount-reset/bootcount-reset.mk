BOOTCOUNT_RESET_VERSION = 1.0.0

BOOTCOUNT_RESET_PACKAGE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

define BOOTCOUNT_RESET_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(BOOTCOUNT_RESET_PACKAGE_DIR)/bootcount-reset $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 $(BOOTCOUNT_RESET_PACKAGE_DIR)/S99bootcount-reset $(TARGET_DIR)/etc/init.d
endef

$(eval $(generic-package))