AA_PROXY_OBD_VERSION = main
AA_PROXY_OBD_SITE = https://github.com/aa-proxy/aa-proxy-obd
AA_PROXY_OBD_SITE_METHOD = git

define AA_PROXY_OBD_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/bin/aa-proxy-obd $(TARGET_DIR)/usr/bin
    $(INSTALL) -D -m 0644 $(@D)/configs/aa-proxy-obd.toml $(TARGET_DIR)/etc/aa-proxy-obd.toml
	mkdir -p $(TARGET_DIR)/etc/aa-proxy-obd
	cp -dpfr $(@D)/profiles/*.json $(TARGET_DIR)/etc/aa-proxy-obd/
endef

$(eval $(cargo-package))
