setenv load_addr "0x05000000"

# defaults
setenv kernelimg "zImage"
setenv fdtfile "rv1109-cs317.dtb"
setenv console "ttyS2,1500000n8"
setenv verbosity "4"

echo "Running boot script"

# No init= here on purpose. CONFIG_CMDLINE_EXTEND seeds the command line with
# the built-in string and appends these after it, so an init= here would be the
# last one parsed and would win over the init=/etc/overlay_init that
# board/aaw-common/kernel.config.part sets. overlay_init mounts /data, handles
# factory reset and the pending restore, sets up the /etc and /var overlays and
# then execs /sbin/init itself.
setenv bootargs "console=${console} rw root=/dev/mmcblk0p${bootpart} rootfstype=ext4 rootwait systemd.machine_id=${cpuid#}"

load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} ${prefix}${kernelimg}

load ${devtype} ${devnum}:${bootpart} ${fdt_addr_r} ${prefix}${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536

bootz ${kernel_addr_r} - ${fdt_addr_r}