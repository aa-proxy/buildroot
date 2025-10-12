AA_PROXY_GO_OBD_FEEDER_VERSION = main
AA_PROXY_GO_OBD_FEEDER_SITE = https://github.com/aa-proxy/aa-proxy-go-obd-feeder
AA_PROXY_GO_OBD_FEEDER_SITE_METHOD = git

define AA_PROXY_GO_OBD_FEEDER_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/bin/aa-proxy-go-obd-feeder $(TARGET_DIR)/usr/bin
    $(INSTALL) -D -m 0644 $(@D)/configs/ioniq5n.yaml $(TARGET_DIR)/etc/ev-obd-feeder.yaml
endef

$(eval $(golang-package))
