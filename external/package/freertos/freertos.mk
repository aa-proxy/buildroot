FREERTOS_VERSION = 388f300771219b3094104f7c805800cfea8eb548
FREERTOS_SITE = $(call github,sophgo,freertos,$(FREERTOS_VERSION))

define FREERTOS_BUILD_CMDS
    # we need to clone subdirectories as well besides the main, details:
    # https://github.com/milkv-duo/duo-buildroot-sdk-v2/blob/main/.version/version.md
    git clone -b sg200x-dev --single-branch --depth=1 https://github.com/sophgo/FreeRTOS-Kernel.git $(@D)/Source || echo "dir exists"
    git clone -b sg200x-dev --single-branch --depth=1 https://github.com/sophgo/Lab-Project-FreeRTOS-POSIX.git $(@D)/Source/FreeRTOS-Plus-POSIX || echo "dir exists"

    cd $(@D)/cvitek && \
    env CONFIG_FAST_IMAGE_TYPE=0 DDR_64MB_SIZE=n PATH="$$PATH:/app/host-tools/gcc/riscv64-elf-x86_64/bin" \
    ./build_cv181x.sh
endef

$(eval $(generic-package))
