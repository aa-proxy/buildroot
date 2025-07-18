AA_PROXY_RS_VERSION = 0.6.0
AA_PROXY_RS_SITE = $(call github,manio,aa-proxy-rs,v$(AA_PROXY_RS_VERSION))

define AA_PROXY_RS_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/target/armv7-unknown-linux-gnueabihf/release/aa-proxy-rs  $(TARGET_DIR)/usr/bin
endef

$(eval $(cargo-package))
