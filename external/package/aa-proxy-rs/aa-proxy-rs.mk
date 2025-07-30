AA_PROXY_RS_VERSION = 2639cf0b3091c57cb3ea02174e495ba7edbb036d
AA_PROXY_RS_SITE = $(call github,aa-proxy,aa-proxy-rs,$(AA_PROXY_RS_VERSION))
BUILDROOT_DIR = $(realpath $(TOPDIR)/..)
BUILDROOT_COMMIT = $(shell git config --global --add safe.directory $(BUILDROOT_DIR) && git -C $(BUILDROOT_DIR) rev-parse HEAD)

define AA_PROXY_RS_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/aa-proxy-rs $(TARGET_DIR)/usr/bin
    $(INSTALL) -D -m 0644 $(@D)/contrib/config.toml $(TARGET_DIR)/etc/aa-proxy-rs/config.toml
endef

AA_PROXY_RS_CARGO_ENV = \
    AA_PROXY_COMMIT="$(AA_PROXY_RS_VERSION)" \
    BUILDROOT_COMMIT="$(BUILDROOT_COMMIT)"

$(eval $(cargo-package))
