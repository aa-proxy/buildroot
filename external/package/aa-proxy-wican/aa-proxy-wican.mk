AA_PROXY_WICAN_VERSION = main
AA_PROXY_WICAN_SITE = https://github.com/aa-proxy/aa-proxy-wican.git
AA_PROXY_WICAN_SITE_METHOD = git

# obtain git hashes for aa-proxy-wican and buildroot
BUILDROOT_DIR = $(realpath $(TOPDIR)/..)
BUILDROOT_COMMIT = $(shell git config --global --add safe.directory $(BUILDROOT_DIR) && git -C $(BUILDROOT_DIR) rev-parse HEAD)
AA_PROXY_WICAN_GIT_DIR = $(realpath $(DL_DIR)/aa-proxy-wican/git)
AA_PROXY_WICAN_COMMIT = $(shell git config --global --add safe.directory $(AA_PROXY_WICAN_GIT_DIR) && git -C $(AA_PROXY_WICAN_GIT_DIR) rev-parse HEAD)

define AA_PROXY_WICAN_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/aa-proxy-wican $(TARGET_DIR)/usr/bin
endef

# pass git hashes as env variables
AA_PROXY_WICAN_CARGO_ENV = \
    AA_PROXY_WICAN_COMMIT="$(AA_PROXY_WICAN_COMMIT)" \
    BUILDROOT_COMMIT="$(BUILDROOT_COMMIT)"

$(eval $(cargo-package))
