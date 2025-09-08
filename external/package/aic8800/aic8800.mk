################################################################################
#
# AICSemi AIC8800 Drivers
#
################################################################################
AIC8800_VERSION = eb8652a3d85feeba19474e80e362bf0adaf98cfd
AIC8800_SITE = $(call github,radxa-pkg,aic8800,$(AIC8800_VERSION))
AIC8800_LICENSE = GPL-3.0
AIC8800_LICENSE_FILES = LICENCE

AIC8800_PACKAGE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifeq ($(BR2_PACKAGE_AIC8800_BT_WORKAROUND),y)
AIC8800_DEPENDENCIES += bluez5_utils
endif

AIC8800_INTERFACE := $(strip \
  $(if $(BR2_PACKAGE_AIC8800_INTERFACE_SDIO),SDIO) \
  $(if $(BR2_PACKAGE_AIC8800_INTERFACE_PCIE),PCIE) \
  $(if $(BR2_PACKAGE_AIC8800_INTERFACE_USB),USB))

AIC8800_ENABLED_MODELS =  $(strip $(if $(BR2_PACKAGE_AIC8800_FW_AIC8800),aic8800) \
                          $(if $(BR2_PACKAGE_AIC8800_FW_AIC8800D80),aic8800D80) \
                          $(if $(BR2_PACKAGE_AIC8800_FW_AIC8800D80X2),aic8800D80X2) \
                          $(if $(BR2_PACKAGE_AIC8800_FW_AIC8800DC),aic8800DC))

ifeq ($(AIC8800_INTERFACE),USB)
AIC8800_MODULE_SUBDIRS = src/$(AIC8800_INTERFACE)/driver_fw/drivers/aic8800
AIC8800_MODULE_SUBDIRS += src/$(AIC8800_INTERFACE)/driver_fw/drivers/aic_btusb
endif 

ifeq ($(AIC8800_INTERFACE),SDIO)
AIC8800_MODULE_SUBDIRS = src/$(AIC8800_INTERFACE)/driver_fw/driver/aic8800
endif

ifeq ($(AIC8800_INTERFACE),PCIE)
ifeq ($(BR2_PACKAGE_AIC8800_FW_AIC8800D80X2),y)
AIC8800_MODULE_SUBDIRS = src/$(AIC8800_INTERFACE)/driver_fw/driver/aic8800d80x2
else
AIC8800_MODULE_SUBDIRS = src/$(AIC8800_INTERFACE)/driver_fw/driver/aic8800
endif
endif

AIC8800_MODULE_MAKE_OPTS += \
	AIC_WLAN_SUPPORT=$(BR2_PACKAGE_AIC8800_BSP) \
	AIC8800_BTLPM_SUPPORT=$(BR2_PACKAGE_AIC8800_BT_LPM) \
	AIC8800_WLAN_SUPPORT=$(BR2_PACKAGE_AIC8800_WLAN) \
	AIC8800_BTUSB_SUPPORT=$(BR2_PACKAGE_AIC8800_BT_USB)

define AIC8800_APPLY_PATCHES
	@echo "Applying AIC8800 patches..."
	while read patch; do \
		echo "Applying $$patch"; \
		patch -t -d $(@D) -p1 < $(@D)/debian/patches/$$patch; \
	done < $(@D)/debian/patches/series
	cd "$(@D)"
endef
 
AIC8800_PRE_PATCH_HOOKS += AIC8800_APPLY_PATCHES

define AIC8800_COPY_FIRMWARE
	mkdir -p $(TARGET_DIR)/lib/firmware/aic8800_fw
	$(foreach model,$(AIC8800_ENABLED_MODELS), \
		mkdir -p $(TARGET_DIR)/lib/firmware/aic8800_fw/$(AIC8800_INTERFACE)/$(model); \
		$(INSTALL) -D -m 0755 $(@D)/src/$(AIC8800_INTERFACE)/driver_fw/fw/$(model)/* \
		                     $(TARGET_DIR)/lib/firmware/aic8800_fw/$(AIC8800_INTERFACE)/$(model)/;)
endef

AIC8800_INSTALL_TARGET_CMDS += $(AIC8800_COPY_FIRMWARE)

ifeq ($(BR2_PACKAGE_AIC8800_BT_WORKAROUND),y)

define AIC8800_COPY_BT_WORKAROUND
	$(INSTALL) -D -m 0755 $(AIC8800_PACKAGE_DIR)/S25btattach \
							$(TARGET_DIR)/etc/init.d/
endef

AIC8800_INSTALL_TARGET_CMDS += $(AIC8800_COPY_BT_WORKAROUND)
endif


$(eval $(kernel-module))
$(eval $(generic-package))