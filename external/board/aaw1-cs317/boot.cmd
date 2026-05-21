setenv load_addr "0x05000000"

# defaults
setenv kernelimg "zImage"
setenv fdtfile "rv1109-cs317.dtb"
setenv console "ttyS2,1500000n8"
setenv verbosity "4"

echo "Running boot script"

setenv bootargs "console=${console} rw root=/dev/mmcblk0p${bootpart} rootfstype=ext4 init=/sbin/init rootwait systemd.machine_id=${cpuid#}"

load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} ${prefix}${kernelimg}

load ${devtype} ${devnum}:${bootpart} ${fdt_addr_r} ${prefix}${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536

bootz ${kernel_addr_r} - ${fdt_addr_r}