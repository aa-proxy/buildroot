setenv load_addr "0x6000000"

echo "setting boot args"
setenv bootargs "root=/dev/mmcblk${devnum}p2 console=ttyS2,1500000n8 rw rootwait loglevel=8"
fatload mmc ${devnum}:${distro_bootpart} ${fdt_addr_r} ${fdtfile}
fatload mmc ${devnum}:${distro_bootpart} ${kernel_addr_r} Image

echo booting linux ...
booti ${kernel_addr_r} - ${fdt_addr_r}