AA_PROXY_RS_VERSION = 1806f011c00e8b798cf8be117313070d43d53469
AA_PROXY_RS_SITE = $(call github,aa-proxy,aa-proxy-rs,$(AA_PROXY_RS_VERSION))

define AA_PROXY_RS_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/aa-proxy-rs $(TARGET_DIR)/usr/bin
    $(INSTALL) -D -m 0644 $(@D)/contrib/config.toml $(TARGET_DIR)/etc/aa-proxy-rs/config.toml
endef

$(eval $(cargo-package))
