AA_PROXY_RS_VERSION = main
AA_PROXY_RS_SITE = https://github.com/aa-proxy/aa-proxy-rs.git
AA_PROXY_RS_SITE_METHOD = git

# obtain git hashes for aa-proxy-rs and buildroot
BUILDROOT_DIR = $(realpath $(TOPDIR)/..)
BUILDROOT_COMMIT = $(shell git config --global --add safe.directory $(BUILDROOT_DIR) && git -C $(BUILDROOT_DIR) rev-parse HEAD)
AA_PROXY_RS_GIT_DIR = $(realpath $(DL_DIR)/aa-proxy-rs/git)
AA_PROXY_RS_COMMIT = $(shell git config --global --add safe.directory $(AA_PROXY_RS_GIT_DIR) && git -C $(AA_PROXY_RS_GIT_DIR) rev-parse HEAD)

define AA_PROXY_RS_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/aa-proxy-rs $(TARGET_DIR)/usr/bin
    $(INSTALL) -D -m 0644 $(@D)/target/release/config.toml $(TARGET_DIR)/etc/aa-proxy-rs/config.toml
    $(INSTALL) -D -m 0755 $(@D)/contrib/S93aa-proxy-rs $(TARGET_DIR)/etc/init.d
endef

# pass git hashes as env variables
AA_PROXY_RS_CARGO_ENV = \
    AA_PROXY_COMMIT="$(AA_PROXY_RS_COMMIT)" \
    BUILDROOT_COMMIT="$(BUILDROOT_COMMIT)"

# default config file generator
define AA_PROXY_RS_GENERATE_CONFIG
    cd $(@D) && env PATH=$${PATH}:$(HOST_DIR)/bin cargo run --release --bin generate_config
endef
AA_PROXY_RS_POST_BUILD_HOOKS += AA_PROXY_RS_GENERATE_CONFIG

$(eval $(cargo-package))
