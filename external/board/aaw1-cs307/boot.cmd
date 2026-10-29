setenv load_addr "0x05000000"
setenv kernel_addr_r "0x00800000"
setenv fdt_addr_r "0x04000000"

# defaults
setenv kernelimg "Image"
setenv fdtfile "rk3308-cs307-e2w3.dtb"
setenv console "ttyS0,1500000n8"
setenv verbosity "4"

echo "Running boot script"

# arm64 has no CONFIG_CMDLINE_EXTEND, so the init=/etc/overlay_init that
# board/aaw-common/kernel.config.part puts in CONFIG_CMDLINE is ignored as soon
# as U-Boot passes bootargs. Pass it here instead. overlay_init mounts /data,
# handles factory reset and the pending restore, sets up the /etc and /var
# overlays and then execs /sbin/init itself.
setenv bootargs "console=${console} rw root=/dev/mmcblk0p${bootpart} rootfstype=ext4 rootwait init=/etc/overlay_init systemd.machine_id=${cpuid#}"

load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} ${prefix}${kernelimg}

load ${devtype} ${devnum}:${bootpart} ${fdt_addr_r} ${prefix}${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536

booti ${kernel_addr_r} - ${fdt_addr_r}