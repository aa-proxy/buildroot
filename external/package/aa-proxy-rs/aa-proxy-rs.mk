AA_PROXY_RS_VERSION = main
AA_PROXY_RS_SITE = https://github.com/aa-proxy/aa-proxy-rs.git
AA_PROXY_RS_SITE_METHOD = git

# openssl backend is now compiled in alongside rustls (runtime choice via
# config.toml), so openssl-sys needs to find libssl/libcrypto + headers in
# staging via pkg-config during the cross-build
AA_PROXY_RS_DEPENDENCIES += openssl

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
    BUILDROOT_COMMIT="$(BUILDROOT_COMMIT)" \
    AA_PROXY_BOARD="$(notdir $(patsubst %/,%,$(CONFIG_DIR)))"

# use own toolchain only for RISC-V builds (milkv-duos)
ifeq ($(findstring milkv-duos,$(CONFIG_DIR)),milkv-duos)
# Add our own toolchain to path
AA_PROXY_RS_CARGO_ENV += PATH=/app/buildroot/output/milkv-duos/build/riscv/bin:$(BR_PATH)
endif

# aa-proxy-rs defaults to the wasm-scripting + io-uring features. Guard on the
# package itself: with it disabled the IO_URING symbol is absent entirely, and
# an unguarded "!= y" would otherwise select features for a board that never
# builds this package.
ifeq ($(BR2_PACKAGE_AA_PROXY_RS),y)
ifeq ($(RUSTC_TARGET_NAME),arm-unknown-linux-gnueabihf)
# disable wasm-scripting on armv6 (wasmtime doesn't support it); this drops
# io-uring too, which armv6 boards have not needed so far
AA_PROXY_RS_CARGO_BUILD_OPTS += --no-default-features
else ifneq ($(BR2_PACKAGE_AA_PROXY_RS_IO_URING),y)
# io_uring only exists from kernel 5.1; on 4.19 tokio_uring::start() panics with
# ENOSYS before the proxy gets going. Keep wasm-scripting, drop io-uring.
AA_PROXY_RS_CARGO_BUILD_OPTS += --no-default-features --features wasm-scripting
endif
endif

# default config file generator
define AA_PROXY_RS_GENERATE_CONFIG
    cd $(@D) && env PATH=$${PATH}:$(HOST_DIR)/bin cargo run --release --bin generate_config
endef
AA_PROXY_RS_POST_BUILD_HOOKS += AA_PROXY_RS_GENERATE_CONFIG

$(eval $(cargo-package))
