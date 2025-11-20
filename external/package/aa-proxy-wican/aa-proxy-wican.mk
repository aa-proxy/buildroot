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

# use own toolchain only for RISC-V builds (milkv-duos)
ifeq ($(findstring milkv-duos,$(CONFIG_DIR)),milkv-duos)
# Add our own toolchain to path
AA_PROXY_WICAN_CARGO_ENV += PATH=/app/buildroot/output/milkv-duos/build/riscv/bin:$(BR_PATH)

# Prepare target build environment with custom toolchain:
# - Remove references to the system toolchain to ensure the build
#   uses our own toolchain paths.
# - Set all relevant compiler and linker flags (CFLAGS, CXXFLAGS, LDFLAGS, etc.)
#   for both host and target builds.
TARGET_CONFIGURE_OPTS = \
        $(TARGET_MAKE_ENV) \
        CPPFLAGS_FOR_BUILD="$(HOST_CPPFLAGS)" \
        CFLAGS_FOR_BUILD="$(HOST_CFLAGS)" \
        CXXFLAGS_FOR_BUILD="$(HOST_CXXFLAGS)" \
        LDFLAGS_FOR_BUILD="$(HOST_LDFLAGS)" \
        FCFLAGS_FOR_BUILD="$(HOST_FCFLAGS)" \
        CPPFLAGS="$(TARGET_CPPFLAGS)" \
        CFLAGS="$(TARGET_CFLAGS)" \
        CXXFLAGS="$(TARGET_CXXFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS)" \
        FCFLAGS="$(TARGET_FCFLAGS)" \
        FFLAGS="$(TARGET_FCFLAGS)" \
        PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
        STAGING_DIR="$(STAGING_DIR)" \
        INTLTOOL_PERL=$(PERL)
endif

$(eval $(cargo-package))
