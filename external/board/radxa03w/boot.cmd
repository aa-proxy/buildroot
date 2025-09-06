setenv load_addr "0x6000000"

echo "setting boot args"
setenv bootargs "root=/dev/mmcblk${devnum}p2 console=ttyS2,1500000n8 rw rootwait loglevel=8 init=/etc/overlay_init"
fatload mmc ${devnum}:${distro_bootpart} ${fdt_addr_r} rk3566-radxa-zero-3w.dtb
fatload mmc ${devnum}:${distro_bootpart} ${kernel_addr_r} Image

echo booting linux ...
booti ${kernel_addr_r} - ${fdt_addr_r}