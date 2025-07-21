AA_PROXY_RS_VERSION = 6bcc2cf3df3a8c4f0a375c10352d410a86c94330
AA_PROXY_RS_SITE = $(call github,aa-proxy,aa-proxy-rs,$(AA_PROXY_RS_VERSION))

define AA_PROXY_RS_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/aa-proxy-rs $(TARGET_DIR)/usr/bin
endef

$(eval $(cargo-package))
