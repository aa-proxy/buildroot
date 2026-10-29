################################################################################
#
# cvi-mpi
#
################################################################################

# sophgo/cvi_mpi, branch sg200x-dev (same revision as in Milk-V duo-buildroot-sdk-v2)
CVI_MPI_VERSION = 587d6238f8adf762ec4b29655996bf82381a0099
CVI_MPI_SITE = $(call github,sophgo,cvi_mpi,$(CVI_MPI_VERSION))
CVI_MPI_LICENSE = Proprietary
CVI_MPI_INSTALL_STAGING = YES
CVI_MPI_DEPENDENCIES = cvi-osdrv

# sys must come first: libvenc/libvdec link with -lsys from $(MW_LIB)
CVI_MPI_MODULES = sys venc vdec

# -Werror is dropped on purpose: it breaks with anything newer than the
# vendor GCC 10. The chip selection is done by the cvi_defines.h hook below.
CVI_MPI_MAKE_OPTS = \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CHIP_ARCH=CV181X \
	WARNING_LEVEL="-Wall"

# Upstream defaults to __CV180X__ and flips it in the top-level 'prepare'
# target, which we do not run. SG2000/SG2002 are CV181X.
define CVI_MPI_SELECT_CHIP
	$(SED) '19,21s/__CV180X__/__CV181X__/' $(@D)/include/linux/cvi_defines.h
	grep -q '__CV181X__' $(@D)/include/linux/cvi_defines.h
endef
CVI_MPI_POST_PATCH_HOOKS += CVI_MPI_SELECT_CHIP

# Per-module Makefiles rely on $(PWD), so cd into each directory
define CVI_MPI_BUILD_CMDS
	mkdir -p $(@D)/lib/3rd
	$(foreach m,$(CVI_MPI_MODULES), \
		cd $(@D)/modules/$(m) && \
		$(TARGET_MAKE_ENV) $(MAKE) $(CVI_MPI_MAKE_OPTS) all || exit 1;)
endef

# Headers keep their "linux/cvi_*.h" layout, so they live in their own
# directory to not clash with the kernel uapi headers.
define CVI_MPI_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/include/cvi_mpi
	cp -a $(@D)/include/. $(STAGING_DIR)/usr/include/cvi_mpi/
	$(foreach m,sys venc vdec, \
		if [ -d $(@D)/modules/$(m)/include ]; then \
			cp -a $(@D)/modules/$(m)/include/. \
				$(STAGING_DIR)/usr/include/cvi_mpi/; \
		fi;)
	$(foreach m,$(CVI_MPI_MODULES), \
		$(INSTALL) -D -m 0755 $(@D)/lib/lib$(m).so $(STAGING_DIR)/usr/lib/lib$(m).so; \
		$(INSTALL) -D -m 0644 $(@D)/lib/lib$(m).a $(STAGING_DIR)/usr/lib/lib$(m).a;)
endef

define CVI_MPI_INSTALL_TARGET_CMDS
	$(foreach m,$(CVI_MPI_MODULES), \
		$(INSTALL) -D -m 0755 $(@D)/lib/lib$(m).so $(TARGET_DIR)/usr/lib/lib$(m).so;)
endef

$(eval $(generic-package))
